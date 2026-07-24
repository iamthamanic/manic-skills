# Incremental checklist (Strict)

```text
Incremental Progress:
- [ ] collect-git-context.sh (base = checkpoint.last_processed_commit)
- [ ] detect-history-coverage.sh — if history_action=required|recommended → run history-backfill.md first (or combine draft)
- [ ] Load .project-memory + features
- [ ] Apply materiality rules → material? yes/no
- [ ] If not material: report in chat; optionally skip file writes; do not advance checkpoint for “empty” unless user asks status-only
- [ ] If material: draft change event (DE+EN impacts) + evidence[] **with GitHub urls** (commit/compare/blob from `project.repository.url`)
- [ ] Map packages[] + affected_features[] via path heuristics; put real paths in `affected_components[]` (viewer links them)
- [ ] Respect locked fields (never overwrite)
- [ ] Patch current-state.json / features as needed
- [ ] Re-render affected Markdown + Mermaid
- [ ] If overview.mermaid changed: `snapshot-architecture-history.sh` (append-only history)
- [ ] Screenshot gaps → prompt or placeholders (status: missing)
- [ ] User-facing → README ## Recent changes one line (DE)
- [ ] Manual: wait for OK; Pipeline mode=apply: write now
- [ ] On apply: write changes/, update docs, run `export-viewer-snapshot.sh` (theme + architecture + data)
- [ ] Stage `.project-memory/**` + `docs/**` with same commit when shipping
- [ ] Advance checkpoint.last_processed_commit only after successful apply
- [ ] validate-memory.sh
```

Architecture: edit `overview.mermaid`; run `snapshot-architecture-history.sh` when content changes; `export-viewer-snapshot.sh` publishes history + current. See `architecture-history.md`. Prefer `plain_language` on features/changes for non-technical readers.

## Repair path

If schema incompatible or critical files missing:

1. Report gaps
2. Recreate missing structural files from templates (keep existing changes/ append-only)
3. Then run incremental on current diff
4. Mark repaired fields `needs-review`

## Working tree rule

Prefer documenting the intended ship set: committed range when clean; include staged+unstaged when dirty and user is about to commit (esp. `@commit-push-safe`).
