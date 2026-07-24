---
name: test-gate
description: >-
  Deterministic quality gate: run tools/scripts (lint, tsc, prettier, tests,
  prisma, security-gate, rg probes) by exit code — never LLM judgment. Stack-
  agnostic via project.yaml + auto-detect. Use as Phase A for @ecc-check,
  @audit-changes, @verify-ticket; before claim-done in @implement; or when user
  says test-gate, /test-gate, det-gate, run checks, deterministic gate.
---

# Test Gate

**Hard gate only.** Execute tools and scripts; map exit codes → PASS | FAIL.
Do **not** read code and invent a quality verdict. Do **not** run AI review
(shimwrappercheck AI, narrative SOLID scoring, etc.).

Works on **any tech stack**: resolve checks from config + detection, then run
only applicable ones. Missing tools → SKIP (documented), not invent.

## Exit states

| State | Meaning | Next step |
|-------|---------|-----------|
| **PASS** | All required checks exit 0 / RG matches = 0 | Continue caller skill |
| **FAIL** | Any required check non-zero or critical RG hit | Fix → re-run; caller must not claim READY/ACCEPT/PASS |
| **SKIPPED** (individual check) | Tool/config absent or out of scope | OK if optional; document in report |

## Iron rules

1. **Exit code is law** — never reinterpret FAIL as PASS.
2. **No AI review** inside this skill (`aiReview`, explanation, fallow → out of scope).
3. Prefer project **`checksCommand`** / package scripts over reinventing commands.
4. Diff-scope: only packages/paths touched (unless `depth: full` or user forces both).
5. If `.qa/project.yaml` → `testGate` exists, honor it; else auto-detect.

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
4. Detect / load stack profile + enabled checks
5. Run each check (shell); record exit
6. Run @typed-strict on touched paths (required)
7. Run secure-by-default RG probes if checklist active
8. Report PASS | FAIL — never override exits
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
| **quick** | typecheck + lint (touched pkgs) + `@typed-strict` + critical RG (secrets, any, project non-negotiables) — skip full build/test/audit unless only way to typecheck |
| **standard** | quick + build (if FE in scope) + tests if script exists + prisma validate (if prisma) + security-gate / AGENTS backend gates + npm audit (warn→optional fail per yaml) + gitleaks if available |
| **full** | standard + semgrep if available + e2eCommand from yaml if set + optional complexity/architecture if configured |

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

### Step 4 — Resolve check set

1. If `testGate.packages` / `testGate.always` / `testGate.never` in yaml → use that.
2. Else map detected stack → profile in [references/stack-profiles.md](references/stack-profiles.md).
3. Intersect with [references/check-catalog.md](references/check-catalog.md) (only checks whose `when` matches).
4. Apply `testGate.never` and skip AI category always.

**If `checksCommand` is set** and depth ≥ standard: run it **first** as the primary bundle (covers many catalog items). Still run `@typed-strict` + secure-by-default RG + AGENTS non-negotiable RGs that the bundle may not cover.

### Step 5 — Execute

For each enabled check:

```bash
# Prefer package scripts from package root
cd <package-root> && npm run lint
cd <package-root> && npx tsc --noEmit -p tsconfig.json
# etc. — exact commands from catalog + AGENTS.md overrides
```

Parallelize independent checks when safe.

**Shim (optional):** If project has shimwrappercheck / MCP and `testGate.runner: shim`, call `run_checks` with **`noAiReview: true`**. Never enable AI review via this skill.

### Step 6 — Always-on gates (all stacks with TS/AGENTS)

1. **`@typed-strict`** on changed paths — FAIL if matches ([typed-strict](../typed-strict/SKILL.md)).
2. **Secure-by-Default RG probes** when `security.checklist: secure-by-default` or AGENTS has Security Checklist — from `~/.cursor/skills/security-review/references/secure-by-default-checklist.md`, diff-scoped.
3. **AGENTS Non-Negotiable RGs** when documented (examples): `any`, `console.log`, Tailwind arbitrary values, cross-module imports — only on touched paths.

### Step 7 — Report (required format)

```markdown
## Test Gate — PASS | FAIL

- Depth: quick | standard | full
- Profile: <name> (config | auto)
- Scope: frontend | backend | both | docs | scripts
- checksCommand: `<cmd>` | skipped

| Check | Command / probe | Exit | Result |
|-------|-----------------|------|--------|
| typecheck | `npx tsc --noEmit` | 0 | PASS |
| lint | `npm run lint` | 1 | FAIL |
| typed-strict | `@typed-strict` | — | PASS |
| secureByDefault | RG probes | — | PASS |
| prettier | — | — | SKIP (no config) |

### Failures
- …

### Notes
- Skipped: …
```

**Never claim PASS if any required row is FAIL.**

## Out of scope

- LLM code review → `@review-ticket`
- Acceptance matching → `@verify-ticket`
- Browser UX → `@verify-ui`
- AgentShield (`.cursor/`) → `@ecc-check` Phase D / commit skills
- Fixing failures (unless caller is in a fix loop like `@ecc-check`)

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
| Vite React | `vite-react` — vite build when standard+ |
| Python API | ruff/pyright from detect; skip eslint |
| Deno / Supabase functions | deno fmt/lint when deno.json present |
| Unknown | run `checksCommand` or `lint`+`test`+`build` if scripts exist; always typed-strict + secrets RG |

Wrong stack assumption → **detect again**, do not force Node checks on a Python-only diff.

## Related files

- [references/check-catalog.md](references/check-catalog.md)
- [references/stack-profiles.md](references/stack-profiles.md)
- [references/config-schema.md](references/config-schema.md)
- [scripts/detect-stack.sh](scripts/detect-stack.sh)
