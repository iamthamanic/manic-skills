# ECC Runner Loop — reporting

## Loop mode (default)

**Stay silent in chat** during normal progress. Log to:

- `runs/issue-<N>.md` — each phase: timestamp, skill, verdict (PASS/FAIL/MERGED)
- `state.json` — `phase`, `prUrls`, `mergedIssues`
- `SHARED_TASK_NOTES.md` — cross-issue decisions

### One user message — only at loop end or hard stop

```markdown
## ECC Runner Loop — complete | paused

**Mode:** loop
**Merged:** #1, #2, … (count / total)
**PRs:** #1 → <url> (merged <sha>), …
**Stopped at:** #N — <title> — phase: … — <reason>
**Blocked:** #N — …
**Queue remaining:** #X, #Y, …
**Resume:** `@ecc-runner-loop continue`
```

### Do not report mid-loop for

- Bootstrap, queue sync, auto-pick
- Individual verify/review PASS
- PR opened, babysit round N
- Merge succeeded — log only; continue to next issue
- Starting next issue

### Hard stop → report immediately

- Verify/review retries exhausted
- Composition-gate FLAGGED after retry limit
- `@pr-merge-safe` → NEEDS_HUMAN or BLOCKED
- Missing secrets / destructive migration
- Observer loop (3 turns, no `state.json` progress)
- User `ecc-runner-loop pause`

### Do **not** treat as pause / do **not** report

- Context full / long session → `@strategic-compact` or `@handoff` (see [session-continuity.md](session-continuity.md)); keep `paused: false`
- Merge succeeded — continue to next issue
- Starting next issue after compact
