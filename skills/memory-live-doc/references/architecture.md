# Architecture

## Formula

```text
Git context (deterministic)
  + AI interpretation (prose, impacts, feature linking)
  + persistent structured memory (.project-memory/)
  → Markdown (DE primary + EN mirrors)
  → Mermaid
  → GitHub Pages viewer (static JSON snapshot)
```

This skill is the **orchestrator**. It does not require AutoGuide.

## Source of truth

| Layer | Role |
|-------|------|
| `.project-memory/**/*.json` | Canonical structured memory |
| `docs/*.md` + `docs/en/*.md` | Human-readable renders |
| `docs/memory-live-doc/viewer/data/*.json` | Pages-safe snapshot (written on apply via `export-viewer-snapshot.sh`) |
| Mermaid in `.project-memory/architecture/` | Diagram **source**; exported to `viewer/data/architecture.json` for the Architecture **tab** |
| `viewer/data/theme.json` | Product or default theme tokens |

Never invent runtime behavior as verified. Confidence + `needs-review` gate trust.

## Monorepo

One `.project-memory/` at **repo root**. Tag `packages[]` (and path heuristics) on features and change events. Do not create per-package memory roots in v1.

## Providers

| Provider | v1 |
|----------|-----|
| Git (`providers/git.json` + scripts) | Required |
| AutoGuide | Out of scope (optional later) |

## Future extensions (do not build now)

- AutoGuide provider adapter
- Central multi-repo hub database
- NotebookLM sync
- Vector RAG over memory
- Pre-commit hooks / CI required checks
- VisuDev integration
