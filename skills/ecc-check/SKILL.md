---
name: ecc-check
description: >-
  ECC quality gate loop for the current ticket: @test-gate (deterministic
  tools/scripts), @review-ticket, AgentShield; fix findings until READY for
  @commit-pr-safe or @commit-push-safe. Use when user says ecc-check,
  /ecc-check, ecccheck, merge-ready, quality gate, or before ship/PR.
disable-model-invocation: true
---

# ECC Check

Deterministic checks via **`@test-gate`** + ECC code review + AgentShield — **no shimwrappercheck AI review**.

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

- Fast mid-session sanity check → `@audit-changes` (not a ship gate)
- Full issue queue → `@ecc-runner` (orchestrator; calls this skill per issue)
- Browser UX → `@verify-ui` (run inside loop if UI files changed; after `@web-design-guidelines`)
- Appwrite deploy / release → `npm run checks` (legacy shim) + cloud verify scripts

## Project config (read first)

1. `.qa/project.yaml` → `testGate`, `checksCommand`, `checksSnippet`, `acceptanceDir`, **`typedStrict.languages`**, `security`
2. `.qa/runner-profile.yaml` → `checksSnippet`, retry hints
3. `AGENTS.md` → branch rules, desktop-first defaults
4. Git diff + `.qa/acceptance/<slug>.md` if present

Phase A delegates stack resolution + tool execution to **`@test-gate`** (which may auto-detect typedStrict / stack).

## Pipeline (fix loop)

Execute phases **in order**. On FAIL: fix scoped issues → rerun **that phase** until pass or retry limit.

```
Phase A: @test-gate depth=standard (tools/scripts + typed-strict + secureByDefault RGs)
Phase B: @verify-ticket (acceptance vs diff) — optional if no acceptance file
Phase C: @review-ticket (+ @review-bugbot if non-trivial diff)
Phase D: AgentShield (if .cursor/ exists)
Phase E: @web-design-guidelines then @verify-ui (if UI paths in diff)
Phase E2: @memory-live-doc mode=apply (if material changes since checkpoint)
Phase F: Report READY | BLOCKED
```

### Phase E2 — Living documentation (conditional)

If material uncommitted/committed changes since `.project-memory/checkpoint.json` (or memory missing on a material ticket):

1. Run `@memory-live-doc` with **`mode=apply`** (auto-write; `review_status: needs-review`)
2. Do **not** block READY forever on review — proceed with docs marked needs-review
3. Report doc health in the READY/BLOCKED summary (`needs-review` count, screenshot gaps)

Skip when changes are non-material (format/lint/types/lockfile/tests-only/typo docs/pure refactor).
### Phase F — Ship readiness notes (Browo HR)

When the diff includes `backend/prisma/migrations/**` or deploy/infra paths, the READY report must mention:

- Merge order if part of a stacked PR series
- Post-merge: `prisma migrate deploy` + any backfill scripts on hr-dev
- **Merged ≠ deployed** — verify deploy workflow / server if user reports 500s

### Phase A — Deterministic checks (`@test-gate`)

Invoke **`@test-gate`** with **`depth: standard`** (or `full` if user/CI requests).

Do **not** re-implement lint/tsc/prettier/prisma/RG lists here — follow `~/.claude/skills/test-gate/SKILL.md`.

- **PASS** → continue Phase B
- **FAIL** → fix scoped issues → re-run `@test-gate` (max 3 rounds) → else **BLOCKED**
- Include the Test Gate report matrix in the ECC summary (typedStrict + secureByDefault rows are part of test-gate)

Optional legacy equivalent (only if test-gate skill unavailable): `checksCommand` / `npm run verify` + `@typed-strict` + secure-by-default RGs — prefer `@test-gate`.

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

If diff touches UI paths (`src/components`, `pages`, `hooks`, layouts, styles, etc.):

1. `@web-design-guidelines` on touched UI files (static a11y/UX checklist)
2. `@verify-ui` (browser proof) — or document skip

Do **not** run `@frontend-design` / `@design-taste-frontend` / `@imagegen-frontend-mobile` here — create-time only (`@implement`).

If no UI paths → skip Phase E.

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

### Phase A (@test-gate)
- Depth: standard | full
- Result: PASS | FAIL (embed test-gate matrix)
- typedStrict / secureByDefault: as reported by @test-gate

### Phase C (review)
- Verdict: ACCEPT | CHANGES_REQUESTED

### Phase D (AgentShield)
- Grade: … | skipped

### Phase E2 (memory-live-doc)
- Result: applied | skipped | n/a
- needs-review: N | screenshot gaps: …

### Ship
Ready for: @commit-pr-safe | @commit-push-safe | blocked
```

## Integration map

| Old | New |
|-----|-----|
| `npm run checks` + Shim AI Review | `@test-gate` + `@review-ticket` |
| Ad-hoc tsc/lint in Phase A | `@test-gate` (single deterministic runner) |
| `@ecccheck` | `@ecc-check` (this skill) |
| `@prepare-deploy-pr` | `@commit-pr-safe` |
| Shim `VERDICT: ACCEPT` | `@review-ticket` ACCEPT |

Shim remains for **Appwrite deploy shims** and optional legacy full gate.

## Legacy alias

`@ecccheck` is deprecated — use `@ecc-check`.
