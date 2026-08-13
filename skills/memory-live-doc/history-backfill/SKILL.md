---
name: memory-live-doc-history-backfill
description: >-
  Sub-workflow of memory-live-doc: analyze full git history and synthesize
  bilingual milestone change events + architecture history for mature repos.
  Triggered automatically when detect-history-coverage.sh says required, or
  when user says history-backfill / full timeline / seit Projektbeginn.
---

# memory-live-doc history-backfill

Parent skill: `~/.claude/skills/memory-live-doc/SKILL.md`

**Always follow:** [../references/history-backfill.md](../references/history-backfill.md)

## Quick path

```bash
bash ~/.claude/skills/memory-live-doc/scripts/detect-history-coverage.sh
bash ~/.claude/skills/memory-live-doc/scripts/analyze-git-history.sh --write
```

Then cluster `milestone_candidates` into 8–20 change events + architecture eras → apply → set `config.history_coverage.status=complete`.

Draft in chat unless pipeline `mode=apply` or user said apply.
