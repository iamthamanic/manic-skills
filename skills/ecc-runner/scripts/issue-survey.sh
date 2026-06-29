#!/usr/bin/env bash
# ECC Runner — print open-issue snapshot for queue triage.
# Usage: .cursor/skills/ecc-runner/scripts/issue-survey.sh [owner/repo]

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

gh auth status >/dev/null

echo "# ECC Runner — issue survey (${REPO})"
echo ""

echo ""
echo "## auto-queue (next up — no agent-ready label required)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -x "${SCRIPT_DIR}/build-queue.sh" ]]; then
  "${SCRIPT_DIR}/build-queue.sh" "${REPO}" 2>/dev/null | jq -r '
    if .next == null then "  (none eligible)"
    else "  next: #" + (.next|tostring) + "\n  queue: " + ([.queue[] | "#" + (.|tostring)] | join(", "))
    end'
else
  echo "  (build-queue.sh not found)"
fi

echo ""
echo "## agent-ready (priority boost, optional)"
gh issue list --repo "${REPO}" --state open --label agent-ready \
  --json number,title,labels,milestone,updatedAt \
  --limit 50 | jq -r '
  if length == 0 then "  (none)"
  else .[] | "  #\(.number)  \(.title)"
  end'

echo ""
echo "## agent-in-progress (locked)"
gh issue list --repo "${REPO}" --state open --label agent-in-progress \
  --json number,title,labels \
  --limit 20 | jq -r '
  if length == 0 then "  (none)"
  else .[] | "  #\(.number)  \(.title)"
  end'

echo ""
echo "## open issues (all)"
gh issue list --repo "${REPO}" --state open \
  --json number,title,labels \
  --limit 50 | jq -r '
  if length == 0 then "  (none)"
  else .[] | "  #\(.number)  \(.title)  [\([.labels[].name] | join(", "))]"
  end'

echo ""
echo "## skipped by runner (needs-human / wontfix / agent-blocked)"
for label in needs-human wontfix agent-blocked; do
  count=$(gh issue list --repo "${REPO}" --state open --label "${label}" --json number -q 'length' 2>/dev/null || echo 0)
  if [[ "${count}" != "0" ]]; then
    echo "  ${label}: ${count}"
    gh issue list --repo "${REPO}" --state open --label "${label}" \
      --json number,title -q '.[] | "    #\(.number)  \(.title)"'
  fi
done
