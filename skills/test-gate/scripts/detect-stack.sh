#!/usr/bin/env bash
# Detect stack signals for @test-gate. Prints KEY=value lines (stdout).
# Usage: bash detect-stack.sh [repo-root]
set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

has() { [[ -e "$1" ]] || [[ -e "$2" ]]; }
pkg_has() {
  local pat="$1"
  # Any package.json in repo (monorepo-safe)
  if command -v rg >/dev/null 2>&1; then
    rg -l --glob 'package.json' --glob '!**/node_modules/**' "$pat" . 2>/dev/null | head -1 | grep -q .
  else
    grep -R --include='package.json' -l "$pat" . 2>/dev/null | grep -v node_modules | head -1 | grep -q .
  fi
}

HAS_NEXT=0
HAS_VITE=0
HAS_PRISMA=0
HAS_DENO=0
HAS_PYTHON=0
HAS_FRONTEND_DIR=0
HAS_BACKEND_DIR=0
HAS_WORKSPACES=0
HAS_PRETTIER=0
HAS_ESLINT=0
HAS_CHECKS_CMD=0

[[ -f next.config.js || -f next.config.mjs || -f next.config.ts ]] && HAS_NEXT=1
pkg_has '"next"' && HAS_NEXT=1

[[ -f vite.config.ts || -f vite.config.js || -f vite.config.mjs ]] && HAS_VITE=1
pkg_has '"vite"' && HAS_VITE=1

[[ -f prisma/schema.prisma || -f backend/prisma/schema.prisma ]] && HAS_PRISMA=1

[[ -f deno.json || -f deno.jsonc ]] && HAS_DENO=1
[[ -d supabase/functions ]] && HAS_DENO=1

[[ -f pyproject.toml || -f requirements.txt || -f ruff.toml ]] && HAS_PYTHON=1

[[ -d frontend || -d apps/web ]] && HAS_FRONTEND_DIR=1
[[ -d backend || -d apps/api || -d server ]] && HAS_BACKEND_DIR=1

rg -q '"workspaces"' package.json 2>/dev/null && HAS_WORKSPACES=1

[[ -f .prettierrc || -f .prettierrc.js || -f .prettierrc.cjs || -f prettier.config.js ]] && HAS_PRETTIER=1
[[ -f eslint.config.js || -f eslint.config.mjs || -f .eslintrc.js || -f .eslintrc.cjs || -f .eslintrc.json ]] && HAS_ESLINT=1
[[ -f biome.json || -f biome.jsonc ]] && HAS_ESLINT=1

if [[ -f .qa/project.yaml ]]; then
  rg -q 'checksCommand:' .qa/project.yaml 2>/dev/null && HAS_CHECKS_CMD=1
fi
rg -q '"checks"|"verify"' package.json 2>/dev/null && HAS_CHECKS_CMD=1

PROFILE="unknown"
if [[ "$HAS_WORKSPACES" -eq 1 || ( "$HAS_FRONTEND_DIR" -eq 1 && "$HAS_BACKEND_DIR" -eq 1 ) ]]; then
  PROFILE="monorepo"
elif [[ "$HAS_NEXT" -eq 1 ]]; then
  PROFILE="next"
elif [[ "$HAS_VITE" -eq 1 ]]; then
  PROFILE="vite-react"
elif [[ "$HAS_DENO" -eq 1 && "$HAS_FRONTEND_DIR" -eq 0 ]]; then
  PROFILE="deno-supabase"
elif [[ "$HAS_PYTHON" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ]]; then
  PROFILE="python-api"
elif [[ "$HAS_PRISMA" -eq 1 ]]; then
  PROFILE="express-prisma"
elif [[ "$HAS_FRONTEND_DIR" -eq 0 ]]; then
  PROFILE="api-only"
fi

# Browo-style layout heuristic
if [[ -d frontend && -d backend && -f backend/prisma/schema.prisma ]]; then
  PROFILE="monorepo"
  echo "HINT=browo-hr-like"
fi

echo "ROOT=$ROOT"
echo "PROFILE=$PROFILE"
echo "HAS_NEXT=$HAS_NEXT"
echo "HAS_VITE=$HAS_VITE"
echo "HAS_PRISMA=$HAS_PRISMA"
echo "HAS_DENO=$HAS_DENO"
echo "HAS_PYTHON=$HAS_PYTHON"
echo "HAS_FRONTEND_DIR=$HAS_FRONTEND_DIR"
echo "HAS_BACKEND_DIR=$HAS_BACKEND_DIR"
echo "HAS_WORKSPACES=$HAS_WORKSPACES"
echo "HAS_PRETTIER=$HAS_PRETTIER"
echo "HAS_ESLINT=$HAS_ESLINT"
echo "HAS_CHECKS_CMD=$HAS_CHECKS_CMD"
