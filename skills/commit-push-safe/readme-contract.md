# README contract (default)

Agents use this when no repo override exists at `.cursor/readme-contract.md`.

## Living sections (update when user-facing behavior changes)

- `README.md` — feature tables (e.g. “Jetzt nutzbar” / “In Entwicklung”), dev commands, env vars, new scripts
- `README.md` — `## Recent changes` (append one line per shipped change; max 10 entries, newest first)
- `docs/GETTING_STARTED.md` — setup, deploy, smoke workflows
- `docs/DESKTOP_FIRST_DEV.md` — desktop runtime, checks, scoped `SHIM_CHANGED_FILES`
- `AGENTS.md` — agent workflow changes only when this commit changes agent rules
- `docs/TEST_COVERAGE_REGISTRY.md` — new features not covered by default shim checks

## Static sections (do not rewrite unless asked)

- Marketing intro, logo, taglines, license boilerplate
- Long architecture essays (link from README instead)

## When to skip README

Skip README edits when the staged diff is **only**:

- tests (`**/__tests__/**`, `*.test.ts`, `*.test.tsx`)
- formatting-only churn with zero behavior change
- `docs/archive/`, `tickets/`
- dependency lockfiles without feature impact

Document skip reason in the commit-push final report: `README: skipped — <reason>`.

## How much to write

- README: **1–3 bullets or one table row** + link to `docs/…` for depth
- Do **not** paste ticket markdown into README
- Do **not** duplicate `docs/multi-voice-engine.md`-scale content in README

## Recent changes line format

```markdown
- **YYYY-MM-DD** — Short user-facing summary (`branch-name` or ticket id)
```

## Merge (PR to main)

On merge-ready PRs, consolidate branch `Recent changes` into feature tables and dedupe `Recent changes`. See `@commit-pr-safe` skill § README finalize.
