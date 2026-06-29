#!/usr/bin/env bash
# ECC Runner — detect agent-in-progress issues without matching local state.
# Usage: bash .cursor/skills/ecc-runner/scripts/stale-lock-check.sh

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
STATE_FILE=".qa/queue/state.json"

gh auth status >/dev/null

echo "# ECC Runner — stale lock check (${REPO})"
echo ""

ACTIVE_JSON=$(gh issue list --repo "${REPO}" --state open --label agent-in-progress \
  --json number,title,updatedAt --limit 20)

LOCKED_COUNT=$(echo "${ACTIVE_JSON}" | jq 'length')
STATE_ISSUE="null"
if [[ -f "${STATE_FILE}" ]]; then
  STATE_ISSUE=$(jq -r '.activeIssue // "null"' "${STATE_FILE}")
fi

echo "state.json activeIssue: ${STATE_ISSUE}"
echo "GitHub agent-in-progress count: ${LOCKED_COUNT}"
echo ""

if [[ "${LOCKED_COUNT}" -eq 0 ]]; then
  echo "ok: no locks on GitHub"
  exit 0
fi

echo "${ACTIVE_JSON}" | jq -r '.[] | "#\(.number)  \(.title)  (updated \(.updatedAt))"'

if [[ "${LOCKED_COUNT}" -gt 1 ]]; then
  echo ""
  echo "warn: multiple agent-in-progress issues — use ecc-runner skip or cancel"
fi

if [[ "${STATE_ISSUE}" == "null" ]] || [[ "${STATE_ISSUE}" == "" ]]; then
  echo ""
  echo "stale: GitHub lock(s) exist but state.json has no activeIssue"
  echo "recovery: ecc-runner resume #N | ecc-runner cancel #N | ecc-runner skip"
  exit 2
fi

STATE_IN_GH=$(echo "${ACTIVE_JSON}" | jq --argjson n "${STATE_ISSUE}" 'map(select(.number == $n)) | length')
if [[ "${STATE_IN_GH}" -eq 0 ]]; then
  echo ""
  echo "stale: state.json points to #${STATE_ISSUE} but GitHub has no matching lock"
  exit 2
fi

echo ""
echo "ok: state and GitHub lock aligned for #${STATE_ISSUE}"
