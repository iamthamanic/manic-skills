#!/usr/bin/env bash
# Validate a single prompt file: frontmatter + slug filename
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: validate-prompt.sh <path-to-prompt.md>" >&2
  exit 1
fi

FILE="$1"
SLUG="$(basename "$FILE" .md)"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

if [[ ! "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: filename slug must be lowercase alphanumeric with hyphens: $SLUG" >&2
  exit 1
fi

if ! head -n 1 "$FILE" | grep -q '^---$'; then
  echo "ERROR: missing opening frontmatter ---" >&2
  exit 1
fi

for key in name description; do
  if ! awk -v k="$key" '
    /^---$/ { fm++; next }
    fm==1 && $0 ~ "^" k ":" { found=1; exit }
    END { exit(found ? 0 : 1) }
  ' "$FILE"; then
    echo "ERROR: missing frontmatter key: $key" >&2
    exit 1
  fi
done

BODY_LINES="$(awk '/^---$/{c++; next} c>=2' "$FILE" | wc -l | tr -d ' ')"
if [[ "$BODY_LINES" -lt 1 ]]; then
  echo "ERROR: prompt body is empty" >&2
  exit 1
fi

echo "OK: $SLUG"
