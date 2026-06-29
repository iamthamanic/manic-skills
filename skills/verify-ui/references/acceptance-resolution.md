# Acceptance Resolution

How `@verify-ui` finds the acceptance file created by `@implement`.

## Primary rule

**Never guess intent** when `.qa/acceptance/<slug>.md` exists from the current implement run.

## Resolution algorithm

```
1. git diff --name-only HEAD
   → pick .qa/acceptance/*.md (not _template.md)

2. If none in diff:
   git status --porcelain .qa/acceptance/
   → pick new/modified files

3. If multiple:
   - prefer file matching branch slug (feat/foo → foo.md)
   - else newest mtime

4. If still none:
   FALLBACK → infer from diff + conversation
   → report warning: "Acceptance artifact missing — was /implement used?"
```

## Using the file

| Section | verify-ui action |
|---------|------------------|
| Intent | Context for UX judgment in report |
| Happy Path | One Playwright flow step + screenshot per item |
| Edge Cases | Subset to run; skip with reason if N/A |
| Regression | Run after feature steps |
| Screenshots | Use exact filenames from table under `.qa/evidence/<slug>/` |
| Implementation Notes | Read-only context; do not use as pass criteria |

## Evidence path

```
.qa/evidence/<feature-slug>/<NN>-<name>.png
```

Must match the Screenshots table in the acceptance file.

## Checkbox updates

After verification:

- Mark `[x]` only for items actually verified PASS
- Leave failed items `[ ]` and list in report
- User commits updated acceptance file with fixes (optional)

## Missing artifact

If `/implement` was used but no acceptance file exists:

1. Report **FAIL** or **PARTIAL** on process — "acceptance contract missing"
2. Still run smoke + fallback criteria
3. Recommend re-run `/implement` Step 0 or manually invoke acceptance generation

## _template.md

Ignore `.qa/acceptance/_template.md` — reference only, not a test target.
