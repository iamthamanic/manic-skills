#!/usr/bin/env bash
# Detect stack signals for @test-gate. Prints KEY=value lines (stdout).
# Usage: bash detect-stack.sh [repo-root]
set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

pkg_has() {
  local pat="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -l --glob 'package.json' --glob '!**/node_modules/**' "$pat" . 2>/dev/null | head -1 | grep -q .
  else
    grep -R --include='package.json' -l "$pat" . 2>/dev/null | grep -v node_modules | head -1 | grep -q .
  fi
}

script_has() {
  # package.json scripts key, e.g. "lint"
  local key="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -q --glob 'package.json' --glob '!**/node_modules/**' "\"$key\"\\s*:" . 2>/dev/null
  else
    grep -R --include='package.json' -l "\"$key\"" . 2>/dev/null | grep -v node_modules | head -1 | grep -q .
  fi
}

HAS_NEXT=0
HAS_VITE=0
HAS_PRISMA=0
HAS_DENO=0
HAS_PYTHON=0
HAS_GO=0
HAS_RUST=0
HAS_SWIFT=0
HAS_KOTLIN=0
HAS_TS=0
HAS_JS_PKG=0
HAS_FRONTEND_DIR=0
HAS_BACKEND_DIR=0
HAS_WORKSPACES=0
HAS_PRETTIER=0
HAS_ESLINT=0
HAS_BIOME=0
HAS_OXLINT=0
HAS_LINT=0
HAS_TYPECHECK=0
HAS_CHECKS_CMD=0
HAS_TSCONFIG=0

[[ -f next.config.js || -f next.config.mjs || -f next.config.ts ]] && HAS_NEXT=1
pkg_has '"next"' && HAS_NEXT=1

[[ -f vite.config.ts || -f vite.config.js || -f vite.config.mjs || -f vite.config.mts ]] && HAS_VITE=1
pkg_has '"vite"' && HAS_VITE=1

[[ -f prisma/schema.prisma || -f backend/prisma/schema.prisma ]] && HAS_PRISMA=1

HAS_SUPABASE_FN=0
[[ -f deno.json || -f deno.jsonc ]] && HAS_DENO=1
[[ -d supabase/functions ]] && HAS_SUPABASE_FN=1 && HAS_DENO=1

[[ -f pyproject.toml || -f requirements.txt || -f ruff.toml ]] && HAS_PYTHON=1
[[ -f go.mod ]] && HAS_GO=1
[[ -f Cargo.toml ]] && HAS_RUST=1
[[ -f Package.swift ]] && HAS_SWIFT=1
compgen -G '*.xcodeproj' >/dev/null 2>&1 && HAS_SWIFT=1
compgen -G '*.xcworkspace' >/dev/null 2>&1 && HAS_SWIFT=1
{ [[ -f build.gradle || -f build.gradle.kts ]] || [[ -f android/build.gradle || -f android/build.gradle.kts ]]; } && HAS_KOTLIN=1
# Prefer shallow gradle markers; avoid scanning huge trees
[[ -f settings.gradle || -f settings.gradle.kts ]] && HAS_KOTLIN=1

[[ -f package.json ]] && HAS_JS_PKG=1
# tsconfig at repo root or one level down (exclude node_modules)
if compgen -G 'tsconfig*.json' >/dev/null 2>&1 \
  || compgen -G '*/tsconfig*.json' >/dev/null 2>&1; then
  # Ignore if the only hits are under node_modules (glob */ won't match node_modules/pkg at depth 1 for tsconfig name at pkg root — still check)
  if command -v rg >/dev/null 2>&1; then
    rg -l --glob 'tsconfig*.json' --glob '!**/node_modules/**' --glob '!**/.git/**' . 2>/dev/null | head -1 | grep -q . \
      && HAS_TSCONFIG=1 && HAS_TS=1
  else
    HAS_TSCONFIG=1
    HAS_TS=1
  fi
fi
if command -v rg >/dev/null 2>&1; then
  rg -l --glob '*.ts' --glob '*.tsx' --glob '!**/node_modules/**' --glob '!**/.git/**' --glob '!**/dist/**' --glob '!**/build/**' . 2>/dev/null \
    | head -1 | grep -q . && HAS_TS=1
fi

[[ -d frontend || -d apps/web ]] && HAS_FRONTEND_DIR=1
[[ -d backend || -d apps/api || -d server ]] && HAS_BACKEND_DIR=1

[[ -f package.json ]] && rg -q '"workspaces"' package.json 2>/dev/null && HAS_WORKSPACES=1

[[ -f .prettierrc || -f .prettierrc.js || -f .prettierrc.cjs || -f prettier.config.js ]] && HAS_PRETTIER=1
[[ -f eslint.config.js || -f eslint.config.mjs || -f eslint.config.cjs || -f eslint.config.ts \
  || -f .eslintrc.js || -f .eslintrc.cjs || -f .eslintrc.json || -f .eslintrc.yml ]] && HAS_ESLINT=1
[[ -f biome.json || -f biome.jsonc ]] && HAS_BIOME=1 && HAS_ESLINT=1
pkg_has '"oxlint"' && HAS_OXLINT=1

# Lint present? (Deno lint counts only for Deno-primary packages — not Vite+supabase sidecars)
if script_has lint || [[ "$HAS_ESLINT" -eq 1 || "$HAS_BIOME" -eq 1 || "$HAS_OXLINT" -eq 1 ]]; then
  HAS_LINT=1
fi
if [[ "$HAS_DENO" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ]] && { [[ -f deno.json ]] || [[ -f deno.jsonc ]]; }; then
  HAS_LINT=1
fi

# Typecheck present?
if script_has typecheck || script_has type-check || script_has types; then
  HAS_TYPECHECK=1
fi
if [[ "$HAS_TSCONFIG" -eq 1 ]]; then
  # Runnable if script exists or typescript is a dependency (npx tsc --noEmit)
  if script_has typecheck || script_has type-check || pkg_has '"typescript"'; then
    HAS_TYPECHECK=1
  fi
fi
pkg_has '"vue-tsc"' && HAS_TYPECHECK=1
pkg_has '"astro"' && script_has check && HAS_TYPECHECK=1
# Deno check only when Deno is the app (root deno.json), not a supabase/functions sidecar on a Vite app
if [[ "$HAS_DENO" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ]] && { [[ -f deno.json ]] || [[ -f deno.jsonc ]]; }; then
  HAS_TYPECHECK=1
fi

if [[ -f .qa/project.yaml ]]; then
  rg -q 'checksCommand:' .qa/project.yaml 2>/dev/null && HAS_CHECKS_CMD=1
fi
[[ -f package.json ]] && rg -q '"checks"|"verify"' package.json 2>/dev/null && HAS_CHECKS_CMD=1

# Primary language (priority: explicit native > JS/TS when no FE framework)
PRIMARY_LANG="unknown"
if [[ "$HAS_GO" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 && "$HAS_JS_PKG" -eq 0 ]]; then
  PRIMARY_LANG="go"
elif [[ "$HAS_RUST" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 && "$HAS_JS_PKG" -eq 0 ]]; then
  PRIMARY_LANG="rust"
elif [[ "$HAS_SWIFT" -eq 1 && "$HAS_JS_PKG" -eq 0 ]]; then
  PRIMARY_LANG="swift"
elif [[ "$HAS_KOTLIN" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ]]; then
  PRIMARY_LANG="kotlin"
elif [[ "$HAS_PYTHON" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 && "$HAS_JS_PKG" -eq 0 ]]; then
  PRIMARY_LANG="python"
elif [[ "$HAS_PYTHON" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 && "$HAS_FRONTEND_DIR" -eq 0 ]]; then
  PRIMARY_LANG="python"
elif [[ "$HAS_DENO" -eq 1 && "$HAS_JS_PKG" -eq 0 ]]; then
  PRIMARY_LANG="deno"
elif [[ "$HAS_TS" -eq 1 ]]; then
  PRIMARY_LANG="ts"
elif [[ "$HAS_JS_PKG" -eq 1 ]]; then
  PRIMARY_LANG="js"
elif [[ "$HAS_PYTHON" -eq 1 ]]; then
  PRIMARY_LANG="python"
elif [[ "$HAS_GO" -eq 1 ]]; then
  PRIMARY_LANG="go"
elif [[ "$HAS_RUST" -eq 1 ]]; then
  PRIMARY_LANG="rust"
elif [[ "$HAS_DENO" -eq 1 ]]; then
  PRIMARY_LANG="deno"
fi

# Mixed signal
MIXED=0
NATIVE_COUNT=0
[[ "$HAS_PYTHON" -eq 1 ]] && NATIVE_COUNT=$((NATIVE_COUNT + 1))
[[ "$HAS_GO" -eq 1 ]] && NATIVE_COUNT=$((NATIVE_COUNT + 1))
[[ "$HAS_RUST" -eq 1 ]] && NATIVE_COUNT=$((NATIVE_COUNT + 1))
if [[ "$NATIVE_COUNT" -ge 1 && ( "$HAS_TS" -eq 1 || "$HAS_NEXT" -eq 1 || "$HAS_VITE" -eq 1 ) ]]; then
  MIXED=1
  PRIMARY_LANG="mixed"
fi

# App kind
APP_KIND="unknown"
if [[ "$HAS_WORKSPACES" -eq 1 || ( "$HAS_FRONTEND_DIR" -eq 1 && "$HAS_BACKEND_DIR" -eq 1 ) ]]; then
  APP_KIND="monorepo"
elif [[ "$HAS_SWIFT" -eq 1 || "$HAS_KOTLIN" -eq 1 ]]; then
  APP_KIND="mobile"
elif [[ "$HAS_NEXT" -eq 1 || "$HAS_VITE" -eq 1 || "$HAS_FRONTEND_DIR" -eq 1 ]]; then
  APP_KIND="spa"
elif [[ "$HAS_RUST" -eq 1 && "$HAS_FRONTEND_DIR" -eq 0 ]]; then
  APP_KIND="cli"
elif [[ "$HAS_GO" -eq 1 || "$HAS_PRISMA" -eq 1 || "$HAS_BACKEND_DIR" -eq 1 || "$HAS_PYTHON" -eq 1 ]]; then
  APP_KIND="api"
elif [[ "$HAS_DENO" -eq 1 ]]; then
  APP_KIND="api"
fi

PROFILE="unknown"
if [[ "$HAS_WORKSPACES" -eq 1 || ( "$HAS_FRONTEND_DIR" -eq 1 && "$HAS_BACKEND_DIR" -eq 1 ) ]]; then
  PROFILE="monorepo"
elif [[ "$HAS_NEXT" -eq 1 ]]; then
  PROFILE="next"
elif [[ "$HAS_VITE" -eq 1 ]]; then
  PROFILE="vite-react"
elif [[ "$HAS_DENO" -eq 1 && "$HAS_JS_PKG" -eq 0 ]]; then
  PROFILE="deno-only"
elif [[ "$HAS_DENO" -eq 1 && "$HAS_FRONTEND_DIR" -eq 0 ]]; then
  PROFILE="deno-supabase"
elif [[ "$PRIMARY_LANG" == "python" || ( "$HAS_PYTHON" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ) ]]; then
  PROFILE="python-api"
elif [[ "$PRIMARY_LANG" == "go" || ( "$HAS_GO" -eq 1 && "$HAS_NEXT" -eq 0 && "$HAS_VITE" -eq 0 ) ]]; then
  PROFILE="go-api"
elif [[ "$PRIMARY_LANG" == "rust" ]]; then
  PROFILE="rust-cli"
elif [[ "$PRIMARY_LANG" == "swift" ]]; then
  PROFILE="swift-ios"
elif [[ "$PRIMARY_LANG" == "kotlin" ]]; then
  PROFILE="kotlin-android"
elif [[ "$HAS_PRISMA" -eq 1 ]]; then
  PROFILE="express-prisma"
elif [[ "$HAS_FRONTEND_DIR" -eq 0 && "$HAS_JS_PKG" -eq 1 ]]; then
  PROFILE="api-only"
fi

# Browo-style layout heuristic
if [[ -d frontend && -d backend && -f backend/prisma/schema.prisma ]]; then
  PROFILE="monorepo"
  APP_KIND="monorepo"
  echo "HINT=browo-hr-like"
fi

# JS/TS bootstrap hints (1 = missing required gate)
NEEDS_LINT_BOOTSTRAP=0
NEEDS_TYPECHECK_BOOTSTRAP=0
if [[ "$PRIMARY_LANG" == "ts" || "$PRIMARY_LANG" == "js" || "$PRIMARY_LANG" == "mixed" ]]; then
  [[ "$HAS_LINT" -eq 0 ]] && NEEDS_LINT_BOOTSTRAP=1
  # Typecheck required when TS sources or tsconfig exist
  if [[ "$HAS_TS" -eq 1 || "$HAS_TSCONFIG" -eq 1 ]]; then
    [[ "$HAS_TYPECHECK" -eq 0 ]] && NEEDS_TYPECHECK_BOOTSTRAP=1
  fi
fi

echo "ROOT=$ROOT"
echo "PROFILE=$PROFILE"
echo "PRIMARY_LANG=$PRIMARY_LANG"
echo "APP_KIND=$APP_KIND"
echo "MIXED=$MIXED"
echo "HAS_NEXT=$HAS_NEXT"
echo "HAS_VITE=$HAS_VITE"
echo "HAS_PRISMA=$HAS_PRISMA"
echo "HAS_DENO=$HAS_DENO"
echo "HAS_SUPABASE_FN=$HAS_SUPABASE_FN"
echo "HAS_PYTHON=$HAS_PYTHON"
echo "HAS_GO=$HAS_GO"
echo "HAS_RUST=$HAS_RUST"
echo "HAS_SWIFT=$HAS_SWIFT"
echo "HAS_KOTLIN=$HAS_KOTLIN"
echo "HAS_TS=$HAS_TS"
echo "HAS_JS_PKG=$HAS_JS_PKG"
echo "HAS_TSCONFIG=$HAS_TSCONFIG"
echo "HAS_FRONTEND_DIR=$HAS_FRONTEND_DIR"
echo "HAS_BACKEND_DIR=$HAS_BACKEND_DIR"
echo "HAS_WORKSPACES=$HAS_WORKSPACES"
echo "HAS_PRETTIER=$HAS_PRETTIER"
echo "HAS_ESLINT=$HAS_ESLINT"
echo "HAS_BIOME=$HAS_BIOME"
echo "HAS_OXLINT=$HAS_OXLINT"
echo "HAS_LINT=$HAS_LINT"
echo "HAS_TYPECHECK=$HAS_TYPECHECK"
echo "HAS_CHECKS_CMD=$HAS_CHECKS_CMD"
echo "NEEDS_LINT_BOOTSTRAP=$NEEDS_LINT_BOOTSTRAP"
echo "NEEDS_TYPECHECK_BOOTSTRAP=$NEEDS_TYPECHECK_BOOTSTRAP"
