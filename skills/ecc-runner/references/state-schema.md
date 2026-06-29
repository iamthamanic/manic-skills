# ECC Runner — state.json schema

Runtime: `.qa/queue/state.json` (gitignored). Copy from `state.template.json`.

## Fields (v2)

| Field | Type | Description |
|-------|------|-------------|
| `version` | `2` | Schema version |
| `repo` | string | `owner/name` |
| `activeIssue` | number \| null | Current issue |
| `featureSlug` | string \| null | kebab-case slug |
| `phase` | enum | See below |
| `branch` | string \| null | `issue/<N>-<slug>` |
| `prUrl` | string \| null | Linked PR |
| `milestoneFilter` | string \| null | e.g. `phase-2` |
| `paused` | boolean | True after `ecc-runner pause` |
| `runMode` | `"batch"` \| `"step"` | Default `batch`; `step` = one phase per invocation |
| `queue` | number[] | Ordered issue numbers |
| `completedIssues` | number[] | Done |
| `retries` | object | Per-phase counts |
| `maxRetries` | object | Limits |
| `lastError` | string \| null | Stuck detection |
| `lastErrorCount` | number | Same-error streak |
| `issuesProcessedInSession` | number | For strategic-compact |
| `updatedAt` | ISO string | Last write |

## Phases

```
idle | setup | research | design | grill | implement | verify-ticket | verify-ui
| review | verify-loop | security-scan | commit | pr | babysit | prior-art | done | blocked
```

## retries keys

```json
{
  "implement": 0,
  "verifyTicket": 0,
  "verifyUi": 0,
  "review": 0
}
```

## State transitions

Write after every phase. On `ecc-runner unblock`, reset `retries` for that issue and `lastError*`.

On `ecc-runner skip`: remove GitHub lock; optionally re-queue issue at end.

On `ecc-runner pause`: set `paused: true`, remove `agent-in-progress`, keep branch/phase.
