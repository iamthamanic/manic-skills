# Issue Contract — Canonical Issue Template (global, project-agnostic)

**Scope of this file:** Every GitHub issue created by any agent skill MUST use this template.
This is the single source of truth for issue structure. Skills do not invent their own body shapes.

**Resolution order (project override wins):**

1. `.qa/issue-template.md` in the project repo (project-specific override — full replacement)
2. `~/.claude/skills/issue-contract/references/issue-template.md` (this file)

Project-specific **content** (size limits, guard gates, stack rows, labels, language) comes from
`.qa/project.yaml` → `issueContract` + `AGENTS.md`, never from editing this file.

---

## Required sections (in this exact order)

| # | Section | Kind | Required | Consumer / why |
|---|---------|------|----------|----------------|
| 1 | `## Type` | enum line | always | queue sort, pipeline routing, runner classify |
| 2 | `## Intent` | paragraph | always | `ecc-runner` seeds `.qa/acceptance/<slug>.md` from this |
| 3 | `## Goal` | paragraph | always | what "done" means for this slice |
| 4 | `## Non-Goals` | bullets | always | scope guard for `@review-ticket` / `@audit-changes` |
| 5 | `## Context` | bullets | always | existing code, reuse targets, links (fill from `@search-first`) |
| 6 | `## Scope` | `In:` / `Out:` lists | always | diff-scope gate (paths/symbols the PR may touch) |
| 7 | `## User Journey` | numbered steps | if user-facing | omit only for pure infra/chore slices |
| 8 | `## Runtime` | table | if project has runtime axes | rows from `stackProfile` / project.yaml; omit for single-runtime projects |
| 9 | `## Security & Data` | bullets | if auth/data/uploads/tenancy touched | Secure-by-Default notes + `organizationId`/owner guards where applicable |
| 10 | `## Edge Cases` | bullets | always | seeds `.qa/acceptance` edge cases |
| 11 | `## Acceptance` | checkbox list | always | `@implement` acceptance seed; **max 5 bullets** (split if more — see slice-rules) |
| 12 | `## Blockers` | `Depends on #N` lines | if dependencies | queue gating in `ecc-runner` |
| 13 | `## Runner` | metadata block | always | labels, feature slug, links |

**Optional extra sections** (append AFTER `## Runner`, never before): `## Design` (link to
`.qa/design/<slug>.md`), `## Repro Steps` (bug type), `## Screenshots` (UI type).

**Rules:**

- Section headings are `##`-level, exact names, exact order. Do not rename.
- Acceptance bullets are machine-checkable `- [ ]` items, not prose.
- One acceptance bullet MUST be the typed-strict Boy Scout line (language from
  `.qa/project.yaml` → `typedStrict.languages`, e.g. "Touched files: zero type escape hatches").
- Keep bodies short. Design depth belongs in `.qa/design/<slug>.md`, linked from `## Runner`.
- Locale: user-facing examples in `## Intent` / `## User Journey` follow `.qa/project.yaml` `locale`
  (e.g. German copy when `locale: de`). Headings stay English.

---

## Canonical template

```markdown
## Type
feature | bug | chore | docs

## Intent
<One paragraph: what this slice delivers and why.>

## Goal
<What is true when this is done.>

## Non-Goals
- <explicitly out of scope>
- <explicitly out of scope>

## Context
- Existing: <path> — <what it already does>
- Reuse: <path> — <adapter / type / UI shell / function to reuse>
- Links: <epic design / prior issue / ADR>

## Scope
In:
- <path or symbol>
Out:
- <path or symbol that must NOT be touched>

## User Journey
1. User …
2. System …
3. User sees …

## Runtime
| Axis | This slice |
|------|------------|
| Local | yes / no / partial |
| Cloud | yes / no / hybrid gate |

## Security & Data
- <tenant/owner guard, validation, secret handling, upload constraints>
- Secure-by-Default items touched: <e.g. B-02, P-05> (or "none")

## Edge Cases
- …
- …

## Acceptance
- [ ] <machine-checkable criterion>
- [ ] <machine-checkable criterion>
- [ ] Touched files: zero type escape hatches (typed-strict / Boy Scout)

## Blockers
Depends on #<issue>   <!-- omit section if none -->

## Runner
Labels: P0 | P1 | P2 (+ needs-design if UI/architecture open)
Feature slug: `<kebab-case-slug>`
Design: `.qa/design/<slug>.md`   <!-- omit line if none -->
```

---

## Type → section adjustments

| Type | Add | May omit |
|------|-----|----------|
| `feature` | — | — |
| `bug` | `## Repro Steps` (after Runner) | `## User Journey` if internal |
| `chore` | — | `## User Journey`, `## Runtime` |
| `docs` | — | `## User Journey`, `## Runtime`, `## Security & Data` |

---

## What skills must do

- **Creating** (`@feature-intake`, ad-hoc issue authoring): fill every required section from this
  template; project values from `.qa/project.yaml` `issueContract` + `AGENTS.md`.
- **Consuming** (`@ecc-runner`, `@ecc-runner-loop`, `@implement`): assume this structure; if a
  required section is missing in an existing issue, treat as low-quality input — proceed but note
  the gap in the run log; do not rewrite the issue body without user approval.
- **Verifying** (`@verify-ticket`, `@review-ticket`): diff scope is checked against `## Scope`;
  acceptance against `## Acceptance`.
