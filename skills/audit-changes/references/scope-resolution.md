# Scope Resolution

Resolve which files `@audit-changes` inspects before any checks run.

## User intent parsing

| User says | Scope mode |
|-----------|------------|
| "uncommitted", "working tree", nothing specified | `uncommitted` |
| "since last commit", "last commit" | `since-commit` → `HEAD~1..HEAD` |
| "since develop", "against main" | `branch` → merge-base with named branch |
| "this PR", "pr diff" | `pr` |
| "time management", path fragment, directory | `keyword` |

User override always wins over defaults.

## Git commands

```bash
# Uncommitted (default)
git diff --name-only
git diff --cached --name-only

# Since last commit
git diff --name-only HEAD~1..HEAD

# Branch vs main
git diff --name-only "$(git merge-base main HEAD)"..HEAD

# PR (requires gh)
gh pr diff --name-only
# fallback
git diff --name-only origin/main...HEAD
```

## Keyword / path scope

For phrases like "time management" or `backend/app/modules/leaves`:

1. Search paths: `git ls-files | rg -i 'keyword'`
2. Common globs from conversation: `**/time-management/**`, `**/payroll-*`
3. Union with recent commits if user said "everything we did":
   ```bash
   git log --oneline --name-only --since="2 weeks ago" -- '<paths>' | sort -u
   ```
4. If ambiguous, list top 20 candidate paths and ask user to confirm.

## Scope metadata for report

Always record:

- `scope_mode`: uncommitted | since-commit | branch | pr | keyword
- `base_ref`: commit or branch name
- `files`: count
- `packages_touched`: backend | frontend | both | docs-only | agent-config

## Empty scope

If zero files match:

- Report **BLOCK** with reason "empty scope"
- Suggest: widen keyword, check `git status`, or specify path
