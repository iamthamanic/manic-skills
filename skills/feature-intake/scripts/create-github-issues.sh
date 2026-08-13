#!/usr/bin/env bash
# Feature Intake — create GitHub issues from approved JSON draft.
# Usage: create-github-issues.sh .qa/intake/<epic-slug>-issues.json
# Requires: gh, jq; user must have approved draft.

set -euo pipefail

DRAFT="${1:?path to *-issues.json required}"

if [[ ! -f "${DRAFT}" ]]; then
  echo "error: draft not found: ${DRAFT}" >&2
  exit 1
fi

gh auth status >/dev/null

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
EPIC=$(jq -r '.epicSlug' "${DRAFT}")
DEFAULT_LABELS=$(jq -r '.defaultLabels // [] | join(",")' "${DRAFT}")

echo "# Feature Intake — create issues (${EPIC})"
echo "repo: ${REPO}"
echo ""

# Ensure ECC runner labels exist (P0, P1, needs-design, …)
RUNNER_ROOT="${ECC_RUNNER_ROOT:-}"
if [[ -z "${RUNNER_ROOT}" ]]; then
  if [[ -d ".claude/skills/ecc-runner/scripts" ]]; then
    RUNNER_ROOT=".claude/skills/ecc-runner"
  elif [[ -d "${HOME}/.claude/skills/ecc-runner/scripts" ]]; then
    RUNNER_ROOT="${HOME}/.claude/skills/ecc-runner"
  fi
fi
if [[ -n "${RUNNER_ROOT}" && -x "${RUNNER_ROOT}/scripts/bootstrap-labels.sh" ]]; then
  bash "${RUNNER_ROOT}/scripts/bootstrap-labels.sh" >/dev/null
fi

CREATED_JSON='{}'
COUNT=$(jq '.issues | length' "${DRAFT}")

for i in $(seq 0 $((COUNT - 1))); do
  TITLE=$(jq -r ".issues[$i].title" "${DRAFT}")
  BODY=$(jq -r ".issues[$i].body" "${DRAFT}")
  LABELS=$(jq -r ".issues[$i].labels // [] | join(\",\")" "${DRAFT}")
  SLUG=$(jq -r ".issues[$i].featureSlug" "${DRAFT}")

  # Resolve dependsOn titles → #numbers from CREATED_JSON
  BLOCKER_LINES=""
  while IFS= read -r dep; do
    [[ -z "${dep}" ]] && continue
    NUM=$(echo "${CREATED_JSON}" | jq -r --arg d "${dep}" '.[$d] // empty')
    if [[ -n "${NUM}" ]]; then
      BLOCKER_LINES="${BLOCKER_LINES}Depends on #${NUM}"$'\n'
    fi
  done < <(jq -r ".issues[$i].dependsOn // [] | .[]" "${DRAFT}")

  FULL_BODY="${BODY}"
  if [[ -n "${BLOCKER_LINES}" ]]; then
    if echo "${FULL_BODY}" | grep -q '^## Blockers'; then
      FULL_BODY=$(echo "${FULL_BODY}" | sed "/^## Blockers/,\$d")
    fi
    FULL_BODY="${FULL_BODY}"$'\n\n## Blockers\n'"${BLOCKER_LINES}"
  fi
  FULL_BODY="${FULL_BODY}"$'\n\n<!-- feature-intake slug: '"${SLUG}"' -->'

  LABEL_ARGS=()
  IFS=',' read -ra LA <<< "${LABELS}"
  for l in "${LA[@]}"; do
    [[ -n "${l}" ]] && LABEL_ARGS+=(--label "${l}")
  done
  if [[ -n "${DEFAULT_LABELS}" ]]; then
    IFS=',' read -ra DL <<< "${DEFAULT_LABELS}"
    for l in "${DL[@]}"; do
      [[ -n "${l}" ]] && LABEL_ARGS+=(--label "${l}")
    done
  fi

  ISSUE_URL=$(gh issue create --repo "${REPO}" --title "${TITLE}" --body "${FULL_BODY}" "${LABEL_ARGS[@]}")
  ISSUE_NUM=$(echo "${ISSUE_URL}" | grep -oE '[0-9]+$')
  CREATED_JSON=$(echo "${CREATED_JSON}" | jq --arg t "${TITLE}" --argjson n "${ISSUE_NUM}" '. + {($t): $n}')
  echo "created #${ISSUE_NUM}  ${TITLE}"
done

echo ""
echo "done: ${COUNT} issue(s). Next: @ecc-runner"
