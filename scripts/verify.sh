#!/usr/bin/env bash
# verify.sh — validate shared skills, local provider installs, and ChatGPT exportability.
# Supports: Cursor, Windsurf, pi.dev, Claude Code, ChatGPT
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

CURSOR_DIR="$HOME/.cursor/skills"
WINDSURF_DIR="$HOME/.codeium/windsurf/skills"
PI_DIR="$HOME/.pi/agent/skills"
CLAUDE_DIR="$HOME/.claude/skills"

errors=0
warnings=0
ok=0

echo "=== Verifying skills in repo ==="
for skill_dir in "$REPO"/skills/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    echo "FAIL  $name — no SKILL.md"
    ((errors++))
    continue
  fi

  if ! head -1 "$skill_file" | grep -q '^---$'; then
    echo "FAIL  $name — SKILL.md does not start with frontmatter (---)"
    ((errors++))
    continue
  fi

  has_name=0
  has_desc=0
  while IFS= read -r line; do
    case "$line" in
      '---') break ;;
      name:*) has_name=1 ;;
      description:*) has_desc=1 ;;
    esac
  done < <(tail -n +2 "$skill_file")

  if [[ $has_name -eq 0 ]]; then
    echo "FAIL  $name — missing 'name:' in frontmatter"
    ((errors++))
    continue
  fi
  if [[ $has_desc -eq 0 ]]; then
    echo "WARN  $name — missing 'description:' in frontmatter"
    ((warnings++))
  fi

  echo "OK    $name"
  ((ok++))
done

verify_tool() {
  local tool_name="$1"
  local target_dir="$2"
  echo
  echo "=== Verifying installation ($tool_name: $target_dir) ==="
  if [[ ! -d "$target_dir" ]]; then
    echo "$target_dir does not exist — skills not installed for $tool_name."
    echo "Run: bash $REPO/scripts/install.sh --$tool_name"
    return
  fi
  local installed=0
  local broken=0
  for skill_dir in "$REPO"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    name="$(basename "$skill_dir")"
    dest="$target_dir/$name"
    if [[ -L "$dest" ]]; then
      if [[ -d "$dest" ]]; then
        ((installed++))
      else
        echo "BROKEN symlink  $name -> $(readlink "$dest")"
        ((broken++))
      fi
    elif [[ -d "$dest" ]]; then
      echo "non-symlink      $name (copy install)"
      ((installed++))
    else
      echo "missing          $name (not installed — run install.sh --$tool_name)"
    fi
  done
  echo
  echo "$tool_name installed: $installed, broken symlinks: $broken"
  if [[ $broken -gt 0 ]]; then
    errors=$((errors + broken))
  fi
}

verify_tool "cursor" "$CURSOR_DIR"
verify_tool "windsurf" "$WINDSURF_DIR"
verify_tool "pi" "$PI_DIR"
verify_tool "claude" "$CLAUDE_DIR"

echo
echo "=== Verifying ChatGPT provider exportability ==="
if python3 "$REPO/scripts/chatgpt-provider.py" verify; then
  echo "ChatGPT provider verification: PASS"
else
  echo "ChatGPT provider verification: FAIL"
  errors=$((errors + 1))
fi

echo
echo "Summary: $ok OK, $warnings warnings, $errors errors"

if [[ $errors -gt 0 ]]; then
  exit 1
fi
exit 0
