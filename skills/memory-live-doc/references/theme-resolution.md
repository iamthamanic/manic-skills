# Theme resolution (memory-live-doc viewer)

## Goal

GitHub Pages viewer matches the **product UI** when the project exposes design tokens.
Otherwise use a **neutral default**. Never invent a second brand; never hard-code a single product (e.g. VisuDEV) as the global default.

## Resolution order

`scripts/resolve-viewer-theme.sh`:

1. Existing `docs/memory-live-doc/viewer/data/theme.json` with `"locked": true` → keep  
2. `.project-memory/config.json` → `theme_id` pointing at a **skill-shipped** preset (`assets/themes/<id>.json`) — optional pin only  
3. **`scripts/extract-project-theme.py`** — derive tokens from this repo (CSS + StyleGuide)  
4. `assets/themes/default.json`

Optional: `config.theme_prefer` = `dark` | `light` | `auto` (default `auto`).  
When both `:root` and `.dark` CSS exist, `auto` prefers **`.dark`** for the docs viewer.

## What the extractor reads

Preferred paths (then globs):

- `src/STYLEGUIDE.md`, `STYLEGUIDE.md`, `docs/guidelines/StyleGuide.md`, …
- `src/styles/globals.css`, `app/globals.css`, `src/index.css`, `theme.css`, `tokens.css`, …

From CSS: `--background`, `--foreground`, `--primary`, `--accent`, `--card`, `--border`, `--destructive`, `--radius`, … (shadcn / Daisy-like and custom names).  
From Markdown: labeled hex colors (`Primary`, `Background`, `Card`, `Border`, …) and quoted font stacks.

Output: `docs/memory-live-doc/viewer/data/theme.json` with `id: "project-derived"` and `source` listing input files.

## Token schema

```json
{
  "schema_version": 1,
  "id": "project-derived",
  "source": "src/styles/globals.css (css:.dark)",
  "locked": false,
  "tokens": {
    "bg": "#…",
    "bgElev": "#…",
    "ink": "#…",
    "muted": "#…",
    "line": "#…",
    "accent": "#…",
    "accent2": "#…",
    "danger": "#…",
    "radius": "8px",
    "tabRadius": "8px",
    "fontDisplay": "…",
    "fontBody": "…",
    "fontMono": "…",
    "bgGlow1": "#…",
    "bgGlow2": "#…"
  },
  "fonts": { "google": "https://fonts.googleapis.com/css2?…" },
  "mermaid": { "theme": "dark", "themeVariables": { } }
}
```

Set `"locked": true` on a project’s `theme.json` to prevent overwrite on export.

## Skill-shipped presets

| Path | Role |
|------|------|
| `assets/themes/default.json` | Fallback when no frontend tokens found |
| `assets/themes/visudev.json` | Optional **pin** via `theme_id: "visudev"` only — not auto-selected by product name |

Prefer project extraction over pinning. Add a new preset under `assets/themes/` only when a org-wide brand must be forceable without a styleguide in-repo.

## Bootstrap / apply

Every `export-viewer-snapshot.sh` runs theme resolution. On bootstrap apply, leave `theme_id` unset (or `"auto"`) so extraction runs.
