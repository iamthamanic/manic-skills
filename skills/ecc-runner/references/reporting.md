# ECC Runner — reporting rules

## Batch mode (`@ecc-runner` default)

**Stay silent in chat** during normal progress. Write progress to:

- `.qa/queue/runs/issue-<N>.md` (each phase: timestamp, verdict)
- `.qa/queue/SHARED_TASK_NOTES.md`
- `.qa/queue/state.json`

### When to send ONE user message

Only at **batch end** or **hard stop**:

```markdown
## ECC Runner — batch complete | paused

**Mode:** batch
**Processed:** #1 ✓, #2 ✓, … (or "none")
**Stopped at:** #N — <title> (phase: …) — only if paused
**PRs:** #1 → <url>, …
**Blocked:** #N — reason (if any)
**Queue remaining:** #X, #Y, …
**Resume:** `ecc-runner continue`
```

### Do not report mid-batch for

- Bootstrap, survey, queue sync
- Auto-pick per issue
- Individual phase PASS (verify, review, etc.)
- Starting next issue in queue

### Hard stop → report immediately

- Retries exhausted / `agent-blocked`
- Missing `OPENAI_API_KEY` or other required secrets
- Observer loop (no progress 3 turns)
- User `pause` / `cancel`

## Step mode (`ecc-runner step`)

Report after **every single phase**:

```markdown
**Issue #N** — phase `implement` done → next: `verify-ticket`
```

## Status mode

Report snapshot only; no pipeline work.
