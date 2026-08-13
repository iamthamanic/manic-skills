---
name: audit-changes
description: >-
  Fast-lane audit of scoped changes (uncommitted, since commit, PR, or path/keyword):
  @test-gate (deterministic), security scan, SOLID/KISS/DRY review lite. Not a ship gate —
  use @ecc-check before commit/PR. Triggers: audit changes, quick audit, check
  changes, audit since commit, audit time management.
---

# Audit Changes

**Fast lane** for security, maintainability, and validation on a **scoped diff** — without the full ECC ship pipeline.

| | `@audit-changes` | `@ecc-check` |
|---|---|---|
| **Goal** | "Should I worry about what I changed?" | "May I ship?" |
| **Exit** | CLEAN / WARN / BLOCK | READY / BLOCKED |
| **UI / Playwright** | Opt-in (`depth: full` or `@verify-ui`) | Required when UI in diff |
| **Acceptance** | Optional | Required when `.qa/acceptance/` exists |
| **Fix loop** | Report only | Retries until READY or BLOCKED |
| **AgentShield** | Only if `.cursor/` in scope | Always when `.cursor/` exists |

## When to use

- After fast coding sessions without `@implement` → `@verify-ticket` → `@review-ticket`
- Before deciding to commit (sanity check, not ship gate)
- Scoped review: `audit changes in time management`, `audit since last commit`
- Mid-session: SOLID, security, tenant guards, project non-negotiables

## When **not** to use

- Before merge / PR → `@ecc-check`
- Browser UX proof → `@verify-ui`
- Full repo bloat hunt → `@ponytail-audit`
- Issue queue → `@ecc-runner`

## Workflow checklist

```
Audit Changes Progress:
- [ ] Step 1: Resolve scope (uncommitted | since-commit | pr | path/keyword)
- [ ] Step 2: Load project context (project.yaml, AGENTS.md)
- [ ] Step 3: Phase A — @test-gate (depth-dependent)
- [ ] Step 4: Phase B — security diff scan (extra narrative; RGs already in test-gate)
- [ ] Step 5: Phase C — review lite (SOLID, KISS, DRY, maintainability)
- [ ] Step 6: Phase D — optional tooling (snyk, agentshield, web-design-guidelines, verify-ui)
- [ ] Step 7: Report CLEAN | WARN | BLOCK
```

## Step 1 — Resolve scope

Read [references/scope-resolution.md](references/scope-resolution.md).

**Priority** (first match wins unless user overrides):

| Scope | Git command / method |
|-------|----------------------|
| User path or keyword | `rg --files -g '*keyword*'`, glob paths, `git log --oneline -- <paths>` |
| `uncommitted` (default) | `git diff` + `git diff --cached` |
| `since-commit` | `git diff HEAD~1..HEAD` or user-specified ref |
| `pr` | `gh pr diff` or `git diff main...HEAD` |
| `branch` | `git diff $(git merge-base main HEAD)..HEAD` |

Record in report: scope mode, base ref, file count, approximate LOC.

## Step 2 — Project context

Load in order:

1. `.qa/project.yaml` → `testGate`, `checksCommand`, `appRoot`, `typedStrict`, `security`
2. `AGENTS.md` → validation commands, non-negotiables, security checklist
3. `package.json` scripts → `checks`, `verify`, `lint`, `test`, `build`
4. Git diff file list → infer backend / frontend / both

## Depth modes

User may say `depth: quick` (default), `depth: standard`, or `depth: full`.

### `quick` (default)

- Phase A: **`@test-gate` depth=quick** (diff-scoped tools + typed-strict + critical RGs)
- Phase B: extra security narrative if auth/API in diff (test-gate already ran secureByDefault RGs)
- Phase C: static diff read + findings table; invoke `@review-ticket` **lite** (no subagent unless auth/API in diff)
- Phase D: skipped unless `.cursor/` in diff

### `standard`

- Phase A: **`@test-gate` depth=standard**
- Phase B: full security diff scan + `@security-review` checklist if auth/UGC/API/upload
- Phase C: `@review-ticket` on diff; `@ponytail-review` if diff > 150 lines or new abstractions
- Phase D: AgentShield if `.cursor/` exists **and** changed

### `full`

- Phase A: **`@test-gate` depth=full**
- Same as `standard` plus:
- Optional `@web-design-guidelines` then `@verify-ui` if UI paths in diff and user did not skip
- Optional `@verify-ticket` if `.qa/acceptance/*.md` matches scope
- Does **not** replace `@ecc-check` — report must say "run @ecc-check before ship"

## Phase A — Deterministic checks (`@test-gate`)

Invoke **`@test-gate`** with the resolved depth. Do not duplicate lint/tsc/catalog logic here — see `~/.claude/skills/test-gate/SKILL.md`.

**Never claim CLEAN if Phase A / test-gate failed** on standard/full. On quick: test-gate FAIL → **BLOCK**.

Embed the Test Gate matrix in the audit report.

## Phase B — Security diff scan

Always on scoped files:

- [ ] No secrets, tokens, API keys in diff (`sk-`, `api_key`, `password=`, `.env` staged)
- [ ] No auth middleware disabled in diff
- [ ] New API routes: auth + input validation visible in diff
- [ ] Tenant guards if project uses multi-tenancy (e.g. `organizationId` in AGENTS.md)
- [ ] No `dangerouslySetInnerHTML` with user data (frontend)
- [ ] Upload/document paths: authenticated + scoped access

**Secure-by-Default Probe (if `AGENTS.md` has a Security Checklist block or `.qa/project.yaml` → `security.checklist: secure-by-default`):**

Run the RG-Probes from `~/.claude/skills/security-review/references/secure-by-default-checklist.md` against changed paths. Apply only the zutreffende Sektion:

| Diff scope | Sektion(en) prüfen |
|------------|--------------------|
| Frontend-only | Frontend F-01…F-05 |
| Backend-only | Backend B-01…B-09 |
| Fullstack | Frontend + Backend + Practical Habits P-01…P-05 |
| User/permission admin, bundles/roles, route→permission resolvers | **B-07 / B-08 / B-09 manual gate** (checklist) — RG alone is not PASS |

Probes (diff-scoped) — canonical list in `secure-by-default-checklist.md` (includes B-07/B-08/B-09 heuristics):

```bash
# F-03: Secrets in localStorage
rg "localStorage\.(set|get)Item\(['\"](token|secret|password|api[_-]?key)" frontend/src
# F-05: API keys in client bundle
rg "NEXT_PUBLIC_.*(SECRET|KEY|PASSWORD|TOKEN)" frontend/ --type ts
# B-04: SQL injection patterns
rg "query\(\`.*\$\{" backend --type ts
# P-02: Sensitive data in logs/errors
rg "console\.(log|error)\(.*(password|secret|token|api[_-]?key)" backend --type ts
# P-03: Insecure cookies
rg "Set-Cookie" backend --type ts | rg -v "HttpOnly|Secure|SameSite"
# P-05: Rate limiting disabled
rg "rateLimit.*disable|skipRateLimit|@ts-ignore.*rate" backend --type ts
# B-07 / B-08 / B-09 heuristics (then run manual gate)
rg -n "bundles|user_bundles|assignBundle|roles|filterAssignable" --glob '**/api/**/*' -g '!**/node_modules/**'
rg -n "resolve.*[Pp]ermission|\.view[\"']" --glob '**/*{permission,auth,middleware}*' -g '!**/node_modules/**'
rg -n "x-user-id|x-user-email" --glob '**/*.{ts,js}' -g '!**/node_modules/**'
```

Each probe with a match → Critical/Important finding (per Severity-Mapping in the checklist). Critical matches (F-03, B-01, B-04, B-07, B-08, B-09, P-04) → **BLOCK**. Missing applicable items → at least **WARN**. Catalog-only mitigation for assignment (“edit only on admin bundle”) → **BLOCK** under B-07.
**AgentShield** (not app code):

```bash
npx ecc-agentshield scan --path .cursor
```

Run when `.cursor/` is in scope (standard/full) or user requests. Block on critical/high.

**Optional dependency scan** (Phase D, standard+):

```bash
npm run snyk:test          # if script exists
npx snyk test --severity-threshold=high  # if snyk in devDependencies
npm audit --audit-level=high             # fallback
```

Do **not** run shimwrappercheck AI review. Prefer `@test-gate` (scripts runner). Optional: shim MCP `run_checks` with `noAiReview: true` only if `testGate.runner: shim`.

## Phase C — Review lite

Read changed files. Apply `@foundations` tags where relevant:

| Concern | Tag | Check |
|---------|-----|-------|
| Module boundaries | `parnas:` | Cross-module imports, leaky abstractions |
| Contracts | `liskov:` | Broken invariants, adapter inconsistency |
| Preconditions | `hoare:` | Missing validation, untested edge cases |
| Complexity | `brooks:` | Accidental abstraction, ceremony |
| DRY | — | Copy-paste logic in diff |
| KISS | — | Simpler stdlib/native alternative exists |

Invoke helpers conditionally:

| Trigger | Helper |
|---------|--------|
| Auth, API, uploads, secrets | `@security-review` (checklist sections only) |
| Diff > 150 LOC or new abstraction | `@ponytail-review` |
| Complex logic, regression risk | `@review-bugbot` subagent |
| Large diff, architecture | `@foundations` |

Verdict mapping:

- No critical/high → contributes to **CLEAN**
- Medium findings only → **WARN**
- Critical/high (security, tsc fail, secrets) → **BLOCK**

## Phase D — Optional

| Flag / condition | Action |
|------------------|--------|
| `--ui` or `depth: full` + UI in diff | `@web-design-guidelines` on touched UI files, then `@verify-ui` |
| `.qa/acceptance/<slug>.md` in scope | `@verify-ticket` (acceptance section only) |
| `.cursor/` changed | AgentShield (required) |
| `snyk` configured | dependency scan |

Do **not** invoke `@frontend-design` / `@design-taste-frontend` / `@imagegen-frontend-mobile` here — those are create-time skills (`@implement`).

## Exit states

| State | Meaning | Next step |
|-------|---------|-----------|
| **CLEAN** | Checks pass, no critical findings | Continue coding or run `@ecc-check` before ship |
| **WARN** | Works but gaps (tests, medium security, style) | Fix or acknowledge; `@ecc-check` before PR |
| **BLOCK** | Secrets, build fail, critical security | Fix before commit |

**WARN is allowed to continue work.** Only **BLOCK** means do not commit without fixes.

## Report

Use [references/report-template.md](references/report-template.md).

Optional log: `.qa/runs/audit-changes-<date>.md`

## Integration map

```
Fast sessions:     @audit-changes (quick)
Before commit:     @audit-changes (standard) → optional @ecc-check
Before PR/merge:   @ecc-check (required ship gate)
```

| Old habit | New habit |
|-----------|-----------|
| Skip all verification | `@audit-changes` quick after sessions |
| `npm run checks` for sanity | `@audit-changes` (discovers project command) |
| Ship without pipeline | **Still wrong** — need `@ecc-check` |

## Global helper skills

| Helper | When |
|--------|------|
| `@foundations` | Architecture findings in Phase C |
| `@security-review` | Auth, UGC, storage, env in diff |
| `@test-gate` | Phase A — deterministic tools/scripts (required) |
| `@typed-strict` | Invoked inside `@test-gate`; also boy-scout reminder |
| `@ponytail-review` | Large diff, over-engineering |
| `@review-ticket` | standard/full depth Phase C |
| `@web-design-guidelines` | `--ui` or full + UI paths — static a11y/UX audit before browser proof |
| `@verify-ui` | `--ui` or full + UI paths — after guidelines when both run |
| `@ecc-check` | Recommended in report when WARN or before ship |
