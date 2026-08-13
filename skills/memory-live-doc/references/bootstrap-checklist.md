# Bootstrap checklist (Deep)

Copy and track:

```text
Bootstrap Progress:
- [ ] Collect git context (branch, HEAD)
- [ ] Run detect-history-coverage.sh → note history_action
- [ ] If required|recommended: analyze-git-history.sh --write + follow history-backfill.md
- [ ] Read README, AGENTS.md, docs/**, PRD/ARCHITECTURE/ADRs
- [ ] Map packages / apps from manifests + workspace layout
- [ ] Note routes/APIs/tests as capability hints (low confidence)
- [ ] Draft plan in chat (manual) OR prepare apply payload (pipeline / project-setup init)
- [ ] Create .project-memory/ tree
- [ ] Write config.json, project.json, checkpoint.json, current-state.json
- [ ] Seed features/*.json (best-effort)
- [ ] Write change events: young repo = bootstrap event; mature = 8–20 milestones since first commit
- [ ] Write architecture/overview.mermaid (+ history/ eras when mature)
- [ ] Write providers/git.json + evidence/index.json (+ git-history-analysis.json when backfill)
- [ ] Set config.history_coverage (complete after mature backfill; pending/incomplete until then)
- [ ] Render DE docs: PROJECT-STATUS, FEATURES, CHANGELOG, DECISIONS
- [ ] Render EN docs under docs/en/
- [ ] Copy viewer template → docs/memory-live-doc/viewer/
- [ ] Run `export-viewer-snapshot.sh` (theme + architecture.json + data/*.json)
- [ ] Export viewer/data/*.json snapshot
- [ ] List screenshot placeholders for important UI
- [ ] Ensure AGENTS.md has Living documentation section (append if missing)
- [ ] Mark all claims needs-review
- [ ] validate-memory.sh
- [ ] Advance checkpoint only after successful apply
```

On apply, **always** export a Pages-ready viewer:

```bash
bash ~/.claude/skills/memory-live-doc/scripts/export-viewer-snapshot.sh
```

This syncs the Architecture tab Mermaid and resolved theme (see `references/theme-resolution.md`).

## AGENTS.md on first bootstrap apply (mandatory)

If `AGENTS.md` exists and has **no** `## Living documentation` (or German equivalent `## Lebende Dokumentation`) section, **append**:

```markdown
## Living documentation

After material changes, run `@memory-live-doc` (or rely on `@implement` / `@ecc-check` / `@commit-push-safe` / `@project-setup` integration).

- Do not invent features in docs without evidence.
- Storage: `.project-memory/` (bilingual DE+EN JSON; human docs under `docs/` + `docs/en/`).
- Interactive viewer: `docs/memory-live-doc/viewer/` (GitHub Pages).
- First setup: `@project-setup` Step 9 or `@memory-live-doc bootstrap`.
```

If `AGENTS.md` is missing, create a minimal stub that includes this section (prefer full skeleton from `@project-setup` when that skill is in use). Do **not** overwrite unrelated AGENTS content.

## config.json (minimum)

```json
{
  "schema_version": 1,
  "languages": { "json": ["de", "en"], "markdown_primary": "de", "markdown_en_dir": "docs/en" },
  "viewer_path": "docs/memory-live-doc/viewer",
  "storage_root": ".project-memory"
}
```

## checkpoint.json (after apply)

```json
{
  "schema_version": 1,
  "last_processed_commit": "<full-sha>",
  "processed_at": "<ISO-8601>",
  "mode": "bootstrap"
}
```

## Do not

- Invent verified runtime behavior
- Store secrets or private page text
- Create `.autoguide/`
- Skip bilingual JSON fields
- Replace a rich AGENTS.md wholesale
