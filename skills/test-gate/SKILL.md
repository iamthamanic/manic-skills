---
name: test-gate
description: >-
  Deterministic quality gate: run tools/scripts (lint, tsc, prettier, tests,
  prisma, security-gate, rg probes) by exit code — never LLM judgment. Stack-
  agnostic via project.yaml + auto-detect. Bootstraps missing lint/typecheck
  for JS/TS; reports language/app profile for non-JS stacks. Use as Phase A
  for @ecc-check, @audit-changes, @verify-ticket; before claim-done in
  @implement; or when user says test-gate, /test-gate, det-gate, run checks,
  deterministic gate.
---

# Test Gate

**Hard gate only.** Execute tools and scripts; map exit codes → PASS | FAIL.
Do **not** read code and invent a quality verdict. Do **not** run AI review
(shimwrappercheck AI, narrative SOLID scoring, etc.).

Works on **any tech stack**: resolve checks from config + detection, then run
only applicable ones. For **JS/TS**: missing lint or typecheck → **bootstrap
then re-run** (do not SKIP forever and claim PASS). For **non-JS/TS**: do not
force Node lint/tsc; run language-appropriate checks and report the profile.

## Exit states

| State | Meaning | Next step |
|-------|---------|-----------|
| **PASS** | All required checks exit 0 / RG matches = 0 | Continue caller skill |
| **FAIL** | Any required check non-zero or critical RG hit | Fix → re-run; caller must not claim READY/ACCEPT/PASS |
| **SKIPPED** (individual check) | Tool/config absent **and** out of scope / non-JS equivalent N/A | OK if optional; document reason in report |

## Iron rules

1. **Exit code is law** — never reinterpret FAIL as PASS. After bootstrap, new checks are required; FAIL if they fail.
2. **No AI review** inside this skill (`aiReview`, explanation, fallow → out of scope).
3. Prefer project **`checksCommand`** / package scripts over reinventing commands.
4. Diff-scope: only packages/paths touched (unless `depth: full` or user forces both).
5. If `.qa/project.yaml` → `testGate` exists, honor it; else auto-detect.
6. **JS/TS missing lint or typecheck** → bootstrap (minimal), update yaml/scripts, re-run in same invocation — never treat absence as optional PASS.
7. **Non-JS/TS primary language** → never force `eslint` / `tsc`; use stack-profiles + check-catalog for that language.

## When to use

| Trigger | Depth default |
|---------|---------------|
| User: `test-gate`, `/test-gate`, `det-gate`, `run checks` | `standard` |
| `@audit-changes` Phase A | user depth or `quick` |
| `@verify-ticket` checks | `standard` |
| `@ecc-check` Phase A | `standard` |
| `@implement` before claim-done | `quick` |
| `@commit-pr-safe` / `@commit-push-safe` if ecc skipped | `standard` |

## Pipeline (agent)

```
1. Resolve repo root + read config
2. Resolve depth (quick | standard | full)
3. Resolve changed paths (git diff)
4. Detect stack → PRIMARY_LANG + APP_KIND + profile + enabled checks
5. Bootstrap missing JS/TS gates (lint / typecheck) if needed → update yaml
6. Run each check (shell); record exit
7. Run @typed-strict on touched paths when language applies
8. Run secure-by-default RG probes if checklist active
9. Report PASS | FAIL + Language/app profile + bootstrap Notes
```

### Step 1 — Config sources (priority)

1. `.qa/project.yaml` → `testGate`, `checksCommand`, `checksSnippet`, `typedStrict`, `security`
2. `AGENTS.md` → validation / Pre-Commit commands, Non-Negotiables
3. Root + package `package.json` scripts (`verify`, `checks`, `lint`, `test`, `build`, `typecheck`)
4. Auto-detect via `scripts/detect-stack.sh` (this skill)
5. Profile defaults in [references/stack-profiles.md](references/stack-profiles.md)

Schema: [references/config-schema.md](references/config-schema.md).

### Step 2 — Depth

| Depth | Runs |
|-------|------|
| **quick** | typecheck + lint (touched pkgs) + `@typed-strict` (if TS/JS) + critical RG (secrets, any, project non-negotiables) — skip full build/test/audit unless only way to typecheck |
| **standard** | quick + build (if FE in scope) + tests if script exists + prisma validate (if prisma) + security-gate / AGENTS backend gates + npm/cargo/pip audit (warn→optional fail per yaml) + gitleaks if available |
| **full** | standard + semgrep if available + e2eCommand from yaml if set + optional complexity/architecture if configured |

Emphasize by **APP_KIND** (see [stack-profiles.md](references/stack-profiles.md) § Application types): e.g. SPA → build+unit+typed-strict+secrets; API → lint/typecheck+tests+security RG+audit; mobile → platform checks; monorepo → per-package.

### Step 3 — Scope from diff

```bash
git diff --name-only HEAD 2>/dev/null
git diff --cached --name-only
# branch mode: git diff $(git merge-base origin/develop HEAD 2>/dev/null || git merge-base origin/main HEAD)..HEAD --name-only
```

| Paths | Activate |
|-------|----------|
| `frontend/**`, `src/**` (FE), `app/**` (Next) | frontend package checks |
| `backend/**`, `server/**`, `api/**`, `supabase/functions/**` | backend package checks |
| `prisma/**` | prisma validate (+ generate if AGENTS says so) |
| `*.sh`, `scripts/**`, `deployment/**` | shellcheck if available |
| docs / `.qa` only | skip build; secrets + typed-strict only |
| both FE+BE | both packages |

### Step 4 — Resolve check set (language + app)

1. Run `bash scripts/detect-stack.sh` (or equivalent signals). Read `PRIMARY_LANG`, `APP_KIND`, `PROFILE`, `HAS_LINT`, `HAS_TYPECHECK`.
2. If `testGate.packages` / `testGate.always` / `testGate.never` in yaml → use that.
3. Else map profile → [references/stack-profiles.md](references/stack-profiles.md); intersect with [references/check-catalog.md](references/check-catalog.md).
4. Apply `testGate.never` and skip AI category always.
5. **If PRIMARY_LANG is not `js`/`ts`:** exclude Node lint/tsc unless a JS package is also in scope. Prefer language checks (ruff, go vet, cargo clippy, …).

**If `checksCommand` is set** and depth ≥ standard: run it **first** as the primary bundle. Still run `@typed-strict` (when TS/JS) + secure-by-default RG + AGENTS non-negotiable RGs that the bundle may not cover.

### Step 5 — Bootstrap missing JS/TS gates

**When:** primary (or in-scope package) language is JS/TS **and** lint **or** typecheck is absent.

**Detect absence**

| Gate | Present if any of |
|------|-------------------|
| **lint** | `npm run lint` / `lint` script; eslint config; biome; oxlint; `deno lint` (Deno package) |
| **typecheck** | `tsc --noEmit` usable via tsconfig; `vue-tsc` / `astro check`; package script `typecheck` / `type-check`; pyright N/A here |

**Do not** SKIP these as “optional” on a JS/TS project and claim PASS as if they ran.

**Bootstrap (minimal — see catalog § Bootstrap recipes)**

1. Prefer existing stack tooling (Biome if already partial; else ESLint flat config **or** `tsc --noEmit` via project `tsconfig`).
2. Add/update `package.json` scripts (`lint`, `typecheck`) with sensible defaults — do not over-engineer (no multi-plugin empires).
3. Write/update `.qa/project.yaml` `testGate` / `checksCommand` when the project uses that pattern.
4. **Re-run** the newly added checks in **this same** test-gate invocation (setup → execute → report).
5. Document auto-provisioned files/scripts in report **Notes**.
6. Exit codes still law: bootstrap success + check FAIL → overall **FAIL**.

Stack-agnostic: Vite+React example = `typescript` + eslint **or** `tsc --noEmit` via existing tsconfig. Respect AGENTS.md bans (e.g. no DaisyUI/Next when forbidden).

**Non-JS/TS:** skip this step; do not install eslint/tsc.

### Step 6 — Execute

For each enabled check:

```bash
cd <package-root> && <resolved command from catalog / yaml>
```

Parallelize independent checks when safe.

**Shim (optional):** If project has shimwrappercheck / MCP and `testGate.runner: shim`, call `run_checks` with **`noAiReview: true`**. Never enable AI review via this skill.

### Step 7 — Always-on gates

1. **`@typed-strict`** on changed paths — when TS/JS (or configured languages) in scope; FAIL if matches ([typed-strict](../typed-strict/SKILL.md)). Skip with reason on pure non-TS repos unless yaml lists other languages.
2. **Secure-by-Default RG probes** when `security.checklist: secure-by-default` or AGENTS has Security Checklist — from `~/.claude/skills/security-review/references/secure-by-default-checklist.md`, diff-scoped.
   - **B-10** (`process.env.*(SECRET|KEY|TOKEN|PASSWORD) ||`) → required **FAIL** if match.
   - **P-06** heuristics (`pending`+`failed` together, `void processBatch`) → record as **review-trigger**, do **not** FAIL test-gate solely on the fire-and-forget probe (in-flight guard is a review check). `in: ['pending', 'failed']` without attempts filter → **FAIL** (starvation anti-pattern).
3. **AGENTS Non-Negotiable RGs** when documented — only on touched paths.

### Step 8 — Report (required format)

```markdown
## Test Gate — PASS | FAIL

- Depth: quick | standard | full
- Profile: <name> (config | auto)
- Scope: frontend | backend | both | docs | scripts
- checksCommand: `<cmd>` | skipped

### Language / app profile
- Primary language(s): <ts|js|python|go|rust|swift|kotlin|deno|…>
- Application type: <spa|api|cli|mobile|game|data|monorepo|unknown>
- Recommended required: <check ids>
- Recommended optional: <check ids>
- Node lint/tsc forced: no (non-JS) | n/a (JS/TS)

| Check | Command / probe | Exit | Result |
|-------|-----------------|------|--------|
| typecheck | `npx tsc --noEmit` | 0 | PASS |
| lint | `npm run lint` | 1 | FAIL |
| typed-strict | `@typed-strict` | — | PASS |
| secureByDefault | RG probes | — | PASS |
| prettier | — | — | SKIP (no config; optional) |

### Failures
- …

### Notes
- Auto-provisioned: … (or none)
- Skipped: … (reason per check)
```

**Never claim PASS if any required row is FAIL.**

## Out of scope

- LLM code review → `@review-ticket`
- Acceptance matching → `@verify-ticket`
- Browser UX → `@verify-ui`
- AgentShield (`.cursor/`) → `@ecc-check` Phase D / commit skills
- Fixing product failures (unless caller is in a fix loop like `@ecc-check`) — bootstrap of **missing gate tooling** is in scope; fixing lint violations after bootstrap is a fix-loop concern

## Callers (must invoke, not duplicate)

| Caller | How |
|--------|-----|
| `@ecc-check` | Phase A = `@test-gate` depth=standard |
| `@audit-changes` | Phase A = `@test-gate` with user/depth mode |
| `@verify-ticket` | Checks section = `@test-gate` depth=standard |
| `@implement` | Before claim-done: `@test-gate` depth=quick |
| `@commit-pr-safe` / `@commit-push-safe` | If no READY ecc this session: `@test-gate` standard (prefer full `@ecc-check`) |
| `@verification-loop` | Prefer `@test-gate`; legacy phase list is fallback only |
| `@project-setup` | Write/refresh `testGate` defaults into `.qa/project.yaml` |

## Stack-agnostic guarantee

| Situation | Behavior |
|-----------|----------|
| Next.js monorepo | profile `next` / `monorepo` — FE build + BE scripts |
| Express + Prisma | `express-prisma` — tsc, lint, prisma, no Vite |
| Vite React | `vite-react` — vite build when standard+; bootstrap lint/tsc if missing |
| Python / Go / Rust / Swift / Kotlin | language profile; **no** forced Node lint/tsc; report Language/app profile |
| Deno-only | deno fmt/lint/check; skip npm eslint unless mixed |
| Unknown | run `checksCommand` or detected language checks; always secrets RG; typed-strict if TS |

Wrong stack assumption → **detect again**, do not force Node checks on a non-JS primary language.

## Related files

- [references/check-catalog.md](references/check-catalog.md)
- [references/stack-profiles.md](references/stack-profiles.md)
- [references/config-schema.md](references/config-schema.md)
- [scripts/detect-stack.sh](scripts/detect-stack.sh)
