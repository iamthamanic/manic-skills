#!/usr/bin/env bash
# verify.sh — prüft, dass jeder Skill eine gültige SKILL.md mit Frontmatter hat
# und (wenn via install.sh installiert) die Symlinks funktionieren.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.cursor/skills"

errors=0
warnings=0
ok=0

echo "=== Verifying skills in repo ==="
for skill_dir in "$REPO"/skills/*/; do
  name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    echo "FAIL  $name — no SKILL.md"
    ((errors++))
    continue
  fi

  # Check frontmatter
  if ! head -1 "$skill_file" | grep -q '^---$'; then
    echo "FAIL  $name — SKILL.md does not start with frontmatter (---)"
    ((errors++))
    continue
  fi

  # Check required fields
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

echo
echo "=== Verifying installation (~/.cursor/skills/) ==="
if [[ -d "$TARGET" ]]; then
  installed=0
  broken=0
  for skill_dir in "$REPO"/skills/*/; do
    name="$(basename "$skill_dir")"
    dest="$TARGET/$name"
    if [[ -L "$dest" ]]; then
      if [[ -d "$dest" ]]; then
        ((installed++))
      else
        echo "BROKEN symlink  $name → $(readlink "$dest")"
        ((broken++))
      fi
    elif [[ -d "$dest" ]]; then
      echo "non-symlink      $name (Methode B/C — copy install)"
      ((installed++))
    else
      echo "missing          $name (nicht installiert — run install.sh)"
    fi
  done
  echo
  echo "Installed: $installed, broken symlinks: $broken"
else
  echo "$TARGET does not exist — skills not installed."
  echo "Run: bash $REPO/scripts/install.sh"
fi

echo
echo "Summary: $ok OK, $warnings warnings, $errors errors"

if [[ $errors -gt 0 ]]; then
  exit 1
fi
exit 0