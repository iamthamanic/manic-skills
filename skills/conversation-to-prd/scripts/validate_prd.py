#!/usr/bin/env python3
"""Validate structural and traceability basics of a PRD produced by this skill."""

from __future__ import annotations

import argparse
import re
import sys
from collections import Counter
from pathlib import Path


REQUIRED_SECTIONS = (
    "document-control",
    "source-ledger",
    "summary",
    "constitution",
    "users",
    "scope",
    "journeys",
    "functional-requirements",
    "scenarios",
    "edge-cases",
    "ux",
    "data",
    "security",
    "architecture",
    "stack-repo",
    "contracts",
    "quality",
    "analytics-observability",
    "testing",
    "delivery",
    "risks-decisions",
    "traceability",
    "readiness",
)

STATUS_TAGS = ("CONFIRMED", "INFERRED", "PROPOSED", "UNKNOWN", "CONFLICT")
FINAL_STATUSES = (
    "READY FOR IMPLEMENTATION",
    "READY WITH ASSUMPTIONS",
    "BLOCKED",
)
TRACEABLE_PREFIXES = ("FR", "NFR")
ID_PATTERN = re.compile(
    r"\b(FR|NFR|SCN|EDGE|S|G|J|D|A|Q|RISK|T|MET|BR|DATA|C)-(\d{3})\b"
)
VAGUE_TERMS = re.compile(
    r"\b(fast|quick|secure|scalable|robust|intuitive|user[- ]friendly|modern|"
    r"performant|reliable|accessible|schnell|sicher|skalierbar|robust|intuitiv|"
    r"benutzerfreundlich|modern|performant|zuverlässig|barrierefrei)\b",
    re.IGNORECASE,
)
PLACEHOLDERS = re.compile(
    r"<[A-Za-z][^>\n]{0,80}>|\b(?:TODO|TBD|FIXME|INSERT HERE|PLACEHOLDER)\b",
    re.IGNORECASE,
)


def extract_section(text: str, section: str) -> str:
    marker = f"<!-- prd-section:{section} -->"
    start = text.find(marker)
    if start < 0:
        return ""
    next_marker = text.find("<!-- prd-section:", start + len(marker))
    return text[start:] if next_marker < 0 else text[start:next_marker]


def add_duplicate_id_errors(text: str, errors: list[str]) -> None:
    definitions: Counter[str] = Counter()
    definition_patterns = (
        re.compile(r"^#{2,6}\s+((?:FR|NFR|SCN|EDGE|D|A|Q|RISK|T|MET)-\d{3})\b", re.MULTILINE),
        re.compile(r"^\|\s*((?:FR|NFR|SCN|EDGE|D|A|Q|RISK|T|MET)-\d{3})\s*\|", re.MULTILINE),
    )
    for pattern in definition_patterns:
        definitions.update(pattern.findall(text))
    duplicates = sorted(identifier for identifier, count in definitions.items() if count > 1)
    if duplicates:
        errors.append("Duplicate ID definitions: " + ", ".join(duplicates))


def validate(path: Path, strict: bool) -> int:
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        print(f"ERROR: cannot read {path}: {exc}")
        return 2

    errors: list[str] = []
    warnings: list[str] = []

    if not re.search(r"^#\s+\S", text, re.MULTILINE):
        errors.append("Missing level-1 document title.")

    missing_sections = [
        section
        for section in REQUIRED_SECTIONS
        if f"<!-- prd-section:{section} -->" not in text
    ]
    if missing_sections:
        errors.append("Missing required section markers: " + ", ".join(missing_sections))

    marker_counts = Counter(re.findall(r"<!-- prd-section:([a-z-]+) -->", text))
    repeated_markers = sorted(marker for marker, count in marker_counts.items() if count > 1)
    if repeated_markers:
        errors.append("Repeated section markers: " + ", ".join(repeated_markers))

    placeholders = sorted(set(PLACEHOLDERS.findall(text)))
    if placeholders:
        errors.append("Unresolved template placeholders: " + ", ".join(placeholders[:10]))

    if not any(f"[{tag}]" in text for tag in STATUS_TAGS):
        errors.append("No canonical evidence-status tags found.")

    final_hits = [status for status in FINAL_STATUSES if status in extract_section(text, "readiness")]
    if len(final_hits) != 1:
        errors.append(
            "Readiness section must contain exactly one final status; found: "
            + (", ".join(final_hits) if final_hits else "none")
        )

    all_ids = [f"{prefix}-{number}" for prefix, number in ID_PATTERN.findall(text)]
    id_counts = Counter(all_ids)
    for required_prefix in ("S", "FR", "NFR", "SCN", "EDGE"):
        if not any(identifier.startswith(required_prefix + "-") for identifier in all_ids):
            errors.append(f"No {required_prefix}-### IDs found.")

    traceability = extract_section(text, "traceability")
    for prefix in TRACEABLE_PREFIXES:
        identifiers = sorted(
            identifier for identifier in id_counts if identifier.startswith(prefix + "-")
        )
        missing_from_traceability = [
            identifier for identifier in identifiers if identifier not in traceability
        ]
        if missing_from_traceability:
            errors.append(
                f"{prefix} IDs missing from traceability section: "
                + ", ".join(missing_from_traceability)
            )

    scenarios = extract_section(text, "scenarios")
    for token in ("Given:", "When:", "Then:"):
        if token not in scenarios:
            errors.append(f"Acceptance scenarios contain no '{token}' steps.")

    add_duplicate_id_errors(text, errors)

    for line_number, line in enumerate(text.splitlines(), start=1):
        if re.search(r"\b(?:FR|NFR)-\d{3}\b", line) and VAGUE_TERMS.search(line):
            if not re.search(r"\d|≤|>=|<=|percentile|p\d{2}|WCAG|ASVS", line, re.IGNORECASE):
                warnings.append(
                    f"Line {line_number}: requirement may use an unmeasured vague term."
                )

    for identifier, count in sorted(id_counts.items()):
        if identifier.startswith(("FR-", "NFR-")) and count < 2:
            warnings.append(
                f"{identifier} appears only once; verify downstream scenario/test/trace links."
            )

    unknown_count = text.count("[UNKNOWN]")
    conflict_count = text.count("[CONFLICT]")
    if "READY FOR IMPLEMENTATION" in final_hits and (unknown_count or conflict_count):
        warnings.append(
            "READY FOR IMPLEMENTATION is used despite "
            f"{unknown_count} [UNKNOWN] and {conflict_count} [CONFLICT] markers."
        )

    print(f"PRD validation: {path}")
    print(f"Sections: {len(marker_counts)}/{len(REQUIRED_SECTIONS)} required markers")
    print(f"IDs: {len(id_counts)} unique identifiers")
    print(f"Open markers: {unknown_count} unknown, {conflict_count} conflict")

    for message in errors:
        print(f"ERROR: {message}")
    for message in warnings:
        print(f"WARNING: {message}")

    if errors:
        return 1
    if strict and warnings:
        return 1
    print("PASS" if not warnings else "PASS WITH WARNINGS")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate structure, IDs, traceability, and readiness of a Markdown PRD."
    )
    parser.add_argument("prd", type=Path, help="Path to the Markdown PRD")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat warnings as validation failures.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    return validate(args.prd, args.strict)


if __name__ == "__main__":
    sys.exit(main())
