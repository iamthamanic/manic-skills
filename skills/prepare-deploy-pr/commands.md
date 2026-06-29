# Prepare Deploy PR — Commands & Templates

Read only when executing steps 3, 6, or 7.

## Git inspection (step 3)

Run in parallel where possible:

```bash
git branch --show-current
git remote -v
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "no upstream"
git status
git diff
git diff --staged
git log --oneline -10
```

For PR scope vs base (after base branch is documented):

```bash
git log --oneline <base-branch>...HEAD
git diff <base-branch>...HEAD --stat
```

## Secret / diff scan (step 5)

```bash
git diff --staged
git diff
git diff --name-only
```

Flag: `.env`, `*.pem`, `*credentials*`, `*secret*`, API key patterns, tokens in logs.

## Push (step 6)

Only after branch is confirmed from project docs:

```bash
git push -u origin HEAD
```

Use `gh` for GitHub repos; use project-documented GitLab flow if applicable.

## Open PR (step 7) — GitHub

```bash
gh pr create --base <documented-base-branch> --title "<title>" --body "$(cat <<'EOF'
## Summary
- ...

## Documentation
- README: sections updated (or skipped — reason)
- Recent changes: …
- Deep docs: `docs/…`

## Validation / checks run
- `command` — result

## Test results
- ...

## Deployment relevance
- ...

## Risks / assumptions
- ...

## UI notes (if applicable)
- ...

## Migration / rollback (if applicable)
- ...
EOF
)"
```

Set `--base` only from documented project rules. Do not default to `main`.

## Final report template (step 8)

```markdown
## Deploy / PR readiness

| Item | Value |
|------|-------|
| Current branch | |
| Pushed remote branch | |
| PR base branch | |
| PR URL | |

### Changed files
- ...

### Validation
- Command: result

### README / docs
- Updated: yes/no
- Sections: …

### Assumptions
- ...

### Blockers / not validated
- ...
```
