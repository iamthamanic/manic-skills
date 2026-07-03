---
name: audit-changes
description: >-
  Fast-lane audit of scoped changes (uncommitted, since commit, PR, or path/keyword):
  diff-scoped checks, security scan, SOLID/KISS/DRY review lite. Not a ship gate —
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
- [ ] Step 3: Phase A — deterministic checks (depth-dependent)
- [ ] Step 4: Phase B — security diff scan
- [ ] Step 5: Phase C — review lite (SOLID, KISS, DRY, maintainability)
- [ ] Step 6: Phase D — optional tooling (snyk, agentshield, verify-ui)
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

1. `.qa/project.yaml` → `checksCommand`, `appRoot`, `language`
2. `AGENTS.md` → validation commands, non-negotiables, security checklist
3. `package.json` scripts → `checks`, `verify`, `lint`, `test`, `build`
4. Git diff file list → infer backend / frontend / both

## Depth modes

User may say `depth: quick` (default), `depth: standard`, or `depth: full`.

### `quick` (default)

- Phase A: **diff-scoped** — tsc/lint only for packages touched; skip full frontend `build` unless only frontend changed and no `tsc` script
- Phase B: secrets + `.env` + project RG gates on changed paths ([references/project-rg-gates.md](references/project-rg-gates.md))
- Phase C: static diff read + findings table; invoke `@review-ticket` **lite** (no subagent unless auth/API in diff)
- Phase D: skipped unless `.cursor/` in diff

### `standard`

- Phase A: full package checks per touched area (AGENTS.md / `checksCommand`)
- Phase B: full security diff scan + `@security-review` checklist if auth/UGC/API/upload
- Phase C: `@review-ticket` on diff; `@ponytail-review` if diff > 150 lines or new abstractions
- Phase D: AgentShield if `.cursor/` exists **and** changed; `npm audit --audit-level=high` if no snyk

### `full`

- Same as `standard` plus:
- Optional `@verify-ui` if UI paths in diff and user did not skip
- Optional `@verify-ticket` if `.qa/acceptance/*.md` matches scope
- Does **not** replace `@ecc-check` — report must say "run @ecc-check before ship"

## Phase A — Deterministic checks

Discover command (priority):

1. `.qa/project.yaml` → `checksCommand`
2. `package.json` → `checks` or `verify`
3. `AGENTS.md` § validation
4. Fallback: `npm run build && npm test`

**Diff-scoped execution** (quick mode):

| Changed paths | Run |
|---------------|-----|
| `backend/**` only | backend checks from AGENTS.md |
| `frontend/**` only | `tsc --noEmit` (+ lint if fast) |
| both | both, parallel when possible |
| `.qa/**`, docs only | skip build; RG gates only |

**Never claim CLEAN if Phase A failed** on standard/full. On quick: tsc/lint failure → **BLOCK**.

Run project RG gates from [references/project-rg-gates.md](references/project-rg-gates.md) on changed paths only.

## Phase B — Security diff scan

Always on scoped files:

- [ ] No secrets, tokens, API keys in diff (`sk-`, `api_key`, `password=`, `.env` staged)
- [ ] No auth middleware disabled in diff
- [ ] New API routes: auth + input validation visible in diff
- [ ] Tenant guards if project uses multi-tenancy (e.g. `organizationId` in AGENTS.md)
- [ ] No `dangerouslySetInnerHTML` with user data (frontend)
- [ ] Upload/document paths: authenticated + scoped access

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

Do **not** run `npx shimwrappercheck` by default — use project `checks`/`verify` + `@review-ticket`. Shim remains for legacy projects only.

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
| `--ui` or `depth: full` + UI in diff | `@verify-ui` |
| `.qa/acceptance/<slug>.md` in scope | `@verify-ticket` (acceptance section only) |
| `.cursor/` changed | AgentShield (required) |
| `snyk` configured | dependency scan |

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
| `@ponytail-review` | Large diff, over-engineering |
| `@review-ticket` | standard/full depth Phase C |
| `@verify-ui` | `--ui` or full + UI paths |
| `@ecc-check` | Recommended in report when WARN or before ship |
