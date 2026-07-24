# ECC Runner Loop — commands

## Start

| Command | Behavior |
|---------|----------|
| `@ecc-runner-loop` / `/ecc-runner-loop` | Bootstrap + full loop until queue empty or hard stop |
| `ecc-runner-loop continue` | Resume from `state.json` |
| `ecc-runner-loop status` | Snapshot only |

## German triggers

`alles durchziehen`, `issues komplett abarbeiten`, `merge und weiter`, `ecc runner loop`

## Flow control

| Command | Action |
|---------|--------|
| `ecc-runner-loop pause` | Stop after current phase |
| `ecc-runner-loop skip` | Defer current issue, continue queue |
| `ecc-runner-loop cancel <N>` | Abort issue N |

## Related skills

| Intent | Skill |
|--------|-------|
| Implement + PR only (no merge) | `@ecc-runner` |
| One phase debug | `@ecc-runner step` |
| Merge single existing PR | `@pr-merge-safe merge` |
| CI on open PR | `@babysit` |
| Same-session context shrink | `@strategic-compact` (between issues; **never** pause queue) |
| New agent mid-queue | `@handoff` (`paused: false`) |
