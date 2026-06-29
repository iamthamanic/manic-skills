#!/usr/bin/env bash
# ECC Runner — seed .qa/acceptance stub from GitHub issue body (## Acceptance / ## Intent).
# Usage: bash .cursor/skills/ecc-runner/scripts/seed-acceptance-from-issue.sh <issue-number> <feature-slug>

set -euo pipefail

ISSUE="${1:?issue number required}"
SLUG="${2:?feature-slug required}"
REPO="${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
OUT=".qa/acceptance/${SLUG}.md"
DATE=$(date +%Y-%m-%d)

gh auth status >/dev/null

if [[ -f "${OUT}" ]]; then
  echo "skip: ${OUT} already exists"
  exit 0
fi

BODY=$(gh issue view "${ISSUE}" --repo "${REPO}" --json title,body -q '.body // ""')
TITLE=$(gh issue view "${ISSUE}" --repo "${REPO}" --json title -q '.title')

mkdir -p .qa/acceptance

extract_section() {
  local heading="$1"
  echo "${BODY}" | awk -v h="${heading}" '
    BEGIN { found=0 }
    $0 ~ "^##[[:space:]]*" h { found=1; next }
    found && /^## / { exit }
    found { print }
  '
}

INTENT=$(extract_section "Intent" | sed '/^[[:space:]]*$/d')
ACCEPTANCE=$(extract_section "Acceptance" | sed '/^[[:space:]]*$/d')

if [[ -z "${INTENT}" && -z "${ACCEPTANCE}" ]]; then
  INTENT="From GitHub issue #${ISSUE}: ${TITLE}"
fi

{
  echo "# Feature: ${TITLE}"
  echo ""
  echo "<!-- seeded by ecc-runner from issue #${ISSUE} on ${DATE} — @implement may refine -->"
  echo ""
  echo "## Intent"
  if [[ -n "${INTENT}" ]]; then
    echo "${INTENT}"
  else
    echo "From GitHub issue #${ISSUE}: ${TITLE}"
  fi
  echo ""
  echo "## Happy Path"
  if [[ -n "${ACCEPTANCE}" ]]; then
    while IFS= read -r line; do
      trimmed=$(echo "${line}" | sed 's/^[[:space:]]*//')
      [[ -z "${trimmed}" ]] && continue
      if echo "${trimmed}" | grep -q '^\[[ xX]\]'; then
        echo "${trimmed}"
      else
        echo "- [ ] ${trimmed}"
      fi
    done <<< "${ACCEPTANCE}"
  else
    echo "- [ ] (define in @implement — no ## Acceptance section in issue body)"
  fi
  echo ""
  echo "## Edge Cases"
  echo "- [ ] (from .qa/edge-cases.md + @implement)"
  echo ""
  echo "## Regression"
  echo "- [ ] Feed and topic routes still load"
  echo ""
  echo "## Assumptions"
  echo "- none"
  echo ""
  echo "## Screenshots"
  echo "| Step | Filename |"
  echo "|------|----------|"
  echo "| 1 | \`01-happy-path.png\` |"
  echo ""
  echo "## Implementation Notes"
  echo "<!-- filled after coding -->"
} > "${OUT}"

echo "created: ${OUT}"
