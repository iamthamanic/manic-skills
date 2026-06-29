---
name: project-setup
description: >-
  Bootstraps new or existing repos with PRD, AGENTS.md, README, .qa/ config,
  UI styleguide, shimwrappercheck, and optional fallow/stubtree. Discovers stack
  and app root generically. Use when creating a new project, initializing a repo,
  or when the user says project setup, bootstrap repo, or scaffold project files.
disable-model-invocation: true
---

# Project Setup

Orchestrates project bootstrap so repos are ready for `@pingpong-solution` → `@implement` → `@verify-ui`.

**Does not write feature code.** Creates/configures project identity, QA scaffolding, and quality gates.

## Pipeline position

```
/project-setup  →  @pingpong-solution  →  @implement  →  @verify-ui
```

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **`init`** | New/empty repo, user says "new project" | Create all missing artifacts with stack defaults |
| **`audit`** | Existing repo, user says "audit setup" | Fill gaps only; never overwrite without asking |

**Idempotency:** `exists + valid → skip`, `exists + invalid → report`, `missing → create`.

## Workflow checklist

Copy and track progress:

```
Project Setup Progress:
- [ ] Step 0: Resolve mode (init | audit) + load overrides
- [ ] Step 1: Discovery (workspace root, app root, stack, locale)
- [ ] Step 2: PRD check or scaffold
- [ ] Step 3: AGENTS.md
- [ ] Step 4: README.md
- [ ] Step 5: .qa/ (project.yaml, edge-cases, templates)
- [ ] Step 6: UI styleguide (frontend only)
- [ ] Step 7: shimwrappercheck setup
- [ ] Step 8: package.json scripts (checks, test:e2e placeholder)
- [ ] Step 9: Optional (fallow stub, stubtree, mcp-setup)
- [ ] Step 10: Setup report
```

---

## Step 0: Overrides

Read optional `.qa/setup-profile.yaml` in workspace root if present:

```yaml
locale: de
appRoot: ./frontend
prdPath: docs/PRD.md
styleguidePath: docs/UI_STYLEGUIDE.md
skipShimwrappercheck: false
enableFallow: false
enableStubtree: false
enableMcpSetup: false
enablePonytail: false
```

User chat overrides file. If neither exists, use discovery defaults.

---

## Step 1: Discovery

Read [references/discovery-rules.md](references/discovery-rules.md).

Output a short **Discovery Summary** before creating files:

- workspace root
- app root (relative path)
- stack profile: `vite-react` | `next` | `cra` | `api-only` | `monorepo` | `unknown`
- has frontend (yes/no)
- default dev port / devUrl
- locale guess (`de` if UI strings or user rules suggest German, else `en`)

Load stack hints from [references/stack-profiles/](references/stack-profiles/) matching the detected profile.

**Monorepo rule:** Run quality tools from app root when paths differ. Set `appRoot` in `.qa/project.yaml` accordingly.

---

## Step 2: PRD

Read [references/prd-checklist.md](references/prd-checklist.md).

1. Search (first match): `docs/PRD.md`, `PRD.md`, `docs/*prd*.md`, `**/*-prd.md`
2. If found → validate required sections; list gaps in report
3. If missing → copy [references/templates/PRD.skeleton.md](references/templates/PRD.skeleton.md) to `docs/PRD.md` (or `prdPath` from profile)
4. If `README.md` or draft `AGENTS.md` already has product context → pre-fill skeleton sections; **ask user to confirm** before writing
5. If no context → ask up to **5 questions** (problem, users, v1 scope, non-goals, constraints) then write draft

Do not invent detailed product requirements without user input.

---

## Step 3: AGENTS.md

1. If `AGENTS.md` exists → validate has: project summary, stack, architecture boundaries, language rules, validation commands; report gaps
2. If missing → use [references/templates/AGENTS.skeleton.md](references/templates/AGENTS.skeleton.md)
3. Fill placeholders from Discovery Summary + PRD + stack profile
4. If shimwrappercheck will run (Step 7): append or merge shim sections from `node_modules/shimwrappercheck/templates/AGENTS.md` **after** project-specific sections — project identity first, shim workflow second
5. If `enablePonytail: true` (profile or user request): append **„Ponytail (lazy senior dev)“** subsection from [references/templates/AGENTS.skeleton.md](references/templates/AGENTS.skeleton.md) under QA Pipeline — link [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail); do not paste the full upstream skill
6. Never replace a rich existing AGENTS.md wholesale in audit mode

---

## Step 4: README.md

1. If `README.md` exists → ensure sections: title, description, prerequisites, install, dev, checks, env vars (`.env.example` pointer), project structure
2. If missing → [references/templates/README.skeleton.md](references/templates/README.skeleton.md)
3. Use actual `dev` script and port from app root `package.json`

---

## Step 5: .qa/

Create if missing (workspace root):

| Path | Source |
|------|--------|
| `.qa/project.yaml` | [references/templates/project.yaml.template](references/templates/project.yaml.template) |
| `.qa/edge-cases.md` | [references/templates/edge-cases.skeleton.md](references/templates/edge-cases.skeleton.md) |
| `.qa/design/_template.md` | [references/templates/design-template.md](references/templates/design-template.md) |
| `.qa/acceptance/_template.md` | [references/templates/acceptance-template.md](references/templates/acceptance-template.md) |
| `.qa/.gitignore` | `evidence/\ntest-results/\n` |

Fill `project.yaml` with discovered `appRoot`, `devUrl`, `checksCommand`, `styleguide` path, `locale`, placeholder `navigation` (empty list OK for API-only).

Do not copy acceptance/design feature files — only `_template.md` stubs.

---

## Step 6: UI styleguide (frontend only)

Skip when stack is `api-only` or no frontend detected.

1. Search: path from `project.yaml` `styleguide`, then `docs/UI_STYLEGUIDE.md`, `STYLEGUIDE.md`
2. If missing → [references/templates/UI_STYLEGUIDE.skeleton.md](references/templates/UI_STYLEGUIDE.skeleton.md) at `docs/UI_STYLEGUIDE.md` (or profile path)
3. Pre-fill stack-appropriate notes (Tailwind vs CSS modules) from stack profile

This is the **style tree** — design tokens, component hierarchy, states — not `@zapier/stubtree`.

---

## Step 7: shimwrappercheck

Skip if `.qa/setup-profile.yaml` has `skipShimwrappercheck: true`.

1. If no `package.json` at workspace root → note in report; suggest adding one or run global init only
2. If `shimwrappercheck` not in devDependencies → `npm i -D shimwrappercheck` (from workspace root)
3. If no `.shimwrappercheckrc` and no `scripts/run-checks.sh`:
   - Run `npx shimwrappercheck setup` when interactive OK, else `npx shimwrappercheck init` with defaults aligned to discovery (Supabase if `supabase/` exists, git wrapper if `.git` exists)
4. Do **not** reimplement init wizard logic
5. **Fallow:** leave disabled by default (`SHIM_RUN_FALLOW=0`). Document enabling in report

---

## Step 8: package.json scripts

At workspace root or app root (where `checks` should run):

Add if missing:

```json
"checks": "shimwrappercheck run || scripts/run-checks.sh",
"test:e2e": "echo 'Add Playwright — see verify-ui skill'"
```

Prefer existing project conventions. In monorepos, use `--prefix` or document app-root path in README.

---

## Step 9: Optional

Only when requested or enabled in `.qa/setup-profile.yaml`:

| Option | Action |
|--------|--------|
| **Fallow** | After `npm install` in app root: add `.fallow.jsonc` stub with common ignores; note `SHIM_RUN_FALLOW=1` |
| **Stubtree** | `npx @zapier/stubtree --root <appRoot> --lang ts,tsx,js,jsx --json > .qa/code-structure.json` |
| **MCP** | `npx shimwrappercheck mcp-setup --client cursor` (ask before writing user config) |
| **Ponytail** | When `enablePonytail: true`: add AGENTS.md subsection (Step 3.5); note `@implement` + optional `@ponytail` skill from upstream repo |

Run Fallow only when `node_modules` exists and app root is confirmed.

---

## Step 10: Setup report

Use [references/setup-report-template.md](references/setup-report-template.md).

Include:

- Discovery Summary
- Created / updated / skipped files
- PRD validation result
- Next steps: edit PRD + AGENTS, then `@pingpong-solution` for first feature

---

## Guardrails

- **No feature code** in this skill
- **No Playwright bootstrap** — that's `@verify-ui`
- **No blind overwrite** of PRD, AGENTS, or README in audit mode
- **No secrets** in generated files
- **German UI copy** in examples when `locale: de`
- Ask before modifying `~/.cursor/mcp.json` or shimwrappercheck user-level config

## Additional resources

- [references/discovery-rules.md](references/discovery-rules.md)
- [references/prd-checklist.md](references/prd-checklist.md)
- [references/setup-report-template.md](references/setup-report-template.md)
- [references/templates/](references/templates/)
- [references/stack-profiles/](references/stack-profiles/)
