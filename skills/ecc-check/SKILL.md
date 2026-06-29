---
name: ecc-check
description: >-
  ECC quality gate loop for the current ticket: run npm run verify (or project
  checksCommand), @review-ticket, AgentShield; fix findings until READY for
  @commit-pr-safe or @commit-push-safe. Use when user says ecc-check,
  /ecc-check, ecccheck, merge-ready, quality gate, or before ship/PR.
disable-model-invocation: true
---

# ECC Check

Deterministic checks + ECC code review + AgentShield — **no shimwrappercheck AI review**.

Replaces `npm run checks` + Shim `VERDICT: ACCEPT` for normal desktop/frontend tickets.

## Exit states

| State | Meaning | Next step |
|-------|---------|-----------|
| **READY** | All gates passed | `@commit-pr-safe` or `@commit-push-safe` |
| **BLOCKED** | Retries exhausted or hard blocker | Report blockers; do **not** commit/push |

## When to use

- After `@implement`, before commit/PR
- User: `ecc-check`, `/ecc-check`, `ecccheck`, `merge-ready`, `quality gate`
- `@ecc-runner` batch: quality gate phase before commit/PR

## When **not** to use alone

- Full issue queue → `@ecc-runner` (orchestrator; calls this skill per issue)
- Browser UX → `@verify-ui` (run inside loop if UI files changed)
- Appwrite deploy / release → `npm run checks` (legacy shim) + cloud verify scripts

## Project config (read first)

1. `.qa/project.yaml` → `checksCommand`, `checksSnippet`, `acceptanceDir`
2. `.qa/runner-profile.yaml` → `checksSnippet`, retry hints
3. `AGENTS.md` → branch rules, desktop-first defaults
4. Git diff + `.qa/acceptance/<slug>.md` if present

Default checks command when unset: `npm run verify`

## Pipeline (fix loop)

Execute phases **in order**. On FAIL: fix scoped issues → rerun **that phase** until pass or retry limit.

```
Phase A: Deterministic checks (checksCommand)
Phase B: @verify-ticket (acceptance vs diff) — optional if no acceptance file
Phase C: @review-ticket (+ @review-bugbot if non-trivial diff)
Phase D: AgentShield (if .cursor/ exists)
Phase E: @verify-ui (if src/components|pages|hooks UI paths in diff)
Phase F: Report READY | BLOCKED
```

### Phase A — Deterministic checks

```bash
npm run verify -- --frontend   # desktop / frontend (default)
npm run verify -- --backend    # functions
npm run verify                 # both
```

**Fix loop:** rerun failing step after each fix.

### Phase B — Verify ticket (acceptance)

Invoke `@verify-ticket` when `.qa/acceptance/*.md` exists.

### Phase C — Code review

Invoke `@review-ticket` until **ACCEPT**. Do **not** use Shim AI review.

### Phase D — AgentShield

```bash
npx ecc-agentshield scan --path .cursor
```

Block on critical/high. If CLI unavailable → **BLOCKED**.

### Phase E — UI verification (conditional)

If diff touches UI paths → `@verify-ui` or document skip.

### Phase F — Ship (only on explicit user request)

| Intent | Skill |
|--------|-------|
| Commit + push + PR | `@commit-pr-safe` |
| Commit + push only | `@commit-push-safe` |
| PR exists, CI red | `@babysit` |
| PR exists, review + merge | `@pr-merge-safe` or `@pr-merge-safe merge` |
| Architecture / acceptance contracts | `@foundations` (reference) |

**Never** ship on main/master. **Never** `--no-verify`.

## Retry limits

| Phase | Max rounds |
|-------|------------|
| A checks | 3 |
| C review | 2 |
| D AgentShield | 2 |
| Same root error | 2 → BLOCKED |

Optional log: `.qa/runs/ecc-check-<date>.md`

## Report format

```markdown
## ECC Check — READY | BLOCKED

### Phase A (verify)
- Command: `…`
- Result: PASS | FAIL

### Phase C (review)
- Verdict: ACCEPT | CHANGES_REQUESTED

### Phase D (AgentShield)
- Grade: … | skipped

### Ship
Ready for: @commit-pr-safe | @commit-push-safe | blocked
```

## Integration map

| Old | New |
|-----|-----|
| `npm run checks` + Shim AI Review | `npm run verify` + `@review-ticket` |
| `@ecccheck` | `@ecc-check` (this skill) |
| `@prepare-deploy-pr` | `@commit-pr-safe` |
| Shim `VERDICT: ACCEPT` | `@review-ticket` ACCEPT |

Shim remains for **Appwrite deploy shims** and optional legacy full gate.

## Legacy alias

`@ecccheck` is deprecated — use `@ecc-check`.
