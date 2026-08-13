# Viewer spec (v1)

Vanilla SPA template: `assets/viewer/` → copied to `docs/memory-live-doc/viewer/` on bootstrap/apply via `scripts/export-viewer-snapshot.sh`.

## Pages / Tabs

| View | Content |
|------|---------|
| Status | `product_status`, `active_focus`, `known_gaps`, optional recent/incomplete |
| Features | Cards; filter by package/status; bilingual toggle |
| Changes | **Horizontal timeline** (newest **left** → older right); detail: **GitHub codebase links**, impacts, evidence, screenshots |
| Decisions | From `decisions/*.json` snapshot (fallback: changes with type decision/architecture) |
| **Architecture** | Mermaid with **date/version filter** from `architecture-history.json` (+ current `architecture.json`); plain source in `<details>` |

## Date display

Store dates in JSON as ISO `YYYY-MM-DD` (sorting). Viewer UI formats them as **`DD.MM.YYYY`** via `formatDate()` in `app.js` (day.month.year).

## Changes timeline

- Sort: newest first (`date` descending).
- Layout: horizontal scroll rail; **left = newest**, right = older.
- Each card shows **GitHub link chips** (`<a class="gh-chip">`) for Diff / Commit / Code paths - clickable without opening detail.
- Detail view: prominent **codebase panel** with the same chips (new tab).
- Deep links: `#/changes/<change-id>` (and `#/status` etc.).

## Interaction rules (mandatory)

- Never wrap the whole timeline card in a `<button>` if it contains links - use `<article>` + separate Details button.
- External code links must be real `<a href="https://github.com/…" target="_blank" rel="noopener noreferrer">`.
- Visible focus (`:focus-visible`), min hit target ~40px, hover state on chips.
- Keep product theme tokens from extraction (or locked `theme.json`); do not invent a second palette.

## Data loading (self-contained for GitHub Pages)

On apply, run:

```bash
bash ~/.claude/skills/memory-live-doc/scripts/export-viewer-snapshot.sh
```

Writes:

```text
docs/memory-live-doc/viewer/data/project.json
docs/memory-live-doc/viewer/data/features.json      # { schema_version, features: [] }
docs/memory-live-doc/viewer/data/changes.json
docs/memory-live-doc/viewer/data/current-state.json
docs/memory-live-doc/viewer/data/decisions.json
docs/memory-live-doc/viewer/data/architecture.json  # { mermaid, title, source_path }
docs/memory-live-doc/viewer/data/architecture-history.json  # { versions: [] }
docs/memory-live-doc/viewer/data/theme.json
```

`features` / `changes` / `decisions` may also be bare arrays or `{ items: [] }` (viewer accepts all).

**Never** rely on fetching `.project-memory/` from Pages — only `./data/*`.

## Theme resolution

```bash
bash ~/.claude/skills/memory-live-doc/scripts/resolve-viewer-theme.sh
```

Order:

1. Existing `theme.json` with `"locked": true` → keep
2. `.project-memory/config.json` → `theme_id` pin to skill preset (`assets/themes/<id>.json`) only if set
3. **`extract-project-theme.py`** from StyleGuide / CSS (`:root` / `.dark`) → `project-derived`
4. Else → `assets/themes/default.json`

Optional `theme_prefer`: `dark` | `light` | `auto` (prefer `.dark` when both exist).

Viewer applies CSS variables from `theme.tokens` and optional Google Fonts URL from `theme.fonts.google`. Mermaid uses `theme.mermaid`.

Match the product palette from the repo — do not invent a second brand. Projects without frontend tokens keep the **default** theme.

## Visual

- Token-driven `styles.css` (no hard-coded product branding in the shell)
- Clear hierarchy; mobile-friendly
- Architecture tab always available when snapshot has mermaid source

## GitHub Pages

See `assets/viewer/README.md` and `references/github-pages-policy.md`.

## Smoke check

```bash
bash ~/.claude/skills/memory-live-doc/scripts/export-viewer-snapshot.sh
cd docs/memory-live-doc/viewer && python3 -m http.server 8765
# open http://127.0.0.1:8765/ — Status, Features, Architecture tabs
```

## Plain language

Features and changes should include `plain_language` and optional `why_it_matters` (bilingual). Viewer shows these first; technical `summary` under a disclosure.

## needs-review

Viewer explains that `needs-review` means documentation trust (human should verify), not an application runtime error.
