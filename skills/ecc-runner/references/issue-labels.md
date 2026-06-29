# ECC Runner — GitHub issue labels

**Auto-created** on every `@ecc-runner` start via:

```bash
bash .cursor/skills/ecc-runner/scripts/bootstrap-labels.sh
```

Manual creation in GitHub Settings is optional.

| Label | Color (suggested) | Description |
|-------|-------------------|-------------|
| `agent-ready` | `#0E8A16` | **Optional** priority boost (not required to start runner) |
| `agent-in-progress` | `#FBCA04` | Runner lock — do not pick in parallel |
| `agent-blocked` | `#D93F0B` | Escalated; needs human or design |
| `agent-done` | `#1D76DB` | Completed by runner |
| `needs-design` | `#C5DEF5` | Run `@pingpong-solution` before implement |
| `needs-human` | `#B60205` | Never auto-pick |
| `P0` | `#B60205` | Highest priority in queue sort |
| `P1` | `#FBCA04` | Medium priority |
| `P2` | `#FEF2C0` | Low priority |

## Issue body template (recommended)

```markdown
## Intent
…

## Acceptance
- [ ] …
- [ ] …

## Notes
…

## Blockers
Depends on #X

## Runner
Label: agent-ready when ready for @ecc-runner
```

`ecc-runner` seeds `.qa/acceptance/<slug>.md` from `## Intent` and `## Acceptance` via `seed-acceptance-from-issue.sh`.

## Workflow

1. `@ecc-runner` — auto-builds queue from open issues, picks next (#1, lowest num, or P0/agent-ready boost)
2. Runner locks with `agent-in-progress`
3. On success → `agent-done` (or close issue)
4. On block → `agent-blocked` + `needs-human` (excluded from auto-queue)
5. Optional: `ecc-runner triage #N` to prioritize a specific issue
