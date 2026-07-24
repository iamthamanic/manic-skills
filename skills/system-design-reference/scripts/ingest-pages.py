#!/usr/bin/env python3
"""Ingest LinkedIn Posts 2024 Blue PDF into references/pages/*.md.

Default: text extraction (offline, no API).
Future: --vision uses an LLM vision API when OPENAI_API_KEY or similar is set.

Usage:
  python3 ingest-pages.py --pages 8-20
  python3 ingest-pages.py --all
  python3 ingest-pages.py --page 9
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

try:
    import pypdf
except ImportError:
    print("Install pypdf: pip install pypdf", file=sys.stderr)
    sys.exit(1)

SKILL_ROOT = Path(__file__).resolve().parents[1]
PDF_PATH = SKILL_ROOT / "assets" / "linkedin-posts-2024-blue.pdf"
PAGES_DIR = SKILL_ROOT / "references" / "pages"

TAG_RULES = [
    ("api", ["rest api", "graphql", "grpc", "api ", "webhook", "oauth", "http "]),
    ("security", ["security", "xss", "oauth", "jwt", "https", "auth", "cookie", "vpn", "firewall"]),
    ("data", ["database", "sql", "redis", "cache", "sharding", "acid", "postgres", "elastic", "cdc"]),
    ("messaging", ["kafka", "event sourcing", "pub/sub", "messaging", "queue"]),
    ("architecture", ["microservice", "system design", "architectural", "monolith", "12-factor"]),
    ("networking", ["load balanc", "dns", "tcp", "udp", "http", "polling"]),
    ("devops", ["docker", "kubernetes", "k8s", "gitops", "ci/cd", "deploy", "linux"]),
    ("reliability", ["retry", "fault", "disaster", "cap ", "consistency"]),
    ("principles", ["solid", "kiss", "dry", "cap", "base", "trade-off"]),
]


def norm(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "")).strip()


def slugify(title: str, page: int) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:60] or f"page-{page}"
    return f"{page:03d}-{s}"


def guess_tags(title: str, body: str) -> list[str]:
    blob = (title + " " + body).lower()
    tags = [t for t, kws in TAG_RULES if any(k in blob for k in kws)]
    return tags or ["general"]


def extract_bullets(raw: str, title: str) -> list[str]:
    bullets = []
    for line in re.split(r"[•\n]", raw):
        line = norm(line)
        if 20 < len(line) < 220 and line != title:
            bullets.append(line)
    return bullets[:7]


def write_page(page_num: int, title: str, raw: str, ingest: str = "text-extract-v1") -> Path:
    PAGES_DIR.mkdir(parents=True, exist_ok=True)
    text = norm(raw)
    tags = guess_tags(title, text)
    bullets = extract_bullets(raw, title)
    slug = slugify(title, page_num)
    out = PAGES_DIR / f"{slug}.md"

    en_bullets = (
        "\n".join(f"- {b}" for b in bullets)
        if bullets
        else "- (Image-heavy page — see PDF asset for diagram.)"
    )

    content = f"""---
page: {page_num}
title: {title.replace('"', "'")}
title_de: {title.replace('"', "'")}
tags: [{', '.join(tags)}]
source: linkedin-posts-2024-blue.pdf
ingest: {ingest}
---

## Summary (EN)
{en_bullets}

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite {page_num}. Mit `--vision` DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page {page_num} for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (tags: {', '.join(tags)}).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite {page_num} |
"""
    out.write_text(content, encoding="utf-8")
    return out


def parse_page_range(spec: str, max_page: int) -> list[int]:
    if spec == "all":
        return list(range(1, max_page + 1))
    pages: list[int] = []
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            a, b = part.split("-", 1)
            pages.extend(range(int(a), int(b) + 1))
        else:
            pages.append(int(part))
    return sorted({p for p in pages if 1 <= p <= max_page})


def main() -> None:
    parser = argparse.ArgumentParser(description="Ingest PDF pages into skill references")
    parser.add_argument("--page", type=int, help="Single page number")
    parser.add_argument("--pages", type=str, help="Range e.g. 8-20 or all")
    parser.add_argument("--vision", action="store_true", help="Vision enrich (requires API; not yet wired)")
    args = parser.parse_args()

    if args.vision:
        print("Vision ingest: not wired in v1. Set OPENAI_API_KEY and extend this script.", file=sys.stderr)

    reader = pypdf.PdfReader(str(PDF_PATH))
    max_page = len(reader.pages)

    if args.page:
        page_list = [args.page]
    elif args.pages:
        page_list = parse_page_range(args.pages, max_page)
    else:
        page_list = list(range(1, max_page + 1))

    ingest_tag = "text-extract-v1"
    for page_num in page_list:
        raw = reader.pages[page_num - 1].extract_text() or ""
        lines = [norm(l) for l in raw.split("\n") if norm(l)]
        title = lines[0] if lines else f"Page {page_num}"
        if len(title) > 120:
            title = title[:117] + "..."
        path = write_page(page_num, title, raw, ingest_tag)
        print(f"wrote {path.name}")

    print(f"Done: {len(page_list)} pages")


if __name__ == "__main__":
    main()
