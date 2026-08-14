#!/usr/bin/env python3
"""Build and validate ChatGPT upload packages from the shared skill source tree.

The repository stores provider-neutral skills in ``skills/<name>``. ChatGPT does
not consume a local global skill directory, so this adapter produces one upload
archive per skill at ``dist/chatgpt/<name>/skill.zip``.

During export the adapter:
- validates the source ``SKILL.md`` frontmatter,
- canonicalizes ChatGPT frontmatter to ``name`` + ``description``,
- preserves a source ``agents/openai.yaml`` when present or generates one,
- keeps the skill directory as the ZIP root,
- enforces the 25 MiB upload limit, and
- writes a deterministic manifest with SHA-256 hashes.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

MAX_SKILL_ZIP_BYTES = 25 * 1024 * 1024
DEFAULT_OUTPUT = Path("dist/chatgpt")


class ProviderError(RuntimeError):
    """Raised when a skill cannot be exported safely for ChatGPT."""


@dataclass(frozen=True)
class SkillMetadata:
    name: str
    description: str
    body: str


def _strip_optional_quotes(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        quote = value[0]
        inner = value[1:-1]
        if quote == '"':
            try:
                decoded = json.loads(value)
                if isinstance(decoded, str):
                    return decoded
            except json.JSONDecodeError:
                pass
        return inner.replace("''", "'") if quote == "'" else inner
    return value


def _read_scalar(lines: list[str], index: int, raw_value: str) -> tuple[str, int]:
    value = raw_value.strip()
    if value not in {"|", "|-", "|+", ">", ">-", ">+"}:
        return _strip_optional_quotes(value), index + 1

    folded = value.startswith(">")
    block: list[str] = []
    cursor = index + 1
    min_indent: int | None = None

    while cursor < len(lines):
        line = lines[cursor]
        if not line.strip():
            block.append("")
            cursor += 1
            continue

        indent = len(line) - len(line.lstrip(" "))
        if indent == 0:
            break
        if min_indent is None:
            min_indent = indent
        if indent < min_indent:
            break
        block.append(line[min_indent:])
        cursor += 1

    if folded:
        pieces: list[str] = []
        paragraph: list[str] = []
        for item in block:
            if item == "":
                if paragraph:
                    pieces.append(" ".join(paragraph))
                    paragraph = []
                pieces.append("")
            else:
                paragraph.append(item)
        if paragraph:
            pieces.append(" ".join(paragraph))
        result = "\n".join(pieces)
    else:
        result = "\n".join(block)

    return result.rstrip("\n"), cursor


def parse_skill_md(skill_md: Path) -> SkillMetadata:
    try:
        content = skill_md.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise ProviderError(f"{skill_md}: SKILL.md must be UTF-8") from exc

    lines = content.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ProviderError(f"{skill_md}: missing YAML frontmatter start delimiter")

    end = None
    for index in range(1, len(lines)):
        if lines[index].strip() == "---":
            end = index
            break
    if end is None:
        raise ProviderError(f"{skill_md}: missing YAML frontmatter end delimiter")

    frontmatter_lines = lines[1:end]
    values: dict[str, str] = {}
    cursor = 0
    while cursor < len(frontmatter_lines):
        line = frontmatter_lines[cursor]
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            cursor += 1
            continue
        if line.startswith((" ", "\t")):
            cursor += 1
            continue
        if ":" not in line:
            cursor += 1
            continue
        key, raw_value = line.split(":", 1)
        key = key.strip()
        scalar, cursor = _read_scalar(frontmatter_lines, cursor, raw_value)
        values[key] = scalar

    name = values.get("name", "").strip()
    description = values.get("description", "").strip()

    if not name:
        raise ProviderError(f"{skill_md}: missing non-empty 'name' in frontmatter")
    if not description:
        raise ProviderError(f"{skill_md}: missing non-empty 'description' in frontmatter")
    if len(name) > 64:
        raise ProviderError(f"{skill_md}: name exceeds 64 characters")
    if not all(char.islower() or char.isdigit() or char == "-" for char in name):
        raise ProviderError(
            f"{skill_md}: name must use lowercase letters, digits, and hyphens only"
        )
    if name.startswith("-") or name.endswith("-") or "--" in name:
        raise ProviderError(f"{skill_md}: invalid hyphen placement in name '{name}'")
    if len(description) > 1024:
        raise ProviderError(f"{skill_md}: description exceeds 1024 characters")
    if "<" in description or ">" in description:
        raise ProviderError(f"{skill_md}: description cannot contain angle brackets")

    body_lines = lines[end + 1 :]
    body = "\n".join(body_lines)
    if content.endswith("\n"):
        body += "\n"

    return SkillMetadata(name=name, description=description, body=body)


def yaml_quote(value: str) -> str:
    """Return a JSON string, which is also a valid YAML double-quoted scalar."""
    return json.dumps(value, ensure_ascii=False)


def canonical_skill_md(metadata: SkillMetadata) -> str:
    return (
        "---\n"
        f"name: {yaml_quote(metadata.name)}\n"
        f"description: {yaml_quote(metadata.description)}\n"
        "---\n\n"
        f"{metadata.body.lstrip(chr(10))}"
    )


def humanize_name(name: str) -> str:
    special = {
        "api": "API",
        "ci": "CI",
        "cd": "CD",
        "ecc": "ECC",
        "github": "GitHub",
        "mcp": "MCP",
        "prd": "PRD",
        "ui": "UI",
        "ux": "UX",
    }
    words = []
    for part in name.split("-"):
        words.append(special.get(part, part.capitalize()))
    return " ".join(words)


def short_description(description: str, limit: int = 120) -> str:
    compact = " ".join(description.split())
    if len(compact) <= limit:
        return compact
    cutoff = compact.rfind(" ", 0, limit - 1)
    if cutoff < max(20, limit // 2):
        cutoff = limit - 1
    return compact[:cutoff].rstrip(" .,:;-") + "…"


def generated_openai_yaml(metadata: SkillMetadata) -> str:
    return (
        "interface:\n"
        f"  display_name: {yaml_quote(humanize_name(metadata.name))}\n"
        f"  short_description: {yaml_quote(short_description(metadata.description))}\n"
    )


def discover_skill_dirs(repo_root: Path, selected: Iterable[str] | None = None) -> list[Path]:
    skills_root = repo_root / "skills"
    if not skills_root.is_dir():
        raise ProviderError(f"skills directory not found: {skills_root}")

    selected_set = set(selected or [])
    result = sorted(path for path in skills_root.iterdir() if path.is_dir())
    if selected_set:
        by_name = {path.name: path for path in result}
        missing = sorted(selected_set - by_name.keys())
        if missing:
            raise ProviderError(f"unknown skill(s): {', '.join(missing)}")
        result = [by_name[name] for name in sorted(selected_set)]
    return result


def validate_source_skill(skill_dir: Path) -> SkillMetadata:
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        raise ProviderError(f"{skill_dir.name}: SKILL.md not found")

    metadata = parse_skill_md(skill_md)
    if metadata.name != skill_dir.name:
        raise ProviderError(
            f"{skill_dir.name}: frontmatter name '{metadata.name}' must match directory name"
        )

    for path in skill_dir.rglob("*"):
        if path.is_symlink():
            raise ProviderError(f"{skill_dir.name}: symlinks are not allowed in ChatGPT packages: {path}")

    return metadata


def _write_zip_member(zip_file: zipfile.ZipFile, arcname: str, data: str) -> None:
    info = zipfile.ZipInfo(arcname)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.external_attr = 0o644 << 16
    zip_file.writestr(info, data.encode("utf-8"))


def export_skill(skill_dir: Path, output_root: Path) -> dict[str, object]:
    metadata = validate_source_skill(skill_dir)
    skill_output = output_root / metadata.name
    skill_output.mkdir(parents=True, exist_ok=True)
    archive_path = skill_output / "skill.zip"

    source_openai_yaml = skill_dir / "agents" / "openai.yaml"
    generated_metadata = not source_openai_yaml.is_file()

    with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zip_file:
        prefix = Path(metadata.name)
        for path in sorted(skill_dir.rglob("*")):
            if not path.is_file():
                continue
            relative = path.relative_to(skill_dir)
            arcname = str(prefix / relative)

            if relative == Path("SKILL.md"):
                _write_zip_member(zip_file, arcname, canonical_skill_md(metadata))
                continue

            if relative == Path("agents/openai.yaml"):
                zip_file.write(path, arcname)
                continue

            zip_file.write(path, arcname)

        if generated_metadata:
            _write_zip_member(
                zip_file,
                str(prefix / "agents" / "openai.yaml"),
                generated_openai_yaml(metadata),
            )

    archive_size = archive_path.stat().st_size
    if archive_size > MAX_SKILL_ZIP_BYTES:
        archive_path.unlink(missing_ok=True)
        raise ProviderError(
            f"{metadata.name}: skill.zip is {archive_size:,} bytes; ChatGPT limit is "
            f"{MAX_SKILL_ZIP_BYTES:,} bytes"
        )

    digest = hashlib.sha256(archive_path.read_bytes()).hexdigest()
    return {
        "name": metadata.name,
        "source": str(skill_dir),
        "package": str(archive_path),
        "bytes": archive_size,
        "sha256": digest,
        "generated_openai_yaml": generated_metadata,
    }


def verify_skills(repo_root: Path, selected: Iterable[str] | None = None) -> list[str]:
    messages: list[str] = []
    skill_dirs = discover_skill_dirs(repo_root, selected)
    with tempfile.TemporaryDirectory(prefix="manic-chatgpt-verify-") as temp_dir:
        output_root = Path(temp_dir)
        for skill_dir in skill_dirs:
            record = export_skill(skill_dir, output_root)
            messages.append(
                f"OK    {record['name']} ({record['bytes']} bytes, "
                f"openai.yaml={'generated' if record['generated_openai_yaml'] else 'source'})"
            )
    return messages


def export_skills(
    repo_root: Path,
    output_root: Path,
    selected: Iterable[str] | None = None,
) -> list[dict[str, object]]:
    skill_dirs = discover_skill_dirs(repo_root, selected)
    if output_root.exists():
        shutil.rmtree(output_root)
    output_root.mkdir(parents=True, exist_ok=True)

    records = [export_skill(skill_dir, output_root) for skill_dir in skill_dirs]
    manifest = {
        "provider": "chatgpt",
        "format": "agent-skills",
        "count": len(records),
        "packages": records,
    }
    (output_root / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return records


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="ChatGPT provider adapter for manic-skills")
    parser.add_argument(
        "command",
        choices=("export", "verify", "clean"),
        nargs="?",
        default="export",
        help="export packages, verify exportability, or remove generated packages",
    )
    parser.add_argument(
        "--repo",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root (defaults to the parent of scripts/)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="output directory (defaults to <repo>/dist/chatgpt)",
    )
    parser.add_argument(
        "--skill",
        action="append",
        default=[],
        help="export/verify only one skill; repeat for multiple skills",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    repo_root = args.repo.resolve()
    output_root = (args.output or (repo_root / DEFAULT_OUTPUT)).resolve()

    try:
        if args.command == "clean":
            if output_root.exists():
                shutil.rmtree(output_root)
                print(f"Removed {output_root}")
            else:
                print(f"Nothing to remove: {output_root}")
            return 0

        if args.command == "verify":
            messages = verify_skills(repo_root, args.skill)
            for message in messages:
                print(message)
            print(f"ChatGPT provider: {len(messages)} skill(s) exportable")
            return 0

        records = export_skills(repo_root, output_root, args.skill)
        for record in records:
            print(f"EXPORTED {record['name']} -> {record['package']}")
        print(f"ChatGPT provider: exported {len(records)} skill(s) to {output_root}")
        print("Upload each <skill>/skill.zip via ChatGPT Skills > Create > Upload from your computer.")
        return 0
    except ProviderError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
