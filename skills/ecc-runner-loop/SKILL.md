---
name: ecc-runner-loop
description: >-
  Full autonomous issue queue: implement, mandatory verify/review/ecc-check fix
  loops, PR, CI babysit, and merge — then next issue until queue empty. Context
  pressure → @strategic-compact or @handoff (never pause the queue). Use when
  user wants hands-off ship (ecc-runner-loop, /ecc-runner-loop, ecc runner loop,
  issues komplett abarbeiten, merge and continue, alles durchziehen bis fertig).
disable-model-invocation: true
---

# ECC Runner Loop

**Ship loop** on top of `@ecc-runner`: same queue/bootstrap/scripts, but **every issue must pass verify → review → ecc-check → PR → babysit → merge** before the next issue starts.

Composes `@ecc-runner` (queue + implement), `@verify-ticket`, `@review-ticket`, `@ecc-check`, `@commit-pr-safe`, `@babysit`, `@pr-merge-safe merge`. Does **not** duplicate their check logic.

## vs `@ecc-runner`

| | `@ecc-runner` | `@ecc-runner-loop` (this) |
|---|---------------|---------------------------|
| Verify/review/ecc-check | Required by contract; often skipped in practice | **Mandatory** — no commit until all pass |
| After PR | Optional babysit; **no merge** | **Mandatory** babysit + **merge** |
| Mid-queue stop | Should not; agents often stop for manual merge | **Forbidden** — merge in-loop, continue |
| User report | Batch end only | Batch end only |
| Merge approval | Never | **Implicit** on `@ecc-runner-loop` invoke |

For one phase / debug → `@ecc-runner step`. For PR-only merge → `@pr-merge-safe merge`.

## Install resolution

Reuse `@ecc-runner` scripts:

```bash
if [[ -d ".claude/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT=".claude/skills/ecc-runner"
elif [[ -d "$HOME/.claude/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT="$HOME/.claude/skills/ecc-runner"
fi
```

Read `.qa/runner-profile.yaml` and `.qa/merge-gate.yaml` when present. Example merge policy: [references/merge-gate.example.yaml](references/merge-gate.example.yaml).

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Loop** (default) | `@ecc-runner-loop`, `/ecc-runner-loop`, `ecc-runner-loop continue` | Full ship loop per issue → next → one final report |
| **Status** | `ecc-runner-loop status` | Snapshot; no code changes |

Set `state.json` → `runMode: "loop"`.

## Loop contract

Invoking **`@ecc-runner-loop`** = user approves for this session:

- Work on issue branches autonomously
- Run **full verify fix-loops** (no shortcut to commit)
- Open PR, **babysit until CI green**, **`@pr-merge-safe merge`**
- `git checkout main && git pull` after each merge
- **Immediately** pick next queue issue — no “please merge PR #N” pause
- One user-facing report only when queue empty or hard stop

Still forbidden: `git push --no-verify`, force push, push to `main`, `gh pr merge --admin` (unless project docs + user say so).

## Per-issue pipeline (strict order)

```
setup → research? → design? → grill? → seed acceptance
→ @implement
→ @verify-ticket          ─┐ fix → re-run until PASS or retry limit
→ @web-design-guidelines? ─┤  (UI diffs only; before verify-ui)
→ @verify-ui?             ─┤
→ @review-ticket          ─┤
→ @ecc-check              ─┘  (Phase E re-checks UI: guidelines → verify-ui)
→ security-scan? (API/auth/secrets only)
→ @commit-push-safe
→ @commit-pr-safe (Closes #N)
→ @babysit (required — CI green + mergeable)
→ @pr-merge-safe merge
→ refresh main locally
→ agent-done → sync queue → NEXT issue
```

**UI create** stays inside `@implement` (`@frontend-design` / `@design-taste-frontend` / `@imagegen-frontend-mobile` for mobile concepts). Loop does **not** invent aesthetics at verify/ship time.

**Gate:** Do **not** open a PR until `@ecc-check` is **READY** **and** the Secure-by-Default Coverage is PASS (no Critical/Important checklist violations). Do **not** start the next issue until merge is **MERGED**.

## Context continuity (mandatory — not optional)

Context pressure is **not** a reason to pause the queue. Never set `paused: true` for “context compact”, “session too long”, or “please continue”.

| Situation | Action | `paused` |
|-----------|--------|----------|
| Same session, queue continues, context growing | **`@strategic-compact`** between issues (after merge + sync, before next implement) | stays `false` |
| Same session, queue length > 3 or ≥3 issues merged this session | **`@strategic-compact`** proactively — then **immediately** pick next issue | stays `false` |
| Context still too full after compact, or Cursor session must end | **`@handoff`** (OS-temp brief: next issue, branch, phase, `state.json`, last PR) — leave `paused: false` so the next agent resumes without asking the user | stays `false` |
| Hard stop (`needs-human`, merge blocked, retries exhausted) | **`@handoff`** + user report; set `paused: true` only for true hard stops / user `pause` | `true` only then |

**Compact vs handoff:** `@strategic-compact` = shrink context, **same** agent keeps looping. `@handoff` = persist resume brief for a **new** agent; next invocation is `@ecc-runner-loop continue` (or `@ecc-runner-loop`) with no “waiting for user merge” story.

**Forbidden:**
- Mid-loop chat: “pausing for context — resume with continue”
- `state.json` → `paused: true` + `lastError: session compact…`
- Stopping after N issues “to save context”

After compact or handoff prep: **continue the issue loop** (or end the turn only after writing the handoff so the *next* agent can pick up — still not a user-facing pause report unless it was a hard stop).

### Verify fix-loop (mandatory)

On FAIL at verify / review / ecc-check:

1. Fix on the issue branch (scoped to acceptance Intent)
2. Re-run failed phase and downstream phases
3. Increment `state.json` retries; stop at limits → hard stop + `agent-blocked`

Retries (same as `@ecc-runner`): `implement` 3, `verifyTicket` 2, `verifyUi` 2, `review` 2, `sameRootCause` 2.

## Session bootstrap

1. `gh auth status`
2. `bootstrap-labels.sh` → `issue-survey.sh` → `stale-lock-check.sh` (from `ECC_RUNNER_ROOT`)
3. `@project-setup audit` if `.qa/project.yaml` missing
4. Load/init `state.json`; set `runMode: "loop"`, `paused: false`
5. `sync-queue-to-state.sh`
6. **Drain stale PRs** (see below) if `state.prUrls` has open PRs for `completedIssues`
7. Enter issue loop until queue empty or hard stop

Log progress to `runs/issue-<N>.md` (or `.qa/queue/runs/` when using queue dir). **No mid-loop chat reports.**

## Drain stale PRs (start + between issues)

Before picking a new issue, ensure merged work is on `main`:

```bash
gh pr list --repo <owner/repo> --state open --json number,baseRefName,headRefName,mergeable
```

For each open PR linked in `state.prUrls` (oldest / lowest base first):

- If `baseRefName` ≠ default branch → merge blocking base PRs first (stacked PRs)
- Run `@pr-merge-safe merge` on that PR
- On **MERGED**: `git checkout main && git pull`
- On **NEEDS_HUMAN** / **BLOCKED**: hard stop; label `agent-blocked`; report

## Branch strategy

| Case | Base branch |
|------|-------------|
| First issue or `main` has all deps | `main` |
| Issue depends on unmerged prior work | Prefer **sequential merges on `main`** — avoid long stacked PR chains |
| Existing stacked PR | Merge stack bottom-up before new work |

After each merge, **new issues branch from updated `main`**, not from another issue branch (unless issue body requires stacked PR — then merge stack in order).

## State

Extends `@ecc-runner` state. Key fields:

| Field | Loop-specific |
|-------|----------------|
| `runMode` | `"loop"` |
| `prUrls` | `{ "<issueN>": "https://..." }` |
| `mergedIssues` | issue numbers with confirmed merge |
| `phase` | include `merge`, `babysit` |

See [references/state-schema.md](references/state-schema.md).

## Hard stops

Same as `@ecc-runner`, plus:

| Stop | Action |
|------|--------|
| Merge blocked (protection, conflicts, human review) | `needs-human`; report; do not skip issue silently |
| PR open but verify never passed | Do not merge; fix on branch |
| Secure-by-Default Coverage FAIL (Critical checklist violation: F-03, B-01, B-04, B-07, B-08, B-09, P-04) | `agent-blocked`; fix on branch; do not merge |
| `main` pull fails after merge | Report; pause loop |

Resume: `ecc-runner-loop continue` or `@ecc-runner-loop`.

## Flow control

| Command | Action |
|---------|--------|
| `ecc-runner-loop continue` | Resume loop from `state.json` |
| `ecc-runner-loop pause` | Stop after current phase; `paused: true` |
| `ecc-runner-loop skip` | Release lock, defer issue, continue |
| `ecc-runner-loop status` | Queue + phase snapshot |

German triggers: `alles durchziehen`, `issues komplett abarbeiten`, `merge und weiter`.

## Issue complete (loop)

1. `@pr-merge-safe merge` → **MERGED**
2. `git checkout main && git pull`
3. `mergedIssues` += N; `completedIssues` += N; store merge commit in run log
4. `gh issue comment` with PR + merge SHA
5. `agent-done`, remove `agent-in-progress`
6. `sync-queue-to-state.sh`
7. **Context gate:** if queue remaining and (issues merged this session ≥ 3 **or** context feels heavy) → run `@strategic-compact` (same session) **or** `@handoff` (session must end) — **do not** set `paused: true`
8. **Next issue immediately** — no user prompt

## Reporting

See [references/reporting.md](references/reporting.md). One message at loop end:

```markdown
## ECC Runner Loop — complete | paused

**Processed:** #1 ✓ merged, #2 ✓ merged, …
**Merged PRs:** …
**Stopped at:** #N — phase — reason (if paused)
**Queue remaining:** …
**Resume:** `@ecc-runner-loop continue`
```

## Guardrails

- Never skip verify/review/ecc-check to “save time”
- Never stop after one issue asking user to merge
- Never start next issue while prior PR is still open (unless actively babysitting that PR in the same phase)
- **Never pause the queue for context** — use `@strategic-compact` or `@handoff` (see Context continuity)
- **`@typed-strict` / `@test-gate`:** inherited via `@implement` → `@verify-ticket` → `@review-ticket` / `@ecc-check` Phase A — FAIL/CHANGES_REQUESTED if touched paths still have type escape hatches or test-gate FAIL
- UI/errors Deutsch; commits English
- Read `AGENTS.md` / `.qa/project.yaml` checks before merge

## Additional resources

- [references/commands.md](references/commands.md)
- [references/reporting.md](references/reporting.md)
- [references/state-schema.md](references/state-schema.md)
- [references/session-continuity.md](references/session-continuity.md)
- [references/merge-gate.example.yaml](references/merge-gate.example.yaml)
- Parent queue scripts: `~/.claude/skills/ecc-runner/`
