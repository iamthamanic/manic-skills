# PRD Checklist

Validate existing PRDs or scaffold new ones. Formats differ across projects — check **sections**, not exact headings.

## Required sections

| Section | Must answer |
|---------|-------------|
| **Problem / Motivation** | What pain exists? Why build this? |
| **Zielbild / Goals** | What does success look like? |
| **Non-Goals** | What is explicitly out of scope for v1? |
| **Users / Roles** | Who uses it? (even if single role) |
| **Core Scope** | What modules/features are in v1? |
| **Constraints** | Tech, timeline, compliance — or pointer to AGENTS.md |

## Optional but recommended

- UX / quality requirements
- Deployment / environments
- Metrics / success criteria
- Open questions / TODOs

## Validation output

For each section: ✅ present | ⚠️ thin (1 line, needs detail) | ❌ missing

If ≥2 ❌ → treat as **partial**; offer to extend, not replace.

## Scaffold interview (max 5 questions)

Use when no PRD and no README/AGENTS product context:

1. **Problem:** What problem does this product solve?
2. **Users:** Who is the primary user?
3. **v1 scope:** What must work in the first shippable version?
4. **Non-goals:** What should we explicitly NOT build now?
5. **Constraints:** Stack, locale, deployment, integrations?

## Pre-fill sources (priority)

1. User chat in current session
2. Existing README "About" / description
3. Draft AGENTS.md "What is this project?"
4. package.json `description` + repo name

Mark pre-filled sections with `<!-- draft: confirm with user -->` until confirmed.

## File placement default

- Prefer `docs/PRD.md`
- Monorepo: PRD at workspace root unless app is clearly separate product

Do not duplicate full PRD into AGENTS.md — cross-link instead.
