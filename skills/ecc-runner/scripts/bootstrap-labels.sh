#!/usr/bin/env bash
# ECC Runner — idempotent GitHub label bootstrap for the current repo.
# Usage: .cursor/skills/ecc-runner/scripts/bootstrap-labels.sh [owner/repo]

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)}"

if [[ -z "${REPO}" ]]; then
  echo "error: could not resolve repo; pass owner/name or run inside a git repo with gh configured" >&2
  exit 1
fi

gh auth status >/dev/null

create_label() {
  local name="$1"
  local color="$2"
  local description="$3"
  if gh label list --repo "${REPO}" --json name -q ".[] | select(.name==\"${name}\") | .name" 2>/dev/null | grep -qx "${name}"; then
    echo "ok  ${name} (exists)"
  else
    gh label create "${name}" --repo "${REPO}" --color "${color}" --description "${description}" && echo "new ${name}"
  fi
}

echo "ECC Runner label bootstrap — ${REPO}"
echo ""

create_label "agent-ready" "0E8A16" "Safe for ecc-runner to pick"
create_label "agent-in-progress" "FBCA04" "ecc-runner lock — do not pick in parallel"
create_label "agent-blocked" "D93F0B" "ecc-runner escalated; needs human or design"
create_label "agent-done" "1D76DB" "Completed by ecc-runner"
create_label "needs-design" "C5DEF5" "Run pingpong-solution before implement"
create_label "needs-human" "B60205" "Never auto-pick by ecc-runner"
create_label "P0" "B60205" "Highest priority in ecc-runner queue"
create_label "P1" "FBCA04" "Medium priority in ecc-runner queue"
create_label "P2" "FEF2C0" "Low priority in ecc-runner queue"

echo ""
echo "done"
