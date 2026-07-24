#!/usr/bin/env bash
# If overview.mermaid differs from latest history snapshot, append a history entry.
# Usage: snapshot-architecture-history.sh [repo_root] [optional-slug]
set -euo pipefail

ROOT="${1:-}"
SLUG="${2:-architecture-update}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

MEM=".project-memory/architecture"
OVERVIEW="$MEM/overview.mermaid"
HIST="$MEM/history"
mkdir -p "$HIST"

[[ -f "$OVERVIEW" ]] || { echo "skip: no $OVERVIEW" >&2; exit 0; }

CURRENT="$(cat "$OVERVIEW")"
HASH="$(printf '%s' "$CURRENT" | shasum -a 256 | awk '{print $1}')"

# Compare to newest history file by date in filename
LATEST=""
if ls "$HIST"/*.json >/dev/null 2>&1; then
  LATEST="$(ls "$HIST"/*.json | sort | tail -1)"
fi

if [[ -n "$LATEST" ]]; then
  PREV_HASH="$(jq -r '.content_hash // empty' "$LATEST" 2>/dev/null || true)"
  if [[ -z "$PREV_HASH" ]]; then
    PREV_MD="$(jq -r '.mermaid // empty' "$LATEST")"
    PREV_HASH="$(printf '%s' "$PREV_MD" | shasum -a 256 | awk '{print $1}')"
  fi
  if [[ "$PREV_HASH" == "$HASH" ]]; then
    echo "architecture history: unchanged ($HASH)" >&2
    exit 0
  fi
fi

DATE="$(date -u +%Y-%m-%d)"
SHA="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
ID="${DATE}-${SLUG}"
OUT="$HIST/${ID}.json"

# Avoid clobber same-day same slug
if [[ -f "$OUT" ]]; then
  OUT="$HIST/${ID}-$(date -u +%H%M%S).json"
  ID="$(basename "$OUT" .json)"
fi

jq -n \
  --arg id "$ID" \
  --arg date "$DATE" \
  --arg commit "$SHA" \
  --arg mermaid "$CURRENT" \
  --arg hash "$HASH" \
  '{
    schema_version: 1,
    id: $id,
    date: $date,
    title: { de: "Architektur-Stand", en: "Architecture snapshot" },
    summary: {
      de: "Automatischer Snapshot von overview.mermaid",
      en: "Automatic snapshot of overview.mermaid"
    },
    commit: $commit,
    mermaid: $mermaid,
    content_hash: $hash,
    change_ids: [],
    review_status: "needs-review"
  }' >"$OUT"

echo "architecture history: wrote $OUT" >&2
