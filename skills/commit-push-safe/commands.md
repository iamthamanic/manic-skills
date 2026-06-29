# Commit Push Safe — Commands & Templates

Read only when executing steps 3, 4, 5, 6, 7, 8, or 9.

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

List untracked files:

```bash
git status -u
```

## Stage selectively (step 3)

Stage only task-related files after inspection:

```bash
git add path/to/file1 path/to/file2
```

Never use `git add .` until every changed and untracked file is confirmed relevant.

## Secret / staged diff scan (step 5)

```bash
git diff --staged
git diff --staged --name-only
```

Flag: `.env`, `*.pem`, `*credentials*`, `*secret*`, API key patterns, tokens in logs.

## README sync (step 5b)

Read contract (repo first, then skill default):

```bash
test -f .cursor/readme-contract.md && cat .cursor/readme-contract.md || true
```

After staging code, check whether README/docs need updates:

```bash
git diff --staged --name-only
```

Stage README/docs in the same commit:

```bash
git add README.md docs/GETTING_STARTED.md docs/TEST_COVERAGE_REGISTRY.md
```

If the repo provides a scope gate:

```bash
bash scripts/check-readme-scope.sh
# or via shim:
node scripts/update-readme.js
```

Skip only when diff is tests-only or non-user-facing; document reason in final report.

## Commit (step 6)

Use HEREDOC for multi-line messages:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): short summary

Optional body describing why, not how.
EOF
)"
```

Inspect recent commit style if convention is unclear:

```bash
git log --oneline -15
```

## Validate before commit (step 4)

Use project-documented commands only. Examples to detect from `package.json`, `Makefile`, CI, or AGENTS.md:

```bash
npm run checks
npm run lint && npm run typecheck && npm run test
make test
```

### Agent config security scan (step 4 — when `.cursor/` exists)

Check first:

```bash
test -d .cursor && echo "has .cursor" || echo "skip agentshield"
```

Run scan:

```bash
npx ecc-agentshield scan --path .cursor
```

Gate:

| Finding severity | Action |
|----------------|--------|
| critical, high | Block commit and push |
| medium, low, info | Report in final report; do not block by default |

Optional JSON output for the report:

```bash
npx ecc-agentshield scan --path .cursor --format json
```

Do not scan `~/.claude` or other global agent homes unless the user explicitly requests it.

## Re-validate (step 7)

Rerun project checks and AgentShield when applicable:

```bash
npm run checks
```

```bash
test -d .cursor && npx ecc-agentshield scan --path .cursor
```

```bash
test -f scripts/check-readme-scope.sh && bash scripts/check-readme-scope.sh
```

## Push (step 8)

Only after branch is confirmed from project docs:

```bash
git push -u origin HEAD
```

Verify branch before push:

```bash
git branch --show-current
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "no upstream"
```

## Final report template (step 9)

```markdown
## Commit / push report

| Item | Value |
|------|-------|
| Commit hash | |
| Current branch | |
| Pushed remote branch | |

### Changed files
- ...

### Validation commands run
- `command` — result
- `npx ecc-agentshield scan --path .cursor` — grade / findings (if `.cursor/` exists; skip otherwise)

### AgentShield (when scanned)
| Grade | Findings |
|-------|----------|
| | critical: 0, high: 0, medium: 0, low: 0, info: 0 |

### README sync
| Item | Value |
|------|-------|
| Updated | yes / no |
| Sections | e.g. Recent changes, Für Entwickler, feature table |
| Recent changes line | … or `skipped — reason` |

### Assumptions
- ...

### Blockers / risks
- ...

### Not validated
- ...
```
