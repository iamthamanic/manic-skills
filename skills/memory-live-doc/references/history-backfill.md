# History backfill (mandatory sub-workflow)

Triggered automatically when `scripts/detect-history-coverage.sh` reports
`history_action` = `required` or `recommended` — **including on bootstrap of mature repos**.

This is the VisuDEV-style full timeline: not “last 30 commits only”.

Skill pointer (same folder): treat this file as the **history-backfill subroutine**.
Optional agent note: you may also open `~/.cursor/skills/memory-live-doc/history-backfill/SKILL.md` for a short card.

## When it runs

| Trigger | Action |
|---------|--------|
| Bootstrap + mature repo | Run backfill **as part of** bootstrap draft/apply |
| Incremental + `history_action=required` | Pause pure incremental; run backfill draft first (or combine) |
| `@memory-live-doc history-backfill` | Force backfill draft |
| `history_coverage.status` = `complete` \| `skipped` | Do **not** re-backfill |

Mature heuristics (script-owned): ≥40 commits, or ≥2 months span, or ≥20 commits over ≥1 month — plus too few change events / timeline gap vs first commit.

## Steps (agent)

1. Run:
   ```bash
   bash ~/.cursor/skills/memory-live-doc/scripts/detect-history-coverage.sh
   bash ~/.cursor/skills/memory-live-doc/scripts/analyze-git-history.sh --write
   ```
2. Read `.project-memory/providers/git-history-analysis.json` (milestone candidates + monthly counts).
3. **Cluster** candidates into **8–25** material change events spanning `first_commit` → HEAD (eras, not every commit).
   Include **rebuild / UX shell / analyzer honesty / wave polish** eras when commit volume shows concentrated `fix(…)` / `feat(shell|blueprint|…)` work — not only greenfield features.
4. For each event: bilingual `title` / `summary` / `plain_language` / impacts; `evidence[]` **with GitHub `url`s** (commit/compare/blob via `project.repository.url`); `review_status: needs-review`; `confidence` ≤ 0.85.
   Run `enrich-evidence-urls.sh` before export if URLs are missing.
5. Seed **architecture/history/** Mermaid snapshots at suggested eras (append-only; replace only thin stubs that clearly duplicate the same era if upgrading coverage once).
6. Update `current-state.json` to reflect full product arc.
7. Link `related_changes` on features.
8. On apply: `export-viewer-snapshot.sh` + `validate-memory.sh`.
9. Set in `config.json`:
   ```json
   "history_coverage": {
     "status": "complete",
     "method": "git-milestone-synthesis",
     "first_commit_date": "<ISO>",
     "commit_count_at_backfill": 0,
     "change_events_from_backfill": 0,
     "architecture_versions": 0,
     "completed_at": "<ISO-8601>"
   }
   ```
   User may set `"status": "skipped"` to opt out permanently.

## Materiality for history

Record eras that match [materiality-rules.md](materiality-rules.md): features, security, architecture, data model, major UX.

Also record **product rebuild eras** when many related commits land in a short window:

- shell / navigation / view chrome rebuilds
- analyzer “honesty” / coverage / soft-cap ranking overhauls
- Wave N visualization parity / polish passes
- stack extractors (e.g. Meteor/Mongo, Prisma, compose infra)
- gap-close / QA waves that change what the product shows

Skip: pure lint/format commit storms — mention volume in `current-state` gaps if needed.

## Dates

- Store ISO `YYYY-MM-DD` in JSON.
- Viewer displays **`DD.MM.YYYY`** (see viewer-spec). Changes UI is a **horizontal timeline, newest left**.

## Chat report extras

When backfill runs, also report:

8. `history_action` + reason  
9. candidate count from analysis  
10. planned change-event count + date span  

## Do not

- Invent verified runtime behavior from commit messages alone without marking `needs-review`
- Re-run full backfill when `status=complete` unless user forces `history-backfill`
- Delete existing change events (append; upgrade summaries only if not `locked`)
