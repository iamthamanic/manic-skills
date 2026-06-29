#!/usr/bin/env bash
# install.sh — symlink skills/ → tool skills directories
# Usage:
#   bash scripts/install.sh                  # install into Cursor (default)
#   bash scripts/install.sh --cursor         # install only into Cursor
#   bash scripts/install.sh --windsurf        # install only into Windsurf
#   bash scripts/install.sh --all             # install into both Cursor + Windsurf
#   bash scripts/install.sh --remove          # remove symlinks pointing to this repo (both tools)
#   bash scripts/install.sh --remove --cursor # remove only Cursor symlinks
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

CURSOR_DIR="$HOME/.cursor/skills"
WINDSURF_DIR="$HOME/.codeium/windsurf/skills"

# Defaults
INSTALL_CURSOR=1
INSTALL_WINDSURF=0
MODE="install"

# Parse args
for arg in "$@"; do
  case "$arg" in
    --cursor)  INSTALL_CURSOR=1; INSTALL_WINDSURF=0 ;;
    --windsurf) INSTALL_CURSOR=0; INSTALL_WINDSURF=1 ;;
    --all)     INSTALL_CURSOR=1; INSTALL_WINDSURF=1 ;;
    --remove)  MODE="remove" ;;
    *) echo "Unknown argument: $arg"; echo "Usage: bash install.sh [--cursor|--windsurf|--all|--remove]"; exit 1 ;;
  esac
done

# Build list of target directories
targets=()
if [[ $INSTALL_CURSOR -eq 1 ]]; then
  targets+=("$CURSOR_DIR")
fi
if [[ $INSTALL_WINDSURF -eq 1 ]]; then
  targets+=("$WINDSURF_DIR")
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "No target selected. Use --cursor, --windsurf, or --all."
  exit 1
fi

# Ensure target dirs exist
for t in "${targets[@]}"; do
  mkdir -p "$t"
done

count_installed=0
count_skipped=0
count_removed=0

# Helper: install/remove a single skill into one target dir
process_skill() {
  local skill_dir="$1"
  local target_dir="$2"
  local name
  name="$(basename "$skill_dir")"
  local dest="$target_dir/$name"

  if [[ "$MODE" == "remove" ]]; then
    if [[ -L "$dest" ]]; then
      local link_target
      link_target="$(readlink "$dest")"
      case "$link_target" in
        "$skill_dir"|"$REPO"/skills/"$name")
          rm "$dest"
          echo "  removed $name"
          ((count_removed++))
          ;;
        *)
          echo "  skip $name (symlink, but not pointing to this repo)"
          ;;
      esac
    else
      echo "  skip $name (not a symlink)"
    fi
    return
  fi

  # install mode
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  skip $name (exists, not a symlink — back it up first: mv \"$dest\" \"$dest.bak\")"
    ((count_skipped++))
    return
  fi

  ln -sfn "$skill_dir" "$dest"
  echo "  linked $name → $skill_dir"
  ((count_installed++))
}

for skill_dir in "$REPO"/skills/*/; do
  name="$(basename "$skill_dir")"
  for target_dir in "${targets[@]}"; do
    tool_name="cursor"
    case "$target_dir" in
      *".codeium/windsurf"*) tool_name="windsurf" ;;
    esac
    echo "[$tool_name] $name"
    process_skill "$skill_dir" "$target_dir"
  done
done

echo
if [[ "$MODE" == "remove" ]]; then
  echo "Done. Removed $count_removed symlinks. Skipped $count_skipped."
else
  tools=""
  [[ $INSTALL_CURSOR -eq 1 ]] && tools="cursor"
  [[ $INSTALL_WINDSURF -eq 1 ]] && tools="$tools windsurf"
  echo "Done. Linked $count_installed skill-symlinks across: ${tools# }. Skipped $count_skipped."
  echo "Verify with: bash $REPO/scripts/verify.sh"
fi