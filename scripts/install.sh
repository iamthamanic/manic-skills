#!/usr/bin/env bash
# install.sh — expose skills to supported providers
# Local providers use symlinks. ChatGPT uses upload-ready ZIP exports.
# Supports: Cursor, Windsurf, pi.dev, Claude Code, ChatGPT
#
# Usage:
#   bash scripts/install.sh                    # install into Cursor (default, backwards compatible)
#   bash scripts/install.sh --cursor           # install only into Cursor
#   bash scripts/install.sh --windsurf         # install only into Windsurf
#   bash scripts/install.sh --pi               # install only into pi.dev
#   bash scripts/install.sh --claude           # install only into Claude Code
#   bash scripts/install.sh --chatgpt          # export ChatGPT upload packages
#   bash scripts/install.sh --all              # install/export for all five providers
#   bash scripts/install.sh --remove           # remove local symlinks + ChatGPT exports (all providers)
#   bash scripts/install.sh --remove --cursor  # remove only Cursor symlinks
#   bash scripts/install.sh --remove --chatgpt # remove only ChatGPT exports
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Local provider skill directories (global, machine-local)
CURSOR_DIR="$HOME/.cursor/skills"
WINDSURF_DIR="$HOME/.codeium/windsurf/skills"
PI_DIR="$HOME/.pi/agent/skills"
CLAUDE_DIR="$HOME/.claude/skills"
CHATGPT_OUTPUT="$REPO/dist/chatgpt"

# Defaults: install into Cursor only (backwards compatible)
INSTALL_CURSOR=1
INSTALL_WINDSURF=0
INSTALL_PI=0
INSTALL_CLAUDE=0
INSTALL_CHATGPT=0
MODE="install"

select_only() {
  INSTALL_CURSOR=0
  INSTALL_WINDSURF=0
  INSTALL_PI=0
  INSTALL_CLAUDE=0
  INSTALL_CHATGPT=0
  case "$1" in
    cursor) INSTALL_CURSOR=1 ;;
    windsurf) INSTALL_WINDSURF=1 ;;
    pi) INSTALL_PI=1 ;;
    claude) INSTALL_CLAUDE=1 ;;
    chatgpt) INSTALL_CHATGPT=1 ;;
  esac
}

# Parse args
for arg in "$@"; do
  case "$arg" in
    --cursor)   select_only cursor ;;
    --windsurf) select_only windsurf ;;
    --pi)       select_only pi ;;
    --claude)   select_only claude ;;
    --chatgpt)  select_only chatgpt ;;
    --all)
      INSTALL_CURSOR=1
      INSTALL_WINDSURF=1
      INSTALL_PI=1
      INSTALL_CLAUDE=1
      INSTALL_CHATGPT=1
      ;;
    --remove) MODE="remove" ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: bash install.sh [--cursor|--windsurf|--pi|--claude|--chatgpt|--all|--remove]"
      exit 1
      ;;
  esac
done

# Build local (tool_name, target_dir) pairs. ChatGPT is handled separately.
declare -a targets=()
if [[ $INSTALL_CURSOR -eq 1 ]]; then targets+=("cursor:$CURSOR_DIR"); fi
if [[ $INSTALL_WINDSURF -eq 1 ]]; then targets+=("windsurf:$WINDSURF_DIR"); fi
if [[ $INSTALL_PI -eq 1 ]]; then targets+=("pi:$PI_DIR"); fi
if [[ $INSTALL_CLAUDE -eq 1 ]]; then targets+=("claude:$CLAUDE_DIR"); fi

if [[ ${#targets[@]} -eq 0 && $INSTALL_CHATGPT -eq 0 ]]; then
  echo "No target selected. Use --cursor, --windsurf, --pi, --claude, --chatgpt, or --all."
  exit 1
fi

# Ensure local target dirs exist only during install mode.
if [[ "$MODE" == "install" ]]; then
  for entry in "${targets[@]}"; do
    target_dir="${entry#*:}"
    mkdir -p "$target_dir"
  done
fi

count_installed=0
count_skipped=0
count_removed=0

# Helper: install/remove a single skill into one local provider directory.
process_skill() {
  local skill_dir="$1"
  local target_dir="$2"
  local tool_name="$3"
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
          echo "  [$tool_name] removed $name"
          ((count_removed++))
          ;;
        *)
          echo "  [$tool_name] skip $name (symlink, but not pointing to this repo)"
          ;;
      esac
    elif [[ -e "$dest" ]]; then
      echo "  [$tool_name] skip $name (not a symlink)"
      ((count_skipped++))
    fi
    return
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  [$tool_name] skip $name (exists, not a symlink — back it up first: mv \"$dest\" \"$dest.bak\")"
    ((count_skipped++))
    return
  fi

  ln -sfn "$skill_dir" "$dest"
  echo "  [$tool_name] linked $name -> $skill_dir"
  ((count_installed++))
}

for skill_dir in "$REPO"/skills/*/; do
  [[ -d "$skill_dir" ]] || continue
  for entry in "${targets[@]}"; do
    tool_name="${entry%%:*}"
    target_dir="${entry#*:}"
    process_skill "$skill_dir" "$target_dir" "$tool_name"
  done
done

if [[ $INSTALL_CHATGPT -eq 1 ]]; then
  if [[ "$MODE" == "remove" ]]; then
    python3 "$REPO/scripts/chatgpt-provider.py" clean
  else
    python3 "$REPO/scripts/chatgpt-provider.py" export
  fi
fi

echo
if [[ "$MODE" == "remove" ]]; then
  echo "Done. Removed $count_removed local symlinks. Skipped $count_skipped."
  if [[ $INSTALL_CHATGPT -eq 1 ]]; then
    echo "ChatGPT export directory removed: $CHATGPT_OUTPUT"
  fi
else
  tools=""
  [[ $INSTALL_CURSOR -eq 1 ]] && tools="$tools cursor"
  [[ $INSTALL_WINDSURF -eq 1 ]] && tools="$tools windsurf"
  [[ $INSTALL_PI -eq 1 ]] && tools="$tools pi"
  [[ $INSTALL_CLAUDE -eq 1 ]] && tools="$tools claude"
  [[ $INSTALL_CHATGPT -eq 1 ]] && tools="$tools chatgpt"
  echo "Done. Local links: $count_installed. Providers:${tools}. Skipped $count_skipped."
  if [[ $INSTALL_CHATGPT -eq 1 ]]; then
    echo "ChatGPT packages: $CHATGPT_OUTPUT/<skill>/skill.zip"
  fi
  echo "Verify with: bash $REPO/scripts/verify.sh"
fi
