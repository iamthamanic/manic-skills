---
name: feature-intake
description: >-
  Epic feature intake: analyze PRD/concept against repo, ask UI/runtime questions,
  write epic design, slice into ordered GitHub issue drafts, create issues only
  after user approval, then hand off to @ecc-runner. Triggers: feature-intake,
  /feature-intake, neues feature, PRD zerlegen, issue plan, epic intake.
disable-model-invocation: true
---

# Feature Intake

Orchestrates **concept → epic design → issue slices → (approved) GitHub issues → @ecc-runner**.

**No feature code.** Does not run `@ecc-runner` until user explicitly approves issue creation and requests the runner.

## Pipeline position

```
@feature-intake  →  (user OK)  →  gh issues created  →  @ecc-runner
```

Inline helpers (do not replace this skill):

| Helper | When |
|--------|------|
| `@search-first` | Step 2 — map existing code before claiming greenfield |
| `@zoom-out` | Step 2 — unfamiliar area: one-layer module/caller map before claiming greenfield |
| `@pingpong-solution` | Epic design phase — same rigor, embedded here |
| `@documentation-lookup` | New deps, external APIs |
| `@security-review` | Auth, storage, voice consent, uploads |
| `@typed-strict` | Step 4–5 — epic/slices must require typed-strict Boy Scout; no issues that introduce type escape hatches |
| `@system-design-reference` | Epic infra/data flow/APIs, queues, cache, scale — pattern evidence before slicing |
| `@project-setup audit` | Missing `.qa/project.yaml` |
| `@frontend-design` / `@design-taste-frontend` | Step 3–4 — UI-heavy epics only: clarify aesthetic direction (no code, no audit) |
| `@imagegen-frontend-mobile` | Step 3–4 — mobile app epics: screen concepts / flow direction (images only; not web landings) |
| `@handoff` | After draft ready if session ends / new agent continues — OS-temp handoff (suggested skills: `@ecc-runner`) |

## Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Intake** (default) | `@feature-intake <concept or doc path>` | Full workflow through issue **draft** |
| **Create** | `feature-intake create` / user says "Issues anlegen" | Run `create-github-issues.sh` on approved draft |
| **Resume** | `feature-intake resume <epic-slug>` | Continue from existing `.qa/intake/<slug>-issues.md` |

## Workflow checklist

```
Feature Intake Progress:
- [ ] 0: Load .qa/runner-profile.yaml + .qa/project.yaml + AGENTS.md
- [ ] 1: Restate problem — user confirms (skip if user said "skip confirmation")
- [ ] 2: Codebase map (@search-first)
- [ ] 3: Socratic round (UI placement, runtime axes, MVP cut)
- [ ] 4: Epic design → .qa/design/<epic-slug>.md
- [ ] 5: Slice plan → .qa/intake/<epic-slug>-issues.md (DRAFT)
- [ ] 6: User reviews draft — STOP (no gh create unless Create mode)
- [ ] 7: On approval → create-github-issues.sh → report issue numbers
- [ ] 8: Handoff: @ecc-runner (user invokes separately)
```

---

## Step 0 — Project profile

Read in order:

1. `AGENTS.md`
2. `.qa/project.yaml`
3. `.qa/runner-profile.yaml` (if missing, use [references/runner-profile.default.yaml](references/runner-profile.default.yaml))
4. Stack profile: `references/stack-profiles/<profile>.md` from `runner-profile.stackProfile`
5. PRD / user paste / `docs/*.md` path

Resolve ECC runner scripts:

```bash
# Prefer project override, else global
if [[ -d ".claude/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT=".claude/skills/ecc-runner"
elif [[ -d "$HOME/.claude/skills/ecc-runner/scripts" ]]; then
  export ECC_RUNNER_ROOT="$HOME/.claude/skills/ecc-runner"
fi
```

---

## Step 1 — Restate

Summarize in 3–5 sentences: **Problem**, **Goal**, **Non-goals**, **MVP cut** (Ponytail Rung 1 option always stated).

End with: **„Stimmt das so? Was würdest du ergänzen?“** unless user said skip confirmation.

---

## Step 2 — Codebase map

Output **„Was im Repo schon da ist“** (3–8 bullets with paths).

Before claiming nothing exists: `@search-first`. If the area is unfamiliar, `@zoom-out` first (one-layer map), then `@search-first`.

Record reuse targets (adapters, types, UI shells, functions).

---

## Step 3 — Socratic round

Ask **3–5 questions** with **why you ask**. Focus:

- UI: where in nav / which view / empty-loading-error states
- UI (when visual): vibe / audience / existing brand vs greenfield (see `@frontend-design`; landing/portfolio → `@design-taste-frontend`; mobile app screens/flows → `@imagegen-frontend-mobile`) — direction only, do not write UI code here
- Runtime: local vs cloud-session vs hybrid (see stack profile)
- Data: SQLite `.scriptony` vs Appwrite collections
- MVP: what is explicitly deferred to later issues

Max 2 rounds; then proceed to slices.

---

## Step 4 — Epic design

Write `.qa/design/<epic-slug>.md` using structure from `@pingpong-solution` design template:

- Problem & Intent, Non-Goals, Assumptions
- Options (include **YAGNI / defer** option)
- Decision, Cross-domain sign-off, Implementation sketch (paths only)
- **Runtime matrix** (local / cloud / Tauri) per slice area
- **UI direction** (UI-heavy epics only): one-line aesthetic read for implementers — not a full `@frontend-design` run; `@web-design-guidelines` belongs in implement/audit, not intake

Slug: kebab-case, max 48 chars, from epic name.

---

## Step 5 — Issue slices (draft only)

Write `.qa/intake/<epic-slug>-issues.md` and `.qa/intake/<epic-slug>-issues.json`.

Rules: [references/slice-rules.md](references/slice-rules.md)

Each slice:

| Field | Required |
|-------|----------|
| `title` | Imperative, scoped |
| `priority` | P0 / P1 / P2 |
| `labels` | `needs-design` only if UI/architecture still TBD for this slice |
| `dependsOn` | Prior slice titles or `#N` after create |
| `featureSlug` | kebab-case for acceptance seeding |
| Body sections | **Canonical set from `@issue-contract`** (`~/.claude/skills/issue-contract/references/issue-template.md` or `.qa/issue-template.md` override): Type, Intent, Goal, Non-Goals, Context, Scope, User Journey, Runtime, Security & Data, Edge Cases, Acceptance, Blockers, Runner |

Body template: [references/issue-body-template.md](references/issue-body-template.md) (thin layer over `@issue-contract`; never invent a skill-specific body shape)

**Order:** vertical slices; MVP 0.1 first; no big-bang issue.

**Human gate:** Do **not** run `gh issue create` in default Intake mode.

---

## Step 6 — Review gate

Tell user:

> Issue-Entwurf liegt in `.qa/intake/<epic-slug>-issues.md`.  
> Epic-Design: `.qa/design/<epic-slug>.md`.  
> Wenn OK: **„Issues anlegen“** oder `@feature-intake create <epic-slug>`.  
> Danach separat: **`@ecc-runner`**.

---

## Step 7 — Create issues (approved only)

Prerequisites: user explicitly approved; `gh auth status` OK.

```bash
bash "$HOME/.claude/skills/feature-intake/scripts/create-github-issues.sh" \
  .qa/intake/<epic-slug>-issues.json
```

Script creates issues, applies labels, prints `Depends on #N` blockers in body.

Update draft markdown with assigned `#numbers`.

---

## Step 8 — Handoff

Do **not** auto-start `@ecc-runner`. User runs it when ready.

Optional: `bash "$ECC_RUNNER_ROOT/scripts/issue-survey.sh"` to preview queue.

---

## Guardrails

- No feature code, no commits
- No `gh issue create` without explicit user approval
- No auto `@ecc-runner`
- German UI copy in issue **Intent/User Journey** examples when `locale: de`
- Respect `AGENTS.md` architecture boundaries over PRD suggestions (e.g. no Supabase in Scriptony)

## Additional resources

- [references/issue-body-template.md](references/issue-body-template.md)
- [references/slice-rules.md](references/slice-rules.md)
- [references/runner-profile.default.yaml](references/runner-profile.default.yaml)
- [references/stack-profiles/scriptony-desktop.md](references/stack-profiles/scriptony-desktop.md)
- [references/stack-profiles/questolin-next.md](references/stack-profiles/questolin-next.md)
