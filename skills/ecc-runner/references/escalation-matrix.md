# ECC Runner — escalation matrix

## Decision tree

```
Stuck or failed?
├─ Same lastError ≥ sameRootCause?
│   └─ freeze + escalate
├─ review-ticket CHANGES_REQUESTED (critical)?
│   └─ implement (blockers) → review again
├─ AC / scope unclear?
│   └─ @pingpong-solution → design; optional @grill-me
├─ No repo pattern?
│   └─ @mine-stars → prior-art
├─ Security / secrets / destructive migration?
│   └─ human + @security-review + security-scan findings on issue
├─ Missing credentials?
│   └─ human
├─ Scope creep vs acceptance?
│   └─ @pingpong-solution
├─ Over-engineered?
│   └─ @ponytail-review → implement
├─ infra/refactor debt?
│   └─ @ponytail-audit (report only unless user wants fix)
└─ CI unrelated to PR?
    └─ human; @babysit if PR exists
```

## Skill mapping

| Symptom | Skill | Then |
|---------|-------|------|
| What to build? | `@pingpong-solution` | `design` |
| Stress-test design | `@grill-me` | `grill` → `implement` |
| Prior art | `@mine-stars` | `prior-art` |
| Codebase patterns | `@search-first` | `research` |
| Library/API docs | `@documentation-lookup` | during `implement` |
| Code quality | `@review-ticket` | `review` |
| Bugs in diff | `@review-bugbot` | inside `review` |
| Security in diff | `@review-security` | inside `review` |
| Long session / many issues | `@strategic-compact` | between issues |
| Ponytail debt harvest | `@ponytail-debt` | after batch |

## Human escalation

```bash
gh issue comment <N> --body "## ECC Runner blocked\n\n…"
gh issue edit <N> --add-label agent-blocked --remove-label agent-in-progress
```

## Recovery

`ecc-runner unblock #N` then `ecc-runner continue`:

1. Remove `agent-blocked`, `needs-human`
2. Add `agent-ready` or `agent-in-progress`
3. Reset `retries`, `lastError`, `paused: false`
4. Set phase to `implement` or `design` per blocker type

## Stale lock

Run `stale-lock-check.sh`. Use `ecc-runner resume #N` or `ecc-runner cancel #N`.
