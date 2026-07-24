---
name: ecc-runner
description: >-
  Autonomous GitHub issue runner: bootstraps labels, builds queue, works through
  every eligible issue with the full pipeline (implement → verify → review → PR)
  without per-step prompts. Default is batch mode; use ecc-runner step for one
  phase only. Reports when queue is done, blocked, or needs human. Triggers:
  ecc-runner, /ecc-runner, issues abarbeiten, github issues, issue queue.
disable-model-invocation: true
---

# ECC Runner

Autonomous GitHub issue orchestrator (global skill). **Default = batch:** run the full pipeline per issue, then the next, until the queue is empty or a hard stop.

## Install resolution

Scripts live under **project override** or **global**:

```bash
if [[ -d ".cursor/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT=".cursor/skills/ecc-runner"
elif [[ -d "$HOME/.cursor/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT="$HOME/.cursor/skills/ecc-runner"
fi
# Example: bash "$ECC_RUNNER_ROOT/scripts/sync-queue-to-state.sh"
```

Read `.qa/runner-profile.yaml` for stack-specific helper routing when present.

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Batch** (default) | `@ecc-runner`, `/ecc-runner`, `ecc-runner continue`, `issues abarbeiten` | Chain **all phases** per issue → next issue → **one final report** |
| **Step** | `ecc-runner step`, `@ecc-runner step` | **One phase only**, then stop and summarize |
| **Status** | `ecc-runner status` | Survey + state; no code changes |

`state.json` → `runMode`: `"batch"` | `"step"`. Set `"step"` only when user says `step`.

## Full pipeline (per issue)

```
setup → research? → design? → grill? → seed acceptance
→ @implement → @verify-ticket → @web-design-guidelines? → @verify-ui? → @review-ticket
→ @ecc-check (includes @memory-live-doc mode=apply for material issues)
→ security-scan? → commit → pr → babysit?
→ agent-done → next issue
```

Helpers: [references/helper-skills.md](references/helper-skills.md). Commands: [references/commands.md](references/commands.md). Reporting: [references/reporting.md](references/reporting.md).

## Batch contract (default)

When user invokes **`@ecc-runner`** without `step`:

1. Run bootstrap (Steps 0–1 below) — **no user-facing report yet** (log to `runs/issue-<N>.md` only).
2. For each issue in queue (skip `completedIssues`):
   - Auto-pick → lock → branch → seed acceptance → classify
   - **Run every pipeline phase in order** without asking `continue`
   - Self-correct on verify/review failures (retries in `state.json`)
   - On phase success: advance `state.json` phase, append run log
   - On issue complete: commit + open PR (`Closes #N`), `agent-done`, `sync-queue-to-state.sh`, **pick next**
3. **`@strategic-compact`:** between issues if queue length > 3 or context is large — **do not stop the batch** (compact and continue). Never set `paused: true` for context; if the session must end, `@handoff` with `paused: false`.
4. **Single user report** only when batch ends (see Reporting).

**Do not** stop after auto-pick. **Do not** stop after one phase in batch mode.

### Batch approval (implicit)

Starting `@ecc-runner` in batch mode = user approves for this session:

- Work on issue branches autonomously
- **Local commits** on the issue branch when `@ecc-check` + `review` pass
- **Push + open PR** via `@commit-pr-safe` (`Closes #N`) — never merge to main

Still forbidden: `git push --no-verify`, force push, merge without user.

### Hard stops (batch pauses → report)

| Stop | Action |
|------|--------|
| Queue empty | Final report: all completed + skipped |
| `blocked` / retries exhausted | Report blocker; label `agent-blocked` |
| Security / missing secrets / destructive migration | `needs-human`; report |
| Same `lastError` ≥ `sameRootCause` | Escalate; report |
| Observer loop (3 turns, no state progress) | Report stuck phase |
| User said `ecc-runner pause` | Report pause point |

Overrides: `ecc-runner step`, `skip`, `pause`, `cancel`, `milestone`, `triage`.

## Quick start (batch)

**`@ecc-runner`** — one invocation, full queue:

1. `gh auth status`
2. `bootstrap-labels.sh` → `issue-survey.sh` → `stale-lock-check.sh`
3. `@project-setup audit` if `.qa/project.yaml` missing
4. Init / load `state.json`; set `runMode: "batch"`
5. `sync-queue-to-state.sh`
6. **Loop** issues until hard stop or queue empty (batch contract above)

No manual labels. No `triage #N` required. Optional: `ecc-runner milestone phase-2`, `ecc-runner triage 42` (priority boost before start).

### Queue rules

Eligible: all open issues except `needs-human`, `wontfix`, `agent-blocked`, `agent-done`, `agent-in-progress` (unless resuming), `[human-only]`, open `Depends on #X`.

**Sort:** `agent-ready` boost → `P0` > `P1` > `P2` → issue number asc.

## State

| File | Purpose |
|------|---------|
| `state.json` | `runMode`, queue, phase, retries, `prUrl`, `paused` |
| `SHARED_TASK_NOTES.md` | Cross-issue context |
| `runs/issue-<N>.md` | Per-issue log (primary batch telemetry) |

Schema: [references/state-schema.md](references/state-schema.md).

## Session checklist (batch)

```
- [ ] 0: bootstrap + sync queue
- [ ] LOOP until stop:
      pick → classify → ALL phases → commit/pr → done → next
- [ ] Final report (reporting.md)
```

## Step 0d — Stale lock recovery

If `stale-lock-check.sh` exits 2 → recover per [commands.md](references/commands.md); in batch, fix then **continue loop**.

## Step 1 — Build queue

```bash
bash "${ECC_RUNNER_ROOT:-$HOME/.cursor/skills/ecc-runner}/scripts/sync-queue-to-state.sh"
```

## Step 2 — Auto-pick / lock

Resume if `activeIssue` + `paused: false` + phase ∉ `done` | `blocked`.

Else pick `queue[0]` not in `completedIssues`:

```bash
gh issue edit <N> --add-label agent-in-progress
gh issue edit <N> --remove-label agent-ready 2>/dev/null || true
git checkout -b issue/<N>-<feature-slug>   # or checkout existing
bash "${ECC_RUNNER_ROOT:-$HOME/.cursor/skills/ecc-runner}/scripts/seed-acceptance-from-issue.sh" <N> <feature-slug>
```

## Step 3 — Classify

| Signal | Route |
|--------|-------|
| `needs-design`, ambiguous scope | `design` (then continue batch) |
| Clear AC / design exists | `implement` |
| `content` | `@questolin-content-layer` |
| API/auth/env | `@security-review`, later `security-scan` |
| New library | `@documentation-lookup` |

## Step 4 — Phase execution

### Batch (default)

Execute **all applicable phases in one session** in this order:

`setup` → `research`? → `design`? → `grill`? → `implement` → `verify-ticket` → `web-design-guidelines`? → `verify-ui`? → `review` → `ecc-check` → `security-scan`? → `commit` → `pr` → `babysit`? → `done`

Skip `web-design-guidelines` / `verify-ui` if no UI files in diff. Skip `security-scan` unless API/auth/secrets touched.

| Phase | Skill | Exit |
|-------|-------|------|
| `implement` | `@implement` (incl. `@frontend-design` / `@design-taste-frontend` when UI) | Code + acceptance notes |
| `verify-ticket` | `@verify-ticket` | PASS |
| `web-design-guidelines` | `@web-design-guidelines` | Findings fixed or accepted; skip if no UI |
| `verify-ui` | `@verify-ui` | PASS or skipped |
| `review` | `@review-ticket` | ACCEPT |
| `ecc-check` | `@ecc-check` (ensure `@memory-live-doc` apply for material diffs) | READY |
| `security-scan` | `npx ecc-agentshield scan` | No critical |
| `commit` | `@commit-push-safe` | Committed on branch |
| `pr` | `@commit-pr-safe` | PR URL, `Closes #N` |
| `babysit` | `@babysit` | CI green (optional in batch) |

After `done`: `sync-queue-to-state.sh` → **immediately** start next issue (no user prompt).

### Step mode

**One phase only**, then stop with short summary and current `state.json` phase.

## Step 5 — Self-correction

Retries: `implement` 3, `verifyTicket` 2, `verifyUi` 2, `review` 2, `sameRootCause` 2.

On FAIL in **batch**: retry phase automatically until limit → then hard stop + report.

## Step 6 — Escalation

[references/escalation-matrix.md](references/escalation-matrix.md)

## Step 7 — Issue complete

1. `gh issue comment` summary + PR link
2. `agent-done`, remove `agent-in-progress`
3. `completedIssues` += N; clear `activeIssue`
4. **Batch:** next issue immediately

## Reporting

See [references/reporting.md](references/reporting.md). **Batch = minimal chat; log to `runs/`.**

## Guardrails

- No push to main; no `--no-verify`
- Lean ECC only
- UI/errors Deutsch; commits English
- `ecc-runner step` for interactive/debug

## Full ship loop (merge included)

For **verify → merge → next issue** without manual merge pauses, use **`@ecc-runner-loop`** (`~/.cursor/skills/ecc-runner-loop`). This skill stops at PR open; the loop skill adds mandatory babysit + `@pr-merge-safe merge`.

## Additional resources

- [references/reporting.md](references/reporting.md)
- [references/state-schema.md](references/state-schema.md)
- [references/commands.md](references/commands.md)
- [references/cursor-automation.md](references/cursor-automation.md)
