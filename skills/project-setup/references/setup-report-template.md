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

## Artifacts

| File | Action | Notes |
|------|--------|-------|
| docs/PRD.md | created \| updated \| skipped \| partial | … |
| AGENTS.md | … | … |
| README.md | … | … |
| .qa/project.yaml | … | … |
| .qa/edge-cases.md | … | … |
| docs/UI_STYLEGUIDE.md | … | … |
| shimwrappercheck | … | … |

## PRD Validation

- Problem: ✅ \| ⚠️ \| ❌
- Goals: …
- Non-Goals: …
- Users: …
- Scope: …
- Constraints: …

## Manual follow-up

- [ ] Review and complete PRD sections marked as draft
- [ ] Fill AGENTS.md architecture section for this codebase
- [ ] Add real navigation labels to `.qa/project.yaml`
- [ ] Add project-specific rows to `.qa/edge-cases.md`
- [ ] Run `npm install` in app root if not done
- [ ] (Optional) Enable Fallow: `SHIM_RUN_FALLOW=1` after first clean `npx fallow`

## Next step

Ready for **`@pingpong-solution`** on first feature, or **`@implement`** if scope is already clear.
```
