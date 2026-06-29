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
@pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket
```

This skill **implements** the project-specific subset of `@verification-loop` (build + tests + acceptance + diff secrets). Before PR, run `@ecc-check` for the full gate.

## Global helper skills (ECC, `~/.cursor/skills/`)

| Helper | Trigger in verify-ticket |
|--------|--------------------------|
| `@foundations` | Hoare pass — map acceptance Preconditions/Happy Path/Edge Cases to diff + tests; flag `hoare:` gaps |
| `@verification-loop` | Superset checklist — suggest after PASS if user prepares PR |
| `@security-review` | Diff touches auth, UGC, storage, env, or user input — extend § Security scan |

## Checklist

```
- [ ] Load .qa/acceptance/<slug>.md from current implement run
- [ ] Load AGENTS.md, README, .qa/project.yaml
- [ ] Identify changed files (git diff)
- [ ] Run checks command (npm run checks or project equivalent)
- [ ] Confirm unit tests cover behavior changes
- [ ] Match diff to acceptance checkboxes (Happy Path + Edge Cases)
- [ ] Preconditions in acceptance satisfied or N/A for tests run
- [ ] No secrets in diff
- [ ] Report PASS / FAIL
```

## Acceptance matching

| Source | Match |
|--------|-------|
| `.qa/acceptance/<slug>.md` | **Primary** — Preconditions + Happy Path (postconditions) + Edge Cases vs diff + tests |
| Git diff | Scope not wildly exceeding acceptance Intent |
| User message | Fallback only if acceptance artifact missing |

If acceptance file is missing but `/implement` was expected, report **FAIL** on process and list gap.

Flag **scope creep** (unrelated files) and **gaps** (AC checkbox not implemented).

## Checks command

Priority:

1. `.qa/project.yaml` → `checksCommand`
2. `package.json` → `checks`
3. `AGENTS.md` validation section
4. `npm run build && npm test`

Run from workspace root if scripts use `--prefix`.

**Never claim PASS without running checks successfully.**

## Security scan (diff)

- No `.env`, keys, tokens committed
- No hardcoded secrets
- User input paths validated if touched

## Report format

```markdown
## Ergebnis
PASS | FAIL

## Checks
- Command: `…`
- Exit: 0 | non-zero

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
Proceed to @verify-ui / @review-ticket | Fix first: …
```

## When FAIL

List blockers only. Do not fix unless user asks.
