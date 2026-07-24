#!/usr/bin/env bash
# sync.sh — bidirektionaler Sync zwischen Tool-Skill-Verzeichnissen und dem Repo
# Supports: Cursor, Windsurf, pi.dev, Claude Code
#
# Usage:
#   bash scripts/sync.sh pull                  # ~/.cursor/skills/ → repo (default, Cursor)
#   bash scripts/sync.sh pull --cursor          # ~/.cursor/skills/ → repo
#   bash scripts/sync.sh pull --windsurf        # ~/.codeium/windsurf/skills/ → repo
#   bash scripts/sync.sh pull --pi              # ~/.pi/agent/skills/ → repo
#   bash scripts/sync.sh pull --claude          # ~/.claude/skills/ → repo
#   bash scripts/sync.sh push                   # repo → ~/.cursor/skills/ (default, Cursor)
#   bash scripts/sync.sh push --windsurf        # repo → ~/.codeium/windsurf/skills/
#   bash scripts/sync.sh push --pi              # repo → ~/.pi/agent/skills/
#   bash scripts/sync.sh push --claude          # repo → ~/.claude/skills/
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

DIRECTION="${1:-pull}"
TOOL="${2:---cursor}"

case "$TOOL" in
  --cursor)   SOURCE="$HOME/.cursor/skills" ;;
  --windsurf) SOURCE="$HOME/.codeium/windsurf/skills" ;;
  --pi)       SOURCE="$HOME/.pi/agent/skills" ;;
  --claude)   SOURCE="$HOME/.claude/skills" ;;
  *) echo "Unknown tool: $TOOL"; echo "Usage: bash scripts/sync.sh [pull|push] [--cursor|--windsurf|--pi|--claude]"; exit 1 ;;
esac

if [[ ! -d "$SOURCE" ]]; then
  echo "Error: $SOURCE does not exist. Run install.sh first."
  exit 1
fi

count=0

if [[ "$DIRECTION" == "pull" ]]; then
  # Alle Skills aus $SOURCE ins Repo (inkl. neu hinzugekommene)
  shopt -s nullglob
  for src in "$SOURCE"/*/; do
    name="$(basename "$src")"
    # Skip non-skill noise
    [[ "$name" == .* ]] && continue
    [[ -f "$src/SKILL.md" ]] || { echo "skip $name (no SKILL.md)"; continue; }
    dest="$REPO/skills/$name"
    mkdir -p "$dest"
    rsync -a --delete --exclude '.DS_Store' "$src" "$dest/"
    echo "pulled $name"
    ((count++)) || true
  done
  echo
  echo "Done. Pulled $count skills from $SOURCE → $REPO/skills/"
  echo "Now: cd $REPO && git diff   # review changes"
  echo "Then: git add -A && git commit -m 'sync skills' && git push"

elif [[ "$DIRECTION" == "push" ]]; then
  # Kopiere alle Änderungen aus dem Repo nach $SOURCE
  for skill_dir in "$REPO"/skills/*/; do
    name="$(basename "$skill_dir")"
    dest="$SOURCE/$name"
    if [[ -L "$dest" ]]; then
      echo "skip $name (symlink — already in sync)"
      continue
    fi
    mkdir -p "$dest"
    rsync -a --delete "$skill_dir" "$dest"
    echo "pushed $name"
    ((count++))
  done
  echo
  echo "Done. Pushed $count skills from $REPO/skills/ → $SOURCE"

else
  echo "Usage: bash scripts/sync.sh [pull|push] [--cursor|--windsurf|--pi|--claude]"
  echo "  pull (default): tool skills dir → repo"
  echo "  push:           repo → tool skills dir"
  echo "  --cursor (default):  ~/.cursor/skills/"
  echo "  --windsurf:          ~/.codeium/windsurf/skills/"
  echo "  --pi:                ~/.pi/agent/skills/"
  echo "  --claude:            ~/.claude/skills/"
  exit 1
fi