---
name: commit-pr-safe
description: >-
  Validates changes, commits on an approved non-main branch, pushes, and opens a
  PR. Use after @ecc-check READY, or when user says commit-pr-safe, /commit-pr-safe,
  ship PR, open PR, prepare deploy, or merge-ready ship.
---

# Commit PR Safe

Commit, push to an approved non-main branch, and open a pull request.

**Prerequisite:** Run `@ecc-check` until READY (includes `@test-gate` + `@composition-gate` CLEAR/SKIPPED + `@review-ticket` ACCEPT). Equivalent: `@test-gate` depth=standard PASS + `@composition-gate` CLEAR/SKIPPED (same HEAD SHA) + `@review-ticket` ACCEPT.

Follow this workflow strictly.

## 1. Read project rules first

Before running any git, deploy, push, or PR command, inspect the project documentation and rules:

- AGENTS.md
- README.md
- CONTRIBUTING.md
- deployment documentation
- CI/CD documentation
- package scripts
- Makefile or task runner files
- GitHub/GitLab workflow files
- branch protection or PR rules if documented
- any other repository-specific instructions

Find the correct target branch and PR base branch from the project rules.

Do not guess.

If the correct branch cannot be found, stop and ask.

## 2. Never push to main

Never push directly to:

- main
- master
- production
- prod
- release
- staging

unless the repository documentation explicitly says this exact branch is the approved working branch for this task.

Default rule: do not push to main/master/production branches.

If the current branch is main, master, production, prod, release, or staging, stop before making any push and ask which branch should be used.

## 3. Inspect current git state

Before changing anything, run the appropriate git inspection commands:

- check current branch
- check remote
- check upstream
- check working tree status
- inspect changed files
- inspect staged files
- inspect untracked files
- inspect recent commits if needed

Do not overwrite, discard, rebase, reset, stash, or amend user work unless explicitly instructed.

If unrelated user changes exist, stop and explain which files are unrelated before continuing.

## 4. Validate before commit/PR

If `@ecc-check` was not run in this session, run it now (or `@test-gate` depth=standard + `@composition-gate` + `@review-ticket`).

**Composition-gate proof:** Read `.qa/runs/composition-gate-<slug>.md` (and acceptance `## Composition Gate` if present).

- Verdict **CLEAR** or **SKIPPED** and SHA matches current `HEAD` (or WORKTREE matches current uncommitted scope) → accept.
- Missing, stale SHA, or **FLAGGED** → run `@composition-gate` now. **FLAGGED findings must be fixed** and the gate re-run. Do not commit/push/open a PR until CLEAR or SKIPPED.
- Skipping without a documented single-hop reason → stop.

Detect validation from `.qa/project.yaml` → `testGate` / `checksCommand` via **`@test-gate`**.

Do not push or open a PR while `@test-gate` / relevant checks are failing.

If checks cannot be run because dependencies, secrets, services, or environment variables are missing, stop and report the exact blocker.

When `.cursor/` exists, run AgentShield before commit:

```bash
npx ecc-agentshield scan --path .cursor
```

Block on critical/high findings.

## 5. Security and secret safety before push

Before pushing, inspect the diff for:

- secrets, tokens, API keys, credentials, private URLs
- debug logs, accidental `.env` changes
- generated files that should not be committed
- unrelated formatting churn or refactors

If a secret appears in the diff, stop and report it.

**PR-split / infra guard (`AGENTS.md` §5.6):** If the diff touches deploy/infra paths (`deployment/**/docker-compose*.yml`, `.github/workflows/**`, `example.env`, `scripts/deploy-*.sh`) and the PR title/scope is **not** a deploy/CI ticket, stop and ask — or remove those files from the commit. Review for accidental removal of runtime mounts (e.g. `docs/permissions.catalog.yaml` in Docker).

## 5b. README finalize (before commit / in PR)

1. Read `.cursor/readme-contract.md` or [commit-push-safe readme-contract](../commit-push-safe/readme-contract.md).
2. Ensure commits include README/docs updates for user-facing changes (or documented skip).
3. PR body must list README/doc updates under **Documentation**.

## 6. Create commit

Follow `@commit-push-safe` steps 3–6 for staging, README sync, and commit message.

## 7. Push only to the approved branch

Push only to the approved non-main branch found in the project documentation.

Do not use force push unless the project rules explicitly require it and the user explicitly confirms it.

## 8. Open the pull request

After successful validation and push, open a PR according to the repository rules.

The PR must include:

- concise title
- summary of changes
- **Documentation** — README sections touched, `Recent changes` entry, linked docs
- validation/checks run (`@ecc-check` / `@test-gate` / `@composition-gate` CLEAR|SKIPPED)
- test results
- **Deploy** — migrations, backfill scripts, infra file changes (or "none")
- deployment relevance
- risks or assumptions

Use the documented PR target/base branch. Do not open a PR against main unless docs explicitly define main as PR base.

## 9. Final report

Report: commit hash, branch, PR URL, changed files, checks run, composition-gate verdict + SHA, AgentShield grade, README status, blockers.

Suggest next step when PR is open: `@pr-merge-safe` (review only) or `@pr-merge-safe merge` (merge when green).

## Additional resources

- Git/PR commands: [commands.md](commands.md)
- Push only (no PR): `@commit-push-safe`
- Quality gate: `@ecc-check` (Phase A = `@test-gate`)

## Legacy alias

`@prepare-deploy-pr` is deprecated — use `@commit-pr-safe`.
