#!/usr/bin/env bash
# sync.sh — bidirektionaler Sync zwischen ~/.cursor/skills/ und dem Repo
# Usage:
#   bash scripts/sync.sh pull      # ~/.cursor/skills/ → repo (lokale Änderungen ins Repo holen)
#   bash scripts/sync.sh push      # repo → ~/.cursor/skills/ (Repo-Stand in Skills kopieren)
# Default: pull
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$HOME/.cursor/skills"
DIRECTION="${1:-pull}"

if [[ ! -d "$SOURCE" ]]; then
  echo "Error: $SOURCE does not exist. Run install.sh first."
  exit 1
fi

count=0

if [[ "$DIRECTION" == "pull" ]]; then
  # Kopiere alle Änderungen aus ~/.cursor/skills/ ins Repo
  for skill_dir in "$REPO"/skills/*/; do
    name="$(basename "$skill_dir")"
    src="$SOURCE/$name"
    if [[ -d "$src" ]]; then
      rsync -a --delete "$src/" "$skill_dir"
      echo "pulled $name"
      ((count++))
    else
      echo "skip $name (not in ~/.cursor/skills/)"
    fi
  done
  echo
  echo "Done. Pulled $count skills from $SOURCE → $REPO/skills/"
  echo "Now: cd $REPO && git diff   # review changes"
  echo "Then: git add -A && git commit -m 'sync skills' && git push"

elif [[ "$DIRECTION" == "push" ]]; then
  # Kopiere alle Änderungen aus dem Repo nach ~/.cursor/skills/
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
  echo "Usage: bash scripts/sync.sh [pull|push]"
  echo "  pull (default): ~/.cursor/skills/ → repo"
  echo "  push:           repo → ~/.cursor/skills/"
  exit 1
fi