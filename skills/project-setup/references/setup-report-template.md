# Project Setup Report

Use this template for Step 10 output.

```markdown
# Project Setup Report

**Mode:** init | audit  
**Date:** YYYY-MM-DD  
**Workspace:** `<path>`

## Discovery Summary

| Field | Value |
|-------|-------|
| App root | `<relative path or .>` |
| Stack | vite-react \| next \| … |
| Frontend | yes \| no |
| Dev URL | http://localhost:… |
| Locale | de \| en |
| typedStrict languages | typescript, python, … (auto \| existing) |

## Artifacts

| File | Action | Notes |
|------|--------|-------|
| docs/PRD.md | created \| updated \| skipped \| partial | … |
| AGENTS.md | … | Living documentation section: yes \| appended \| already present |
| README.md | … | … |
| .qa/project.yaml | … | typedStrict: written \| appended \| ok |
| .qa/edge-cases.md | … | … |
| docs/UI_STYLEGUIDE.md | … | … |
| package.json checks script | … | … |
| `.project-memory/` | created \| skipped \| draft pending | `@memory-live-doc` |
| `docs/memory-live-doc/viewer/` | … | … |

## PRD Validation

- Problem: ✅ \| ⚠️ \| ❌
- Goals: …
- Non-Goals: …
- Users: …
- Scope: …
- Constraints: …

## Living documentation

- Mode: bootstrap \| skipped \| draft pending OK
- `needs-review` count: N
- Viewer: `docs/memory-live-doc/viewer/`

## Manual follow-up

- [ ] Review and complete PRD sections marked as draft
- [ ] Fill AGENTS.md architecture section for this codebase
- [ ] Review `@memory-live-doc` claims marked `needs-review`
- [ ] Add real navigation labels to `.qa/project.yaml`
- [ ] Confirm `typedStrict.languages` matches the stack (run detect script if unsure)
- [ ] Add project-specific rows to `.qa/edge-cases.md`
- [ ] Run `npm install` in app root if not done
- [ ] Add or refine `scripts/run-checks.sh` if `checks` script is a placeholder

## Next step

Ready for **`@pingpong-solution`** on first feature, or **`@implement`** if scope is already clear.
```
