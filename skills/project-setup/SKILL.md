---
name: project-setup
description: >-
  Bootstraps new or existing repos with PRD, AGENTS.md, README, .qa/ config,
  UI styleguide, living docs via @memory-live-doc, and optional stubtree.
  Discovers stack and app root generically. Use when creating a new project,
  initializing a repo, or when the user says project setup, bootstrap repo,
  or scaffold project files.
disable-model-invocation: true
---

# Project Setup

Orchestrates project bootstrap so repos are ready for `@pingpong-solution` → `@implement` → `@verify-ui`.

**Does not write feature code.** Creates/configures project identity, QA scaffolding, and quality gates.

## Pipeline position

```
/project-setup  →  (@memory-live-doc bootstrap if needed)  →  @pingpong-solution  →  @implement  →  @verify-ui
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
- [ ] Step 3: AGENTS.md (include Living documentation section)
- [ ] Step 4: README.md
- [ ] Step 5: .qa/ (project.yaml, edge-cases, templates)
- [ ] Step 6: UI styleguide (frontend only)
- [ ] Step 7: package.json scripts (checks, test:e2e placeholder)
- [ ] Step 8: Optional (stubtree, ponytail)
- [ ] Step 9: Living docs (@memory-live-doc bootstrap if missing)
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
enableStubtree: false
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
- **typedStrict languages** (auto-detect via `~/.cursor/skills/typed-strict/scripts/detect-languages.sh` — see discovery-rules §11)

Load stack hints from [references/stack-profiles/](references/stack-profiles/) matching the detected profile.

**Monorepo rule:** Run quality tools from app root when paths differ. Set `appRoot` in `.qa/project.yaml` accordingly.

**typedStrict:** Always set or refresh `typedStrict.languages` in `.qa/project.yaml` from detection (init: write; audit: create if missing, append if incomplete). Do not confuse with UI `locale` / `language: de`. Details: `~/.cursor/skills/typed-strict/references/stack-detect.md`.

**testGate:** Write/refresh `.qa/project.yaml` → `testGate` per `~/.cursor/skills/test-gate/references/config-schema.md` so `@test-gate` / `@ecc-check` Phase A know profile and exclusions (never AI review).

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

1. If `AGENTS.md` exists → validate has: project summary, stack, architecture boundaries, language rules, validation commands, **Security Checklist block**; report gaps
2. If missing → use [references/templates/AGENTS.skeleton.md](references/templates/AGENTS.skeleton.md) (includes the **Security Checklist (Secure by Default)** block — full embedded tables, no external links)
3. Fill placeholders from Discovery Summary + PRD + stack profile
4. Ensure a **Living documentation** section exists (from skeleton). If `AGENTS.md` already exists without it → **append** the section from the skeleton (do not overwrite other content). In audit mode, ask before appending if the file is rich and the user might prefer a different wording.
5. Ensure the **Security Checklist (Secure by Default)** section exists. If `AGENTS.md` already exists without it → **append** the block from [references/templates/AGENTS.skeleton.md](references/templates/AGENTS.skeleton.md) (Frontend / Backend / Practical Habits tables). Never link to external sources — contents stay embedded in `AGENTS.md`. In audit mode, ask before appending if the file is rich.
6. If `enablePonytail: true` (profile or user request): append **„Ponytail (lazy senior dev)“** subsection from [references/templates/AGENTS.skeleton.md](references/templates/AGENTS.skeleton.md) under QA Pipeline — link [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail); do not paste the full upstream skill
7. Never replace a rich existing AGENTS.md wholesale in audit mode

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

Fill `project.yaml` with discovered `appRoot`, `devUrl`, `checksCommand`, `styleguide` path, `locale`, **`typedStrict.languages`** (from detect script / discovery-rules §11), **`security.checklist: secure-by-default`** (written by default so `@ecc-check`/`@audit-changes`/`@review-ticket`/`@test-gate` know the checklist is active; set to `disabled` only for explicit legacy opt-out), **`testGate`** defaults (see `~/.cursor/skills/test-gate/references/config-schema.md` — `profile: auto`, `always`/`never` lists, no AI checks), placeholder `navigation` (empty list OK for API-only).

Run stack detect for test-gate hints:

```bash
bash "$HOME/.cursor/skills/test-gate/scripts/detect-stack.sh" "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
```

Set `testGate.profile` to the detected `PROFILE` when confident (e.g. `monorepo`, `next`); otherwise leave `auto`.

Template placeholder `{{TYPED_STRICT_LANGUAGES}}` → YAML list, e.g. `[typescript]` or multi-line `- typescript\n  - python`.

Do not copy acceptance/design feature files — only `_template.md` stubs.

The `.qa/edge-cases.md` template ships a **Security** seed section (S-01…S-08) derived from the Secure-by-Default Checklist — agents extend it per feature as security-sensitive areas are touched.

---

## Step 6: UI styleguide (frontend only)

Skip when stack is `api-only` or no frontend detected.

1. Search: path from `project.yaml` `styleguide`, then `docs/UI_STYLEGUIDE.md`, `STYLEGUIDE.md`
2. If missing → [references/templates/UI_STYLEGUIDE.skeleton.md](references/templates/UI_STYLEGUIDE.skeleton.md) at `docs/UI_STYLEGUIDE.md` (or profile path)
3. Pre-fill stack-appropriate notes (Tailwind vs CSS modules) from stack profile
4. In the styleguide (or setup report), note design quality refs for later pipeline use — do **not** run these skills here:
   - Create: `@frontend-design` (general UI); `@design-taste-frontend` (landing/portfolio)
   - Audit: `@web-design-guidelines` (a11y/UX checklist); browser proof via `@verify-ui`

This is the **style tree** — design tokens, component hierarchy, states — not `@zapier/stubtree`.

---

## Step 7: package.json scripts

At workspace root or app root (where `checks` should run):

Add if missing, aligned with stack profile and discovery (see [references/discovery-rules.md](references/discovery-rules.md) §7):

```json
"checks": "scripts/run-checks.sh",
"test:e2e": "echo 'Add Playwright — see verify-ui skill'"
```

If `scripts/run-checks.sh` does not exist, use stack-appropriate commands (e.g. `npm run lint && npm run build && npm test`) or document the gap in the setup report.

Recommend adding `npm audit --audit-level=high` (or equivalent for the stack) to the checks script — covers Practical Security Habit **P-01** (Dependencies aktuell) from the Secure-by-Default Checklist.

Prefer existing project conventions. In monorepos, use `--prefix` or document app-root path in README.

---

## Step 8: Optional

Only when requested or enabled in `.qa/setup-profile.yaml`:

| Option | Action |
|--------|--------|
| **Stubtree** | `npx @zapier/stubtree --root <appRoot> --lang ts,tsx,js,jsx --json > .qa/code-structure.json` |
| **Ponytail** | When `enablePonytail: true`: add AGENTS.md subsection (Step 3); note `@implement` + optional `@ponytail` skill from upstream repo |

---

## Step 9: Living documentation (`@memory-live-doc`)

Ensure the repo has living project memory. Skill: `~/.cursor/skills/memory-live-doc/`.

1. If `.project-memory/checkpoint.json` **exists and validates** → skip; note in setup report
2. If missing or broken:
   - **`init` mode:** run `@memory-live-doc bootstrap` then **`apply`** after showing a short summary (user already approved project-setup; do not wait for a second OK unless they said draft-only)
   - **`audit` mode:** run `@memory-live-doc bootstrap` as **draft** first; apply only after user OK (or `@memory-live-doc apply`)
3. Confirm `AGENTS.md` still has the **Living documentation** section (Step 3); `@memory-live-doc` bootstrap apply also ensures this section on first run
4. Run Pages ownership check (never overwrite other sites):

   ```bash
   bash ~/.cursor/skills/memory-live-doc/scripts/export-viewer-snapshot.sh
   bash ~/.cursor/skills/memory-live-doc/scripts/github-pages-memory.sh status --write-config
   ```

   - `not_enabled` → after first push of `docs/`, optionally `…/github-pages-memory.sh enable --write-config`
   - `memory_viewer_active` / `pages_compatible_docs` → only ensure viewer files exist; do not change Pages
   - `pages_other` → report reason; leave Pages untouched; local viewer still works
5. Report: created/skipped `.project-memory/`, viewer path, Pages `status`, theme id, Architecture tab, `needs-review` count

Do not invent features as verified. Storage root is `.project-memory/` (never `.autoguide/`). See memory-live-doc [github-pages-policy.md](../memory-live-doc/references/github-pages-policy.md) and [theme-resolution.md](../memory-live-doc/references/theme-resolution.md).

---

## Step 10: Setup report

Use [references/setup-report-template.md](references/setup-report-template.md).

Include:

- Discovery Summary
- Created / updated / skipped files
- PRD validation result
- Living docs / `@memory-live-doc` result
- Next steps: edit PRD + AGENTS, review `.project-memory` `needs-review` items, then `@pingpong-solution` for first feature

---

## Guardrails

- **No feature code** in this skill
- **No Playwright bootstrap** — that's `@verify-ui`
- **No blind overwrite** of PRD, AGENTS, or README in audit mode
- **No secrets** in generated files
- **German UI copy** in examples when `locale: de`

## Additional resources

- [references/discovery-rules.md](references/discovery-rules.md)
- [references/prd-checklist.md](references/prd-checklist.md)
- [references/setup-report-template.md](references/setup-report-template.md)
- [references/templates/](references/templates/)
- [references/stack-profiles/](references/stack-profiles/)
