#!/usr/bin/env bash
# ECC Runner — build prioritized issue queue from all open GitHub issues (auto-triage).
# Usage: build-queue.sh [owner/repo] [milestone-filter]
# Output: JSON { queue, next, skipped, repo }

set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
MILESTONE_FILTER="${2:-}"
STATE_FILE=".qa/queue/state.json"

if [[ -f "${STATE_FILE}" ]]; then
  MF=$(jq -r '.milestoneFilter // empty' "${STATE_FILE}" 2>/dev/null || true)
  [[ -n "${MF}" && -z "${MILESTONE_FILTER}" ]] && MILESTONE_FILTER="${MF}"
fi

gh auth status >/dev/null

ISSUES=$(gh issue list --repo "${REPO}" --state open \
  --json number,title,labels,body,milestone \
  --limit 100)

OPEN_NUMBERS=$(echo "${ISSUES}" | jq '[.[].number]')

SKIP_LABELS='["needs-human","wontfix","agent-blocked","agent-done","agent-in-progress"]'

# Resolve "Depends on #N" blockers (case-insensitive)
check_blockers() {
  local body="$1"
  local nums
  nums=$(echo "${body}" | grep -oiE 'depends on #([0-9]+)' | grep -oE '[0-9]+' || true)
  [[ -z "${nums}" ]] && return 0
  for n in ${nums}; do
    state=$(gh issue view "${n}" --repo "${REPO}" --json state -q .state 2>/dev/null || echo "OPEN")
    if [[ "${state}" == "OPEN" ]]; then
      return 1
    fi
  done
  return 0
}

FILTERED='[]'
SKIPPED='[]'

while IFS= read -r row; do
  num=$(echo "${row}" | jq -r '.number')
  title=$(echo "${row}" | jq -r '.title')
  body=$(echo "${row}" | jq -r '.body // ""')
  labels=$(echo "${row}" | jq -c '[.labels[].name]')
  milestone=$(echo "${row}" | jq -r '.milestone.title // ""')

  skip=false
  reason=""

  for lbl in needs-human wontfix agent-blocked agent-done agent-in-progress; do
    if echo "${labels}" | jq -e --arg l "${lbl}" 'index($l)' >/dev/null; then
      skip=true
      reason="label:${lbl}"
      break
    fi
  done

  if [[ "${skip}" == false ]] && echo "${body}" | grep -qi '\[human-only\]'; then
    skip=true
    reason="human-only"
  fi

  if [[ "${skip}" == false ]] && [[ -n "${MILESTONE_FILTER}" ]] && [[ "${milestone}" != "${MILESTONE_FILTER}" ]]; then
    skip=true
    reason="milestone-filter:${MILESTONE_FILTER}"
  fi

  if [[ "${skip}" == false ]] && ! check_blockers "${body}"; then
    skip=true
    reason="blocked-by-open-dependency"
  fi

  if [[ "${skip}" == true ]]; then
    SKIPPED=$(echo "${SKIPPED}" | jq --argjson n "${num}" --arg t "${title}" --arg r "${reason}" \
      '. + [{number: $n, title: $t, reason: $r}]')
    continue
  fi

  prio=0
  echo "${labels}" | jq -e 'index("agent-ready")' >/dev/null 2>&1 && prio=$((prio + 1000))
  echo "${labels}" | jq -e 'index("P0")' >/dev/null 2>&1 && prio=$((prio + 300))
  echo "${labels}" | jq -e 'index("P1")' >/dev/null 2>&1 && prio=$((prio + 200))
  echo "${labels}" | jq -e 'index("P2")' >/dev/null 2>&1 && prio=$((prio + 100))

  FILTERED=$(echo "${FILTERED}" | jq --argjson n "${num}" --arg t "${title}" --argjson p "${prio}" --arg m "${milestone}" \
    '. + [{number: $n, title: $t, priority: $p, milestone: $m}]')
done < <(echo "${ISSUES}" | jq -c '.[]')

QUEUE=$(echo "${FILTERED}" | jq 'sort_by(-.priority, .number) | map(.number)')
NEXT=$(echo "${QUEUE}" | jq '.[0] // null')

jq -n \
  --arg repo "${REPO}" \
  --argjson queue "${QUEUE}" \
  --argjson next "${NEXT}" \
  --argjson skipped "${SKIPPED}" \
  --arg milestoneFilter "${MILESTONE_FILTER}" \
  '{repo: $repo, queue: $queue, next: $next, skipped: $skipped,
    milestoneFilter: (if $milestoneFilter == "" then null else $milestoneFilter end)}'
