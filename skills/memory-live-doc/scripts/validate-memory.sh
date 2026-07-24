#!/usr/bin/env bash
# validate-memory.sh — basic .project-memory health checks for memory-live-doc.
# Usage: validate-memory.sh [repo_root]
# Exit 0 = ok (warnings allowed); exit 1 = hard failure.
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

MEM=".project-memory"
fail=0
warn=0

say() { printf '%s\n' "$*"; }
fail_msg() { say "FAIL: $*"; fail=1; }
warn_msg() { say "WARN: $*"; warn=$((warn + 1)); }

if [[ ! -d "$MEM" ]]; then
  fail_msg "missing $MEM/ (not initialized)"
  exit 1
fi

for f in config.json checkpoint.json project.json current-state.json; do
  if [[ ! -f "$MEM/$f" ]]; then
    fail_msg "missing $MEM/$f"
  fi
done

EXPECTED_SCHEMA=1
if [[ -f "$MEM/config.json" ]]; then
  ver="$(sed -n 's/.*"schema_version"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$MEM/config.json" | head -n1)"
  if [[ -z "$ver" ]]; then
    fail_msg "config.json missing schema_version"
  elif [[ "$ver" != "$EXPECTED_SCHEMA" ]]; then
    fail_msg "schema_version mismatch: got $ver expected $EXPECTED_SCHEMA"
  else
    say "OK: schema_version=$ver"
  fi
fi

if [[ -f "$MEM/checkpoint.json" ]]; then
  sha="$(sed -n 's/.*"last_processed_commit"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MEM/checkpoint.json" | head -n1)"
  if [[ -z "$sha" ]]; then
    fail_msg "checkpoint.json missing last_processed_commit"
  elif ! git cat-file -e "${sha}^{commit}" 2>/dev/null; then
    warn_msg "checkpoint commit not found locally: $sha"
  else
    say "OK: checkpoint=$sha"
  fi
fi

needs=0
if [[ -d "$MEM/changes" ]]; then
  while IFS= read -r file; do
    if grep -q '"needs-review"' "$file" 2>/dev/null; then
      needs=$((needs + 1))
    fi
  done < <(find "$MEM/changes" -type f -name '*.json' 2>/dev/null || true)
fi
if [[ -d "$MEM/features" ]]; then
  while IFS= read -r file; do
    if grep -q '"needs-review"' "$file" 2>/dev/null; then
      needs=$((needs + 1))
    fi
  done < <(find "$MEM/features" -type f -name '*.json' 2>/dev/null || true)
fi
say "needs-review_count=${needs}"
if [[ "$needs" -gt 0 ]]; then
  warn_msg "$needs file(s) still needs-review"
fi

if [[ ! -d docs/memory-live-doc/viewer/data ]]; then
  warn_msg "viewer data snapshot missing (docs/memory-live-doc/viewer/data)"
else
  for f in project.json features.json changes.json current-state.json; do
    if [[ ! -f "docs/memory-live-doc/viewer/data/$f" ]]; then
      warn_msg "viewer missing data/$f"
    fi
  done
  if [[ ! -f docs/memory-live-doc/viewer/data/architecture.json ]]; then
    warn_msg "viewer missing data/architecture.json (Architecture tab)"
  fi
  if [[ ! -f docs/memory-live-doc/viewer/data/architecture-history.json ]]; then
    warn_msg "viewer missing data/architecture-history.json (date filter)"
  fi
  if [[ ! -f docs/memory-live-doc/viewer/data/theme.json ]]; then
    warn_msg "viewer missing data/theme.json (run resolve-viewer-theme / export-viewer-snapshot)"
  fi
fi

# History coverage (mature repos should not stay on thin timelines)
if [[ -x "$(command -v bash)" ]] && [[ -f "${BASH_SOURCE[0]%/*}/detect-history-coverage.sh" ]]; then
  det="$(bash "${BASH_SOURCE[0]%/*}/detect-history-coverage.sh" "$ROOT" 2>/dev/null | tail -n1 || true)"
  if [[ -n "$det" ]]; then
    action="$(printf '%s' "$det" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("history_action",""))' 2>/dev/null || true)"
    say "history_action=${action:-unknown}"
    if [[ "$action" == "required" ]]; then
      warn_msg "history backfill required (run analyze-git-history.sh + history-backfill)"
    elif [[ "$action" == "recommended" ]]; then
      warn_msg "history backfill recommended"
    fi
  fi
fi

say "warnings=${warn}"
if [[ "$fail" -ne 0 ]]; then
  say "RESULT=FAIL"
  exit 1
fi
say "RESULT=OK"
exit 0
