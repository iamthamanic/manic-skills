#!/usr/bin/env bash
# Detect typedStrict languages from repo stack signals.
# Usage: detect-languages.sh [REPO_ROOT]
# Prints YAML list items to stdout, e.g.:
#   - typescript
#   - python
# Exit 0 always (empty stdout if nothing detected).

set -euo pipefail

ROOT="${1:-.}"
ROOT="$(cd "$ROOT" && pwd)"

# True if any file matching name exists under ROOT (skip heavy dirs).
has_name() {
  local name="$1"
  find "$ROOT" \
    \( -path '*/node_modules/*' -o -path '*/.git/*' -o -path '*/dist/*' \
       -o -path '*/build/*' -o -path '*/.next/*' -o -path '*/vendor/*' \
       -o -path '*/__pycache__/*' -o -path '*/.venv/*' -o -path '*/venv/*' \) -prune \
    -o -name "$name" -print -quit 2>/dev/null | grep -q .
}

# True if any package.json (capped) contains needle.
pkg_has() {
  local needle="$1"
  local f
  while IFS= read -r f; do
    if grep -q "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done < <(find "$ROOT" \
    \( -path '*/node_modules/*' -o -path '*/.git/*' \) -prune \
    -o -name package.json -print 2>/dev/null | head -40)
  return 1
}

declare -a langs=()

add() {
  local lang="$1"
  local i
  for i in "${langs[@]+"${langs[@]}"}"; do
    [[ "$i" == "$lang" ]] && return
  done
  langs+=("$lang")
}

if has_name '*.ts' || has_name '*.tsx' || has_name 'tsconfig.json' \
  || pkg_has '"typescript"' || pkg_has '"@typescript-eslint'; then
  add typescript
fi

if has_name '*.py' || has_name 'pyproject.toml' || has_name 'requirements.txt' \
  || has_name 'Pipfile' || has_name 'setup.py'; then
  add python
fi

if has_name 'go.mod' || has_name '*.go'; then
  add go
fi

if has_name 'Cargo.toml' || has_name '*.rs'; then
  add rust
fi

if has_name 'composer.json' || has_name '*.php'; then
  add php
fi

if has_name 'Gemfile' || has_name '*.rb'; then
  add ruby
fi

if has_name '*.java' || has_name 'pom.xml' || has_name 'build.gradle' \
  || has_name 'build.gradle.kts'; then
  add java
fi

if has_name '*.kt' || has_name '*.kts'; then
  add kotlin
fi

if has_name '*.cs' || has_name '*.csproj' || has_name '*.sln'; then
  add csharp
fi

if [[ ${#langs[@]} -eq 0 ]]; then
  exit 0
fi

for lang in "${langs[@]}"; do
  echo "  - $lang"
done
