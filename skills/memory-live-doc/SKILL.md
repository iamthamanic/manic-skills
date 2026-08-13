---
name: memory-live-doc
description: >-
  Maintains living bilingual (DE/EN) project documentation from Git diffs:
  bootstrap or incremental update of .project-memory, change events with
  user/developer/operational impact, feature catalog, PROJECT-STATUS,
  CHANGELOG, Mermaid diagrams, screenshots, and a GitHub Pages viewer.
  On mature repos, auto-detects thin timelines and runs git history backfill
  (milestone synthesis since first commit). Use when user says memory-live-doc,
  /memory-live-doc, living docs, Projektgedächtnis, Chronik, history-backfill,
  document this change, update project memory, or when implement / ecc-check /
  ecc-runner / commit-push-safe requires documentation after a material code change.
---

# memory-live-doc

Living project memory: **Git diff + AI interpretation → JSON + Markdown + Mermaid + GitHub Pages viewer**.

Storage root: **`.project-memory/`** (never `.autoguide/`). AutoGuide is out of scope for v1.

Skill root: `~/.claude/skills/memory-live-doc/`

## Modes

| Invocation | Behavior |
|------------|----------|
| `/memory-live-doc` or `@memory-live-doc` | Detect bootstrap vs incremental; **draft** in chat; write only after user OK / apply |
| `@memory-live-doc apply` | Write last draft / run apply path |
| `@memory-live-doc bootstrap` | Force deep bootstrap draft |
| `@memory-live-doc history-backfill` | Force full git-history milestone synthesis (mature / thin coverage) |
| `@memory-live-doc status` | Checkpoint, health, pending `needs-review` count, **history coverage**; **no writes** |
| `@memory-live-doc pages-status` | Run `scripts/github-pages-memory.sh status` — is memory viewer Pages active? |
| `@memory-live-doc pages-enable` | Safely enable Pages **only** if `not_enabled`; never overwrite other sites (see [references/github-pages-policy.md](references/github-pages-policy.md)) |
| Pipeline (`@implement` / `@ecc-check` / `@ecc-runner` / `@commit-push-safe`) with `mode=apply` | **Auto-write**; mark `needs-review`; do not wait for chat OK |

## Detection (mandatory)

1. If `.project-memory/checkpoint.json` missing → **BOOTSTRAP**
2. Else if `schema_version` incompatible or critical files missing → **REPAIR** then incremental
3. Else → **INCREMENTAL**
4. **Always** run `scripts/detect-history-coverage.sh` (bootstrap, incremental, status):
   - `history_action=required` → run **history-backfill** subroutine ([references/history-backfill.md](references/history-backfill.md) / `history-backfill/SKILL.md`) **before or as part of** bootstrap/incremental apply
   - `recommended` → include backfill in the draft (do not silently skip)
   - `none` + `history_coverage.status=complete|skipped` → normal path only

Mature repos must get a **timeline since first commit** (clustered milestones), not only “last ~30 commits”. VisuDEV-style coverage is the default for large projects.

**Diff range (incremental):**

- Prefer `git diff <last_processed_commit>..HEAD`
- If working tree dirty and not yet committed: include staged + unstaged vs `last_processed_commit`
- If checkpoint commit missing locally: use `git merge-base origin/main HEAD` (or `origin/master`) as base and note low confidence

Run scripts first (deterministic):

```bash
bash ~/.claude/skills/memory-live-doc/scripts/collect-git-context.sh
bash ~/.claude/skills/memory-live-doc/scripts/detect-history-coverage.sh
# if history_action is required|recommended:
bash ~/.claude/skills/memory-live-doc/scripts/analyze-git-history.sh --write
bash ~/.claude/skills/memory-live-doc/scripts/validate-memory.sh   # after init / before claim healthy
bash ~/.claude/skills/memory-live-doc/scripts/github-pages-memory.sh status --write-config  # Pages ownership check
bash ~/.claude/skills/memory-live-doc/scripts/export-viewer-snapshot.sh   # after apply: theme + architecture + data
```

## GitHub Pages (safe enable)

See [references/github-pages-policy.md](references/github-pages-policy.md).

**Always check first:** is memory-live-doc Pages active, or is Pages serving something else?

| Status | Action |
|--------|--------|
| `not_enabled` | `pages-enable` may create legacy Pages (`main` + `/docs`) |
| `memory_viewer_active` / `pages_compatible_docs` | Do **not** change Pages; only push `docs/memory-live-doc/**` |
| `pages_other` | Do **nothing** to Pages settings (root `/`, other path, Actions workflow) |

Never overwrite an existing Pages site.

## Theme & Architecture viewer

- **Architecture tab** renders Mermaid from `viewer/data/architecture.json` (exported from `.project-memory/architecture/overview.mermaid`).
- **Theme (generic):** `scripts/resolve-viewer-theme.sh` → `extract-project-theme.py` derives tokens from the project’s StyleGuide / CSS (`:root` / `.dark`). Falls back to `assets/themes/default.json`. Optional pin: `config.theme_id` → skill preset only. See [references/theme-resolution.md](references/theme-resolution.md).
- On every **apply**, run `scripts/export-viewer-snapshot.sh` so Pages stays self-contained.

## Draft vs apply

**Manual:** draft plan in chat (files, change-event summary, screenshot gaps) → write only after user says OK / apply / `@memory-live-doc apply`.

**Pipeline `mode=apply`:** write immediately; set `review_status: needs-review`; do not block forever.

Never overwrite fields with `locked: true`. Never delete change events (append-only).

## Bootstrap (Deep)

Follow [references/bootstrap-checklist.md](references/bootstrap-checklist.md).

Synthesize from: README, AGENTS.md, `docs/**`, PRD/ARCHITECTURE/ADRs, package manifests, apps/packages layout, obvious routes/APIs, tests as capability hints.

**History depth (automatic):**

- **Young/small repo** (`history_action=none`): seed from structure + recent commits is enough; one bootstrap change event.
- **Mature repo** (`required`/`recommended`): **must** run [history-backfill](references/history-backfill.md) — `analyze-git-history.sh --write`, then synthesize **8–20** milestone change events spanning first commit → HEAD + architecture history eras. Do **not** stop at “last ~30 commits”.

Create full `.project-memory/` tree, DE docs under `docs/`, EN under `docs/en/`, Mermaid overview, viewer copy + data snapshot, screenshot placeholder list. Mark all claims `needs-review`. Do **not** invent verified runtime behavior.

**AGENTS.md:** On bootstrap **apply**, if `AGENTS.md` lacks a Living documentation section, **append** the canonical snippet from [references/bootstrap-checklist.md](references/bootstrap-checklist.md) / [references/integration-map.md](references/integration-map.md). Do not overwrite other AGENTS content. `@project-setup` Step 9 also triggers bootstrap when memory is missing.

## History backfill (sub-workflow)

Follow [references/history-backfill.md](references/history-backfill.md). Short card: [history-backfill/SKILL.md](history-backfill/SKILL.md).

After successful backfill apply, set `config.history_coverage.status` to `complete` (or `skipped` if the user opts out). Incremental runs then stay thin and fast.

## Incremental (Strict)

Follow [references/incremental-checklist.md](references/incremental-checklist.md) and [references/materiality-rules.md](references/materiality-rules.md).

Only create a product change event when material. Always collect git context, draft bilingual impacts, patch features/current-state, re-render affected Markdown/Mermaid, update README `## Recent changes` one line when user-facing (coordinate with `@commit-push-safe`), advance checkpoint **only after successful apply**, prompt for screenshots on UI changes.

## Materiality (Strict)

**Record:** user-visible feature/bugfix, security, data-model/migration, breaking, API/contract, architecture decision, dependency with behavior impact.

**Skip product changelog** (chat mention only): formatting/lint, types-only, lockfile-only, tests-only without new behavior, typo-only docs, pure refactor with no API/behavior change.

Bootstrap may be broad; incremental must stay strict.

## Bilingual

JSON always uses `{ "de": …, "en": … }` for titles, summaries, impacts. See [references/bilingual-rules.md](references/bilingual-rules.md).

- Human Markdown primary: `docs/PROJECT-STATUS.md`, `FEATURES.md`, `CHANGELOG.md`, `DECISIONS.md` (**DE**)
- English mirrors: `docs/en/…`
- Viewer: language toggle over JSON (preferred)

## Evidence & privacy

Every change event needs `evidence[]` with **clickable GitHub URLs** (file/tree blob, commit, compare, PR). On apply: resolve `project.repository.url` + `git.head` + `affected_components` / paths into `evidence[].url`. Viewer shows **GitHub chips on the timeline and in a codebase panel** (real `<a target="_blank">`, not nested inside a card button).

Screenshots: `docs/memory-live-doc/assets/<change-id>/…`. UI material + missing shot → list in draft; on apply create placeholders with `status: missing`.

**Never** store secrets, passwords, form values, or private page text in memory files.

## Chat output (every run)

Always report:

1. mode (`bootstrap` / `incremental` / `repair` / `history-backfill` / `status`)
2. material? yes/no + reason
3. draft vs applied
4. files to write / written
5. `needs-review` count
6. screenshot gaps
7. next recommended command
8. `history_action` + `history_coverage.status` (from detect script)

## Repository layout

```text
.project-memory/
├── config.json
├── checkpoint.json
├── project.json
├── current-state.json
├── features/<feature-id>.json
├── changes/<YYYY-MM-DD>-<slug>.json
├── decisions/<decision-id>.json
├── architecture/overview.mermaid
├── evidence/index.json
└── providers/git.json

docs/
├── PROJECT-STATUS.md
├── FEATURES.md
├── CHANGELOG.md
├── DECISIONS.md
├── en/…
└── memory-live-doc/
    ├── assets/
    └── viewer/          # Pages entry + data/*.json snapshot on apply
```

Monorepo: **one** `.project-memory/` at repo root; tag `packages[]` on features/changes.

On apply, export static snapshot:

- `docs/memory-live-doc/viewer/data/{project,features,changes,current-state,decisions,architecture,architecture-history,theme}.json` (via `export-viewer-snapshot.sh`)

## Schemas & visuals

- Change events: [references/change-event-schema.md](references/change-event-schema.md)
- Features: [references/feature-schema.md](references/feature-schema.md)
- Architecture / future: [references/architecture.md](references/architecture.md)
- Architecture history: [references/architecture-history.md](references/architecture-history.md)
- History backfill: [references/history-backfill.md](references/history-backfill.md)
- Theme: [references/theme-resolution.md](references/theme-resolution.md)
- Viewer: [references/viewer-spec.md](references/viewer-spec.md); template in `assets/viewer/`
- Integration patches: [references/integration-map.md](references/integration-map.md)

Templates: `assets/*.template.json`. Examples: `references/examples/`.

## Out of scope (v1)

AutoGuide provider, multi-repo hub, NotebookLM, vector RAG, pre-commit hooks, required GitHub Action checks, VisuDev — see architecture.md future extensions.
