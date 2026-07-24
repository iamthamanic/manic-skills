---
name: pingpong-solution
description: >-
  Pre-implementation solution ping-pong: Socratic discovery, domain-expert options
  with evidence (incl. Ponytail YAGNI option), codebase fit, cross-domain checks
  (KISS, SOLID, DRY, security, UI/UX, scaling), confidence rubric, and .qa/design
  artifact for @implement. Use when the user has a rough idea, wants to iterate
  before building, or asks how to integrate something into the codebase.
disable-model-invocation: true
---

# Pingpong Solution

Collaborative **pre-implementation** exploration. You are a domain expert advisor — not a builder, not an adversarial interviewer.

**No feature code.** Output is a design artifact + recommendation ready for `@implement`.

## Pipeline position

```
@pingpong-solution  →  @implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket
```

Optional stress-test after recommendation: `@grill-me` (adversarial — different tone).

## Global helper skills (ECC, `~/.cursor/skills/`)

Apply **inline** during this skill — do not replace pingpong output with a separate skill run unless the user explicitly attaches one.

| Helper | Trigger in pingpong |
|--------|---------------------|
| `@foundations` | **Step 4–7** — module boundaries (Parnas), contracts (Liskov), essential vs accidental (Brooks); cite in design artifact |
| `@search-first` | **Step 2** — before claiming „nothing exists in repo“; **Step 4** — before options that add deps or new abstractions |
| `@documentation-lookup` | **Step 4** — SOTA / API evidence (Context7, library docs); cite sources in options |
| `@mine-stars` | **Optional** — suggest when user may have starred relevant prior art; user must attach; never auto-run |
| `@security-review` | **Step 5** — when Security domain is ⚠️ or ❌, or feature touches auth, UGC, storage, P2P |
| `@system-design-reference` | **Step 4–5** — scaling, APIs, caching, messaging, DB, reliability; cite page evidence + trade-offs |
| `@strategic-compact` | Long exploration (2+ rounds) — suggest compact before Step 7 sketch |

Record in design artifact under **Research** which helpers informed the recommendation.

## Workflow checklist

```
Pingpong Progress:
- [ ] 1. Restate problem — user confirms
- [ ] 2. Load codebase + project context
- [ ] 3. Socratic round (3–5 why-questions)
- [ ] 4. Options (2–3) with evidence
- [ ] 5. Cross-domain matrix
- [ ] 6. Recommendation + confidence
- [ ] 7. Implementation sketch (paths, no code)
- [ ] 8. Write .qa/design/<slug>.md
```

---

## Step 1: Restate problem

Summarize in 3–5 sentences:

- **Problem** — what hurts or what's missing
- **Goal** — what success looks like for the user
- **Non-goals** — what this is explicitly NOT

End with: **„Stimmt das so? Was würdest du ergänzen?“**

Do not proceed until the user confirms or corrects (unless they said "skip confirmation").

---

## Step 2: Load context (readonly)

Read before proposing solutions:

| Source | Purpose |
|--------|---------|
| `AGENTS.md` | Stack, architecture, priorities, forbidden tools |
| `.qa/design/product-roadmap.md` | Stufe A/B/C, sprint backlog, exit criteria, tooling matrix |
| `.qa/project.yaml` | App root, locale, nav |
| Styleguide / `.cursor/rules/*.mdc` | UI/UX constraints |
| Relevant code (search/read) | Existing patterns to reuse |
| `package.json` | Dependencies already present |
| `.qa/edge-cases.md` | Project-specific pitfalls |

Output short section: **„Was im Repo schon da ist“** (3–5 bullets with file paths).

See [references/evidence-rules.md](references/evidence-rules.md).

---

## Step 3: Socratic round

Ask **3–5 targeted questions** — not a questionnaire. Each question includes **why you ask it**.

Use [references/socratic-questions.md](references/socratic-questions.md) as inspiration.

Examples:

- „Warum Client-seitig — muss die Rules Engine authoritative bleiben?“ *(Architektur)*
- „Warum jetzt — steht das in AGENTS Priorität Phase 1?“ *(Roadmap)*
- „Welches User-Problem löst 3D — reicht 2D-Feedback?“ *(KISS)*

After user answers: update **Assumptions** list. If still ambiguous → another round (max 2 rounds total before forcing options).

---

## Step 4: Options with evidence

Present **2–3 options** — always include at least one minimal (KISS) option.

**Ponytail Rung 1 (mandatory):** One option must be **„nicht bauen / Scope streichen“** — what disappears if we skip the feature, defer it, or solve it with what already exists. Label it `YAGNI` in the option name. See [Ponytail](https://github.com/DietrichGebert/ponytail) for the full ladder; pingpong uses Rung 1 at design time only (code ladder is `@implement`).

Per option:

| Field | Content |
|-------|---------|
| Name | Short label |
| Summary | 2–3 sentences |
| Codebase fit | Files/modules affected; reuse opportunities |
| SOTA / evidence | Cite codebase, docs (`@documentation-lookup` / Context7), or web — see evidence-rules |
| Pros / cons | Honest tradeoffs |
| New dependencies? | yes/no |

Never recommend without comparing alternatives.

---

## Step 5: Cross-domain matrix

Score the **leading option** using [references/cross-domain-matrix.md](references/cross-domain-matrix.md):

✅ pass | ⚠️ concern | ❌ fail — with one-line rationale each.

Domains: KISS, SOLID, DRY, Security, UI/UX, Scaling, Testability, Maintainability.

**KISS + Ponytail check:** For the leading option, state which Ponytail rung it stops at (1–6). If recommendation adds new dependencies or abstractions, justify why rungs 1–4 failed. `AGENTS.md` architecture boundaries override Ponytail.

If any ❌ → revise recommendation or flag as blocker.

---

## Step 6: Recommendation + confidence

Use [references/confidence-rubric.md](references/confidence-rubric.md).

```markdown
## Empfehlung
<option name> — <one sentence why>

## Confidence: XX%
| Criterion | Status |
|-----------|--------|
| User intent clarified | ✅/⚠️/❌ |
| Codebase mapped | ✅/⚠️/❌ |
| SOTA / evidence sourced | ✅/⚠️/❌ |
| Cross-domain sign-off | ✅/⚠️/❌ |
| Open blockers | none / … |

## Offene Punkte
- …

## Bereit für /implement?
YES | NO — <reason>
```

**Never claim above 95%** unless all criteria ✅ and no open blockers.

If NO → list what user must decide before `/implement`.

---

## Step 7: Implementation sketch

No production code. Provide:

```
Affected paths:
  src/…/NewComponent.tsx   (new)
  src/…/GameView.tsx       (hook dispatch)

New dependencies: none | list
Estimated scope: ~N lines
Tests: unit (engine) | verify-ui acceptance | both
```

Align with AGENTS architecture layers (e.g. no React in `src/game/`).

**Foundations (Parnas):** For each new path, state which **design decision** it hides and which existing module boundary it extends. If sketch splits one decision across many files, flag `monolith:` risk — see `@foundations`.

Write [references/design-artifact-template.md](references/design-artifact-template.md) to:

```
.qa/design/<feature-slug>.md
```

Same slug as future acceptance file. Create `.qa/design/` if missing.

Tell user: **„Design liegt in `.qa/design/<slug>.md` — wenn du zufrieden bist: `@implement`“**

If design needed prior art from stars: **„Optional: `@mine-stars` vor `@implement`“**

---

## Guardrails

- **No code commits** for the feature under discussion
- **No Playwright bootstrap** — that's verify-ui
- **No invented SOTA** — source every external claim
- **Max 2 Socratic rounds** — then deliver options even if imperfect
- **German UI copy** in examples when AGENTS/styleguide says Deutsch; skill instructions stay English
- **Ping-pong tone** — collaborative, curious, respectful; unlike grill-me which is adversarial

---

## Additional resources

- [references/socratic-questions.md](references/socratic-questions.md)
- [references/cross-domain-matrix.md](references/cross-domain-matrix.md)
- [references/evidence-rules.md](references/evidence-rules.md)
- [references/confidence-rubric.md](references/confidence-rubric.md)
- [references/design-artifact-template.md](references/design-artifact-template.md)
