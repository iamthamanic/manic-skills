#!/usr/bin/env bash
# ECC Runner — sync state.json queue from build-queue.sh and print next issue.
# Usage: sync-queue-to-state.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME=".qa/queue/state.json"
TEMPLATE=".qa/queue/state.template.json"

if [[ ! -f "${RUNTIME}" ]]; then
  cp "${TEMPLATE}" "${RUNTIME}"
fi

QUEUE_JSON=$("${SCRIPT_DIR}/build-queue.sh")
REPO=$(echo "${QUEUE_JSON}" | jq -r '.repo')
QUEUE=$(echo "${QUEUE_JSON}" | jq '.queue')
NEXT=$(echo "${QUEUE_JSON}" | jq '.next')
SKIPPED_COUNT=$(echo "${QUEUE_JSON}" | jq '.skipped | length')
MF=$(echo "${QUEUE_JSON}" | jq -r '.milestoneFilter // empty')

COMPLETED=$(jq -c '.completedIssues // []' "${RUNTIME}")
# Remove completed from queue
QUEUE=$(jq -n --argjson q "${QUEUE}" --argjson c "${COMPLETED}" \
  '$q | map(select(. as $n | $c | index($n) | not))')
NEXT=$(echo "${QUEUE}" | jq '.[0] // null')

NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
TMP=$(mktemp)
jq --arg repo "${REPO}" --argjson queue "${QUEUE}" --arg now "${NOW}" --arg mf "${MF}" \
  '.repo = $repo | .queue = $queue | .updatedAt = $now | .milestoneFilter = (if $mf == "" then .milestoneFilter else $mf end)' \
  "${RUNTIME}" > "${TMP}" && mv "${TMP}" "${RUNTIME}"

echo "# ECC Runner — auto queue"
echo "repo: ${REPO}"
echo "next: $(echo "${NEXT}" | jq -r 'if . == null then "(none)" else "#" + (.|tostring) end')"
echo "queue: $(echo "${QUEUE}" | jq -r 'map("#" + (.|tostring)) | join(", ")')"
echo "skipped: ${SKIPPED_COUNT} issues (needs-human, blocked, deps, …)"
echo ""
echo "${QUEUE_JSON}" | jq -r '.skipped[]? | "  skip #\(.number)  \(.reason)"' | head -20
