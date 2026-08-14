---
name: verify-ticket
description: >-
  Technical ticket verification after implementation: runs project checks, validates
  diff against acceptance criteria, confirms build and tests pass. Use after @implement
  and before /review-ticket, or when user says verify ticket or validate implementation.
disable-model-invocation: true
---

# Verify Ticket

Technical verification that the ticket is **built and testable**. Not browser UX (use `@verify-ui`) and not code quality audit (use `@review-ticket`).

## Pipeline position

```
@pingpong-solution  →  @implement  →  @verify-ticket  →  @composition-gate  →  @verify-ui  →  @review-ticket
```

This skill **implements** the project-specific subset of `@verification-loop` (build + tests + acceptance + diff secrets). Before PR, run `@ecc-check` for the full gate.

## Global helper skills (ECC, `~/.claude/skills/`)

| Helper | Trigger in verify-ticket |
|--------|--------------------------|
| `@test-gate` | **Required** — deterministic lint/tsc/build/RG (depth=standard); never claim PASS without it |
| `@foundations` | Hoare pass — map acceptance Preconditions/Happy Path/Edge Cases to diff + tests; flag `hoare:` gaps |
| `@verification-loop` | Legacy alias — prefer `@test-gate` + `@ecc-check` for ship |
| `@security-review` | Diff touches auth, UGC, storage, env, or user input — extend § Security scan |
| `@typed-strict` | Covered by `@test-gate`; FAIL if Boy Scout incomplete |

## Checklist

```
- [ ] Load .qa/acceptance/<slug>.md from current implement run
- [ ] Load AGENTS.md, README, .qa/project.yaml
- [ ] Identify changed files (git diff)
- [ ] Run @test-gate depth=standard (PASS required)
- [ ] Confirm unit tests cover behavior changes (if testRun ran / acceptance needs it)
- [ ] Match diff to acceptance checkboxes (Happy Path + Edge Cases)
- [ ] Preconditions in acceptance satisfied or N/A for tests run
- [ ] No secrets in diff (also covered by test-gate rgSecretsDiff)
- [ ] Report PASS / FAIL
```

## Acceptance matching

| Source | Match |
|--------|-------|
| `.qa/acceptance/<slug>.md` | **Primary** — Preconditions + Happy Path (postconditions) + Edge Cases vs diff + tests |
| Git diff | Scope not wildly exceeding acceptance Intent |
| Issue `## Scope` (In/Out) | When the source issue follows `@issue-contract`, diff paths must stay within `In:` (flag `Out:` touches as scope violations) |
| User message | Fallback only if acceptance artifact missing |

If acceptance file is missing but `/implement` was expected, report **FAIL** on process and list gap.

Flag **scope creep** (unrelated files) and **gaps** (AC checkbox not implemented).

**Side-effect cardinality (P-06):** If the diff enqueues, mails, posts, webhooks, or provisions from a bulk/recipient loop, Happy Path must state **once per event vs once per recipient**. A checkbox like “type X → channel” without cardinality is a **process FAIL** when the producer is bulk. Trace producer → outbox/worker → send — do not verify files in isolation. Full hop-chain gate (including non-outbox paths) is **`@composition-gate`** after this skill; FLAGGED findings there must be fixed before review.

## Checks (`@test-gate`)

Invoke **`@test-gate`** with **`depth: standard`**. Do not hand-roll tsc/lint lists — see `~/.claude/skills/test-gate/SKILL.md`.

**Never claim PASS without `@test-gate` PASS.**

## Security scan (diff)

- Covered primarily by `@test-gate` (secureByDefault + secrets RG)
- Extra: no `.env` staged; user input validated if touched
- Worker/outbox/bulk-send in diff → B-10/P-06 Manual Gate (checklist); do not PASS if fan-out or non-atomic claim is untested
- Narrative OWASP depth → `@security-review` when auth/UGC/upload in scope

## Report format

```markdown
## Ergebnis
PASS | FAIL

## Checks (@test-gate)
- Depth: standard
- Result: PASS | FAIL
- (embed test-gate matrix)

## Acceptance
| Criterion | Status |
|-----------|--------|

## Diff summary
- Files changed: N
- …

## Gaps / scope issues
Keine.

## UI verification
Pending @verify-ui | N/A (no UI changes)

## Empfehlung
Proceed to @composition-gate / @verify-ui / @review-ticket | Fix first: …
```

## When FAIL

List blockers only. Do not fix unless user asks.
