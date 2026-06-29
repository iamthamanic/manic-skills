# Review ticket — architecture blockers (CHANGES_REQUESTED)

Apply to **new or changed** code in the diff. **Grandfathered** paths: read repo `.qa/design/architecture-freeze.md` if present — do not block for existing size alone; block if the diff **grows** frozen files for feature work.

Read limits from `AGENTS.md` when present. Defaults below.

## Hard blockers (must fix before ACCEPT)

| # | Rule | Detection | Tag |
|---|------|-----------|-----|
| 1 | **File size** | New file **> 300 LOC** or **+50 LOC** to an already oversized file without split | `brooks:` |
| 2 | **Component size** | New/changed React component **> 150 LOC** in one function | `brooks:` |
| 3 | **Layer leak** | UI imports persistence/schema/internals bypassing adapter or public `lib/` API | `parnas:` `leaky:` |
| 4 | **New import cycle** | Diff introduces a circular dependency not present on base branch | `parnas:` `monolith:` |
| 5 | **Behavior without tests** | New/changed logic in `src/lib/` or `functions/_shared/` (non-trivial) without test update/add | `hoare:` |
| 6 | **Scope creep** | Files or behavior outside `.qa/acceptance` Intent | `parnas:` |
| 7 | **Freeze violation** | Feature growth in paths listed in `architecture-freeze.md` | `brooks:` |
| 8 | **Secrets** | Keys, tokens, `.env` in diff | critical (security) |

## Soft findings (suggestion only — do not block ACCEPT)

- Cognitive complexity high but under ceiling and tested
- Pre-existing cycle not worsened by diff
- Pre-existing frozen file touched only for bugfix < 20 LOC

## Overrides

Document in review report when **ACCEPT with documented exception**:

- User explicitly approved in ticket
- Emergency hotfix with follow-up issue linked

## Helpers

- `@foundations` — tag vocabulary and checklist
- `@ponytail-review` — accidental complexity before final verdict on large diffs
- `@review-bugbot` / `@review-security` — logic and security (can be blockers independently)
