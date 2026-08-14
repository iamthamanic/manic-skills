# ECC Runner Loop — state extensions

Uses `@ecc-runner` state (`state.json` at repo root or `.qa/queue/state.json`). Loop mode adds:

## runMode

```json
"runMode": "loop"
```

## Extra fields

| Field | Type | Description |
|-------|------|-------------|
| `prUrls` | `Record<string, string>` | Issue number → PR URL |
| `mergedIssues` | `number[]` | Issues with confirmed `gh pr merge` |
| `lastMergeSha` | `string \| null` | Latest merge commit on default branch |

## Phases (loop)

All `@ecc-runner` phases plus strict ordering for:

```
… → verify-ticket → composition-gate → verify-ui? → review → ecc-check → commit → pr → babysit → merge → done
```

`merge` = running `@pr-merge-safe merge` for the active issue PR.

## Transition rules

- Enter `commit` only when `ecc-check` passed **and** composition-gate proof is CLEAR or SKIPPED for current HEAD
- Enter `merge` only when `babysit` reports CI green + mergeable
- Enter `done` only when merge exit state is **MERGED**
- Clear `activeIssue` only after `done`

## Resume

If `activeIssue` set and `phase` ∉ `done` | `blocked` | `paused`:

1. Resume at `phase` (do not re-implement unless verify failed)
2. If `phase` is `pr` and PR exists → skip to `babysit`
3. If PR merged but issue not in `mergedIssues` → sync `main`, mark done, next issue
