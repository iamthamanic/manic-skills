#!/usr/bin/env bash
# List saved prompts: ~/.cursor/prompts/ and optional workspace .cursor/prompts/
set -euo pipefail

GLOBAL_DIR="${CURSOR_PROMPTS_DIR:-$HOME/.cursor/prompts}"
WORKSPACE_ROOT="${1:-}"

print_dir() {
  local dir="$1"
  local scope="$2"
  [[ -d "$dir" ]] || return 0
  shopt -s nullglob
  local files=("$dir"/*.md "$dir"/personal/*.md)
  shopt -u nullglob
  for f in "${files[@]}"; do
    [[ "$(basename "$f")" == "README.md" ]] && continue
    local slug desc
    slug="$(basename "$f" .md)"
    desc="$(awk '
      /^---$/ { fm++; next }
      fm==1 && /^description:/ {
        sub(/^description:[[:space:]]*/, "")
        gsub(/^["'\'']|["'\'']$/, "")
        print
        exit
      }
    ' "$f")"
    printf "%-10s %-28s %-36s %s\n" "$scope" "$slug" "${desc:0:36}" "$f"
  done
}

printf "%-10s %-28s %-36s %s\n" "SCOPE" "SLUG" "DESCRIPTION" "PATH"
printf "%-10s %-28s %-36s %s\n" "-----" "----" "-----------" "----"

print_dir "$GLOBAL_DIR" "global"

if [[ -n "$WORKSPACE_ROOT" && -d "$WORKSPACE_ROOT/.cursor/prompts" ]]; then
  print_dir "$WORKSPACE_ROOT/.cursor/prompts" "project"
elif [[ -z "$WORKSPACE_ROOT" ]] && git rev-parse --show-toplevel &>/dev/null; then
  WORKSPACE_ROOT="$(git rev-parse --show-toplevel)"
  if [[ -d "$WORKSPACE_ROOT/.cursor/prompts" ]]; then
    print_dir "$WORKSPACE_ROOT/.cursor/prompts" "project"
  fi
fi
