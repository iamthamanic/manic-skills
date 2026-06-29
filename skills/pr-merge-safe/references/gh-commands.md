# PR Merge Safe — GitHub CLI commands

Use `gh` for all GitHub API operations. Read tool output minimally — extract fields needed for decisions.

## Auth

```bash
gh auth status
```

If not authenticated → **BLOCKED**; user must `gh auth login`.

## Resolve PR

By current branch:

```bash
gh pr list --head "$(git branch --show-current)" --state open --json number,url,title,baseRefName,headRefName
```

By number:

```bash
gh pr view <n> --json number,title,state,url,baseRefName,headRefName,mergeable,mergeStateStatus,reviewDecision,isDraft,statusCheckRollup,body,commits
```

By URL:

```bash
gh pr view <url> --json number,title,state,url,baseRefName,headRefName,mergeable,mergeStateStatus,reviewDecision,isDraft
```

## Checkout PR head

```bash
gh pr checkout <n>
```

If checkout fails (dirty tree, conflicts) → stop and report. Stash only after user confirms.

## Changed files (for scoped checks)

```bash
gh pr diff <n> --name-only
```

Build `SHIM_CHANGED_FILES` or equivalent from this list when project uses snippet checks.

## CI status

```bash
gh pr checks <n>
gh pr view <n> --json statusCheckRollup,mergeStateStatus
```

Failed runs:

```bash
gh run list --branch "$(gh pr view <n> --json headRefName -q .headRefName)" --limit 5
gh run view <run-id> --log-failed
```

Re-run failed jobs only when fix was pushed:

```bash
gh run rerun <run-id> --failed
```

## Review threads (unresolved)

Prefer GraphQL or `gh api` for review threads. Minimum:

```bash
gh pr view <n> --comments
gh api repos/{owner}/{repo}/pulls/<n>/comments
```

Filter resolved threads; act only on unresolved change requests from humans/bots after validation.

## Update branch (behind base)

```bash
gh pr view <n> --json mergeStateStatus,baseRefName,headRefName
git fetch origin
git merge origin/<baseRefName>   # or rebase per project docs
git push origin HEAD
```

If merge conflicts → `@babysit` or **NEEDS_HUMAN**.

## Merge

Squash (default):

```bash
gh pr merge <n> --squash --delete-branch
```

Merge commit:

```bash
gh pr merge <n> --merge --delete-branch
```

Rebase:

```bash
gh pr merge <n> --rebase --delete-branch
```

Dry-run readiness (no merge):

```bash
gh pr view <n> --json mergeable,mergeStateStatus,reviewDecision
```

**Never:**

```bash
gh pr merge --admin ...
git push --force ...
```

## Post-merge

```bash
gh pr view <n> --json mergedAt,mergeCommit,url
gh issue comment <issue-n> --body "Merged in PR #<n>."
```

Extract issue number from PR body `Closes #N` / `Fixes #N`.

## Final report fields

Collect before reporting:

- PR number, URL, title
- base ← head branches
- head SHA after last push
- CI summary (all required green)
- reviewDecision
- mergeStrategy used
- mergeCommit.oid (if merged)
