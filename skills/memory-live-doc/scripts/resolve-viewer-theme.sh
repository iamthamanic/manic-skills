#!/usr/bin/env bash
# Resolve viewer theme → docs/memory-live-doc/viewer/data/theme.json
#
# Order:
#   1. locked theme.json (locked:true)
#   2. config.theme_id → skill assets/themes/<id>.json (explicit pin only)
#   3. extract-project-theme.py from project CSS / StyleGuide (generic)
#   4. assets/themes/default.json
#
# Usage: resolve-viewer-theme.sh [repo_root]
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="docs/memory-live-doc/viewer/data"
OUT="${OUT_DIR}/theme.json"
mkdir -p "$OUT_DIR"

THEME_ID=""
THEME_PREFER="auto"
if [[ -f .project-memory/config.json ]]; then
  THEME_ID="$(jq -r '.theme_id // empty' .project-memory/config.json 2>/dev/null || true)"
  THEME_PREFER="$(jq -r '.theme_prefer // "auto"' .project-memory/config.json 2>/dev/null || echo auto)"
fi

# Locked: existing theme with locked:true
if [[ -f "$OUT" ]]; then
  LOCKED="$(jq -r '.locked // false' "$OUT" 2>/dev/null || echo false)"
  if [[ "$LOCKED" == "true" ]]; then
    echo "theme: kept locked $OUT" >&2
    jq -n --argjson theme "$(cat "$OUT")" '{status:"locked",path:"'"$OUT"'",theme:$theme}'
    exit 0
  fi
fi

write_theme() {
  local src="$1"
  local from="$2"
  cp "$src" "$OUT"
  local tmp
  tmp="$(mktemp)"
  jq --arg src "$from" '.source = (.source // $src) | .id = (.id // "project-derived")' "$OUT" >"$tmp" && mv "$tmp" "$OUT"
  echo "theme: wrote $OUT from $from" >&2
  jq -n --arg path "$OUT" --arg from "$from" '{status:"resolved",path:$path,from:$from}'
}

# Explicit pin to a skill-shipped theme (optional override)
if [[ -n "$THEME_ID" && "$THEME_ID" != "project" && "$THEME_ID" != "auto" && -f "${SKILL_ROOT}/assets/themes/${THEME_ID}.json" ]]; then
  write_theme "${SKILL_ROOT}/assets/themes/${THEME_ID}.json" "${THEME_ID}.json"
  exit 0
fi

# Generic: derive from this repo's frontend / styleguide
EXTRACT_TMP="$(mktemp)"
set +e
python3 "${SKILL_ROOT}/scripts/extract-project-theme.py" "$ROOT" \
  --prefer "$THEME_PREFER" \
  --skill-root "$SKILL_ROOT" \
  >"$EXTRACT_TMP" 2>"${EXTRACT_TMP}.err"
EXTRACT_RC=$?
set -e
if [[ -s "${EXTRACT_TMP}.err" ]]; then
  cat "${EXTRACT_TMP}.err" >&2
fi

if [[ "$EXTRACT_RC" -eq 0 && -s "$EXTRACT_TMP" ]]; then
  mv "$EXTRACT_TMP" "$OUT"
  rm -f "${EXTRACT_TMP}.err"
  echo "theme: wrote $OUT (project-derived)" >&2
  jq -n --arg path "$OUT" --arg from "project-derived" '{status:"resolved",path:$path,from:$from}'
  exit 0
fi
rm -f "$EXTRACT_TMP" "${EXTRACT_TMP}.err"

# Fallback
write_theme "${SKILL_ROOT}/assets/themes/default.json" "default.json"
