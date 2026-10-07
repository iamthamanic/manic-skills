#!/usr/bin/env python3
"""Deterministic percentile summary for performance timing samples.

Purpose: give agents reproducible p50/p95/p99 (and related stats) from JSON
without inventing numbers. Location: test-performance-speed/scripts/.

Input formats (file path or stdin):
  1) Flat list of numbers: [120, 140, 135, ...]
  2) Object with "samples" list of numbers
  3) Object with "samples" list of objects:
       { "ms": 120, "ok": true, "label": "optional", "profile": "optional" }
  4) Object keyed by interaction name → list/object as above

Usage:
  python3 summarize_timings.py samples.json
  python3 summarize_timings.py samples.json --group-by profile
  cat samples.json | python3 summarize_timings.py -
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import defaultdict
from typing import Any


def percentile(sorted_vals: list[float], p: float) -> float | None:
    if not sorted_vals:
        return None
    if len(sorted_vals) == 1:
        return float(sorted_vals[0])
    # Nearest-rank (inclusive), common for latency reporting
    rank = max(1, math.ceil(p / 100.0 * len(sorted_vals)))
    return float(sorted_vals[rank - 1])


def extract_ms(item: Any) -> tuple[float | None, bool]:
    if isinstance(item, (int, float)) and not isinstance(item, bool):
        return float(item), True
    if isinstance(item, dict):
        for key in ("ms", "duration_ms", "duration", "value"):
            if key in item and isinstance(item[key], (int, float)):
                ok = item.get("ok", item.get("success", True))
                return float(item[key]), bool(ok)
    return None, False


def normalize_groups(data: Any, group_by: str | None) -> dict[str, list[tuple[float, bool]]]:
    groups: dict[str, list[tuple[float, bool]]] = defaultdict(list)

    def ingest(name: str, payload: Any) -> None:
        if isinstance(payload, list):
            for item in payload:
                ms, ok = extract_ms(item)
                if ms is None:
                    continue
                key = name
                if group_by and isinstance(item, dict) and group_by in item:
                    key = f"{name}|{group_by}={item[group_by]}"
                groups[key].append((ms, ok))
        elif isinstance(payload, dict) and "samples" in payload:
            ingest(name, payload["samples"])
        else:
            ms, ok = extract_ms(payload)
            if ms is not None:
                groups[name].append((ms, ok))

    if isinstance(data, list):
        ingest("default", data)
    elif isinstance(data, dict):
        if "samples" in data:
            ingest(str(data.get("name") or data.get("interaction") or "default"), data)
        else:
            for key, value in data.items():
                if key.startswith("_"):
                    continue
                ingest(str(key), value)
    else:
        raise SystemExit("Unsupported JSON: expected list or object")

    return dict(groups)


def summarize(samples: list[tuple[float, bool]]) -> dict[str, Any]:
    oks = [ms for ms, ok in samples if ok]
    errs = sum(1 for _, ok in samples if not ok)
    sorted_ok = sorted(oks)
    n = len(sorted_ok)
    p99_ok = n >= 20
    p95_ok = n >= 10
    out: dict[str, Any] = {
        "n_total": len(samples),
        "n_ok": n,
        "n_error": errs,
        "error_rate": (errs / len(samples)) if samples else None,
        "min_ms": sorted_ok[0] if n else None,
        "max_ms": sorted_ok[-1] if n else None,
        "mean_ms": (sum(sorted_ok) / n) if n else None,
        "p50_ms": percentile(sorted_ok, 50),
        "p95_ms": percentile(sorted_ok, 95) if p95_ok else None,
        "p99_ms": percentile(sorted_ok, 99) if p99_ok else None,
        "percentile_notes": [],
    }
    if not p95_ok:
        out["percentile_notes"].append(
            f"p95 omitted: n_ok={n} < 10 (insufficient for serious percentile claim)"
        )
    if not p99_ok:
        out["percentile_notes"].append(
            f"p99 omitted: n_ok={n} < 20 (insufficient for serious percentile claim)"
        )
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="JSON file path, or - for stdin")
    parser.add_argument("--group-by", default=None, help="Field on sample objects to subgroup")
    parser.add_argument("--pretty", action="store_true", default=True)
    args = parser.parse_args()

    raw = sys.stdin.read() if args.path == "-" else open(args.path, encoding="utf-8").read()
    data = json.loads(raw)
    groups = normalize_groups(data, args.group_by)
    report = {name: summarize(samples) for name, samples in sorted(groups.items())}

    if len(report) == 1 and "default" in report:
        payload: Any = report["default"]
    else:
        payload = report

    print(json.dumps(payload, indent=2 if args.pretty else None, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
