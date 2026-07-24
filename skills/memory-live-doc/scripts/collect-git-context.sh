#!/usr/bin/env bash
# collect-git-context.sh — deterministic git context for memory-live-doc (no network).
# Usage:
#   collect-git-context.sh [base_sha]
# If base_sha omitted, uses .project-memory/checkpoint.json last_processed_commit when present,
# else merge-base with origin/main|origin/master|main|master, else empty tree.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${ROOT}" ]]; then
  echo '{"error":"not a git repository"}' >&2
  exit 1
fi
cd "$ROOT"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
head="$(git rev-parse HEAD 2>/dev/null || echo "")"
dirty=false
if [[ -n "$(git status --porcelain 2>/dev/null || true)" ]]; then
  dirty=true
fi

base_arg="${1:-}"
base=""
base_source=""

if [[ -n "$base_arg" ]]; then
  base="$base_arg"
  base_source="arg"
elif [[ -f .project-memory/checkpoint.json ]]; then
  base="$(sed -n 's/.*"last_processed_commit"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .project-memory/checkpoint.json | head -n1)"
  if [[ -n "$base" ]] && git cat-file -e "${base}^{commit}" 2>/dev/null; then
    base_source="checkpoint"
  else
    base=""
  fi
fi

if [[ -z "$base" ]]; then
  for ref in origin/main origin/master main master; do
    if git rev-parse --verify "$ref" >/dev/null 2>&1; then
      base="$(git merge-base "$ref" HEAD 2>/dev/null || true)"
      if [[ -n "$base" ]]; then
        base_source="merge-base:$ref"
        break
      fi
    fi
  done
fi

if [[ -z "$base" ]]; then
  base="$(git hash-object -t tree /dev/null)"
  base_source="empty-tree"
fi

# Changed files: committed range + working tree when dirty
mapfile_files=()
while IFS= read -r line; do
  [[ -n "$line" ]] && mapfile_files+=("$line")
done < <(git diff --name-only "$base" HEAD 2>/dev/null || true)

if [[ "$dirty" == true ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && mapfile_files+=("$line")
  done < <(git diff --name-only HEAD 2>/dev/null || true)
  while IFS= read -r line; do
    [[ -n "$line" ]] && mapfile_files+=("$line")
  done < <(git diff --name-only --cached 2>/dev/null || true)
  while IFS= read -r line; do
    [[ -n "$line" ]] && mapfile_files+=("$line")
  done < <(git ls-files --others --exclude-standard 2>/dev/null || true)
fi

# Unique files
uniq_files=()
if ((${#mapfile_files[@]} > 0)); then
  while IFS= read -r line; do
    [[ -n "$line" ]] && uniq_files+=("$line")
  done < <(printf '%s\n' "${mapfile_files[@]}" | awk 'NF && !seen[$0]++')
fi

numstat="$(git diff --numstat "$base" HEAD 2>/dev/null || true)"
if [[ "$dirty" == true ]]; then
  numstat+=$'\n'"$(git diff --numstat HEAD 2>/dev/null || true)"
  numstat+=$'\n'"$(git diff --numstat --cached 2>/dev/null || true)"
fi

# Emit shell-friendly + JSON-ish (jq not required)
echo "branch=${branch}"
echo "base=${base}"
echo "base_source=${base_source}"
echo "head=${head}"
echo "dirty=${dirty}"
echo "changed_count=${#uniq_files[@]}"
echo "changed_files<<EOF"
printf '%s\n' "${uniq_files[@]:-}"
echo "EOF"
echo "numstat<<EOF"
printf '%s\n' "$numstat"
echo "EOF"

# Compact JSON object (escape minimal)
json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

echo -n '{"branch":"'"$(json_escape "$branch")"'","base":"'"$(json_escape "$base")"'","base_source":"'"$(json_escape "$base_source")"'","head":"'"$(json_escape "$head")"'","dirty":'"$dirty"',"changed_files":['
first=1
for f in "${uniq_files[@]:-}"; do
  [[ -z "$f" ]] && continue
  if [[ $first -eq 1 ]]; then first=0; else printf ','; fi
  printf '"%s"' "$(json_escape "$f")"
done
echo ']}'
