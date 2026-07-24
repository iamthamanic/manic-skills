# Materiality rules (Strict incremental)

## Record a product change event when any of

- user-visible feature
- user-visible bug fix
- security
- data-model / migration
- breaking change
- API / contract change
- architecture decision
- dependency change with **behavior** impact
- **rebuild / shell / navigation chrome** that changes how users navigate or read the product
- **analyzer honesty / coverage overhaul** (what the product claims about the scanned app)
- **Wave / viz-parity polish** that materially changes Blueprint (or equivalent) views

## Skip product changelog (chat-only mention)

- formatting / lint only
- types with no behavior change
- lockfile-only
- tests-only without new behavior
- typo-only docs
- pure rename/move with **no** UX or analyzer behavior change

> Note: “lots of `fix(module)` in one week” is often a **rebuild era** for history-backfill — cluster into one event, do not skip the whole wave.

## Bootstrap vs incremental

| Mode | Breadth |
|------|---------|
| Bootstrap | Deep / broad catalog allowed; all `needs-review` |
| Incremental | **Strict** — only material events enter `changes/` and human CHANGELOG |

## Decision aid

If unsure: prefer **skip** for incremental, mention in chat. User can force with `@memory-live-doc` and explicit “document this”.

## README Recent changes

Only append when **user-facing**. Prefer DE short summary from the change event `title.de` / `summary.de` + link to `docs/CHANGELOG.md` anchor or change id.
