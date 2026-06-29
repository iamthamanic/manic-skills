#!/usr/bin/env bash
# install.sh — symlink skills/ → ~/.cursor/skills/
# Usage:
#   bash scripts/install.sh            # install/update symlinks
#   bash scripts/install.sh --remove    # remove symlinks pointing to this repo
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.cursor/skills"
MODE="install"

if [[ "${1:-}" == "--remove" ]]; then
  MODE="remove"
fi

mkdir -p "$TARGET"

count_installed=0
count_skipped=0
count_removed=0

for skill_dir in "$REPO"/skills/*/; do
  name="$(basename "$skill_dir")"
  dest="$TARGET/$name"

  if [[ "$MODE" == "remove" ]]; then
    if [[ -L "$dest" ]]; then
      link_target="$(readlink "$dest")"
      case "$link_target" in
        "$skill_dir"|"$REPO"/skills/"$name")
          rm "$dest"
          echo "removed $name"
          ((count_removed++))
          ;;
        *)
          echo "skip $name (symlink, but not pointing to this repo)"
          ;;
      esac
    else
      echo "skip $name (not a symlink)"
    fi
    continue
  fi

  # install mode
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "skip $name (exists, not a symlink — back it up first: mv \"$dest\" \"$dest.bak\")"
    ((count_skipped++))
    continue
  fi

  ln -sfn "$skill_dir" "$dest"
  echo "linked $name → $skill_dir"
  ((count_installed++))
done

if [[ "$MODE" == "remove" ]]; then
  echo
  echo "Done. Removed $count_removed symlinks. Skipped $count_skipped."
else
  echo
  echo "Done. Linked $count_installed skills. Skipped $count_skipped."
  echo "Verify with: bash $REPO/scripts/verify.sh"
fi