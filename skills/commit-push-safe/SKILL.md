---
name: commit-push-safe
description: Commits and pushes changes safely after reading project rules, validating checks, syncing README living sections when user-facing code changes, scanning for secrets, running AgentShield on .cursor agent config when present, and verifying a non-main target branch. Use when the user asks to commit, push, commit and push, commit this change, push safely, or ship work without pushing to main/master/production.
---

# Commit and Push Safely

Commit and push this change safely.

Follow this workflow strictly.

## 1. Read project rules first

Before committing or pushing, inspect the project documentation and rules:

* AGENTS.md
* README.md
* CONTRIBUTING.md
* development workflow docs
* CI/CD docs
* package scripts
* Makefile or task runner files
* GitHub/GitLab workflow files
* branch rules if documented

Find the correct branch and push rules from the project documentation.

Do not guess.

If the correct branch cannot be found in AGENTS.md, README, or other repository documentation, stop and ask.

## 2. Never push to main

Never push directly to:

* main
* master
* production
* prod
* release
* staging

unless repository documentation explicitly says this exact branch is the approved working branch for this task.

Default rule: do not push to main/master/production branches.

If the current branch is main, master, production, prod, release, or staging, stop before committing or pushing and ask which branch should be used.

## 3. Inspect git state before staging

Run the appropriate git inspection commands:

* check current branch
* check remote
* check upstream
* check working tree status
* inspect unstaged changes
* inspect staged changes
* inspect untracked files

Do not stage everything blindly.

Do not use `git add .` unless all changed and untracked files were inspected and confirmed relevant.

Do not include unrelated user changes.

If unrelated changes exist, stage only the files directly related to this task.

If it is unclear whether a file belongs to this task, stop and ask.

**Deploy/infra scope (`AGENTS.md` §5.6):** Do not stage `deployment/**/docker-compose*.yml`, `.github/workflows/**`, `example.env`, or `scripts/deploy-*.sh` unless this task is explicitly deploy/CI. After a PR-split, diff infra files for accidental regressions (e.g. Docker volume for `docs/permissions.catalog.yaml`).

## 4. Validate before commit

Prefer **`@test-gate` depth=standard** (stack-agnostic tools/scripts). Falls back to project `checksCommand` / AGENTS validation if the skill is unavailable.

Detect config from `.qa/project.yaml` → `testGate` / `checksCommand`. Do not assume a specific stack — `@test-gate` auto-detects.

Run relevant available checks before committing (via test-gate or manually), such as:

* type checks
* lint checks
* formatting checks
* unit tests
* integration tests
* build checks
* migration checks
* schema checks
* frontend checks if UI changed
* backend checks if backend changed
* **agent config security scan** when `.cursor/` exists (see below)

### Agent config security scan (when `.cursor/` exists)

If the repository has a `.cursor/` directory, run before commit:

```bash
npx ecc-agentshield scan --path .cursor
```

Rules:

* **Skip** when `.cursor/` does not exist.
* **Block commit and push** on **critical** or **high** findings.
* **Report** medium, low, and info findings in the final report; do not block unless project docs say otherwise.
* If `ecc-agentshield` cannot run (network, npm), stop and report the exact blocker — do not skip silently.
* Scan only project-local `.cursor/` — never scan `~/.claude` or global agent homes unless the user explicitly asks.

Rerun after commit if `.cursor/` files changed during the commit (hooks, rules, skills).

If checks fail, fix directly related failures and rerun the relevant checks.

Do not commit while relevant checks are failing unless the user explicitly instructs otherwise after seeing the failure.

If checks cannot be run because dependencies, secrets, services, or environment variables are missing, stop and report the exact blocker.

## 5. Inspect staged diff before commit

Before committing, inspect the staged diff.

Check for:

* secrets
* tokens
* API keys
* credentials
* private URLs
* debug logs
* console logs
* sensitive user data
* accidental .env changes
* generated files that should not be committed
* unrelated formatting churn
* unrelated refactors
* broken imports
* dead code
* incomplete TODOs
* accidental temporary files
* risky agent permissions or hooks in `.cursor/` (covered by AgentShield in step 4 when `.cursor/` exists)

Do not commit secrets or unrelated changes.

If a secret appears in the diff, stop and report it.

## 5b. Sync README (before commit)

After staging task-related files and **before** `git commit`:

1. Read the README contract:
   - Repo override: `.cursor/readme-contract.md` (if present)
   - Else: [readme-contract.md](readme-contract.md) in this skill folder
2. Inspect `git diff --staged` and decide if **user-facing behavior** changed (UI, API, scripts, env, deploy, agent workflow).
3. **Living memory:** Prefer sourcing the `## Recent changes` line from the latest `.project-memory/changes/*` event when present (DE short summary + link to `docs/CHANGELOG.md`). If `.project-memory/` is missing and the change is material user-facing → invoke `@memory-live-doc apply` (or draft if mid-chat) before commit; then stage `.project-memory/**` + `docs/**` with the **same** commit.
4. **If yes (user-facing):** update only **living sections** from the contract:
   - Adjust feature tables or dev-command blocks as needed
   - Append **one line** under `README.md` → `## Recent changes` (newest first; keep max 10 lines)
   - Update linked `docs/…` when behavior or checks changed
5. Stage doc updates in the **same commit**: `git add README.md docs/…` (and `.project-memory/**` when updated)
6. **If no user-facing change:** do not touch README. Record in the final report: `README: skipped — <reason>`.

Rules:

* Do not rewrite marketing/static README sections.
* Do not paste ticket bodies into README — link to `docs/` or `tickets/`.
* If the repo runs `scripts/check-readme-scope.sh` or shim `updateReadme`, run it after staging; fix failures before commit.

## 6. Create a clean commit

Create a clear commit message following the repository’s convention.

If the repository uses Conventional Commits, follow that format.

The commit should describe the actual change, not the implementation process.

Do not amend, squash, rebase, reset, or rewrite history unless explicitly instructed.

## 7. Validate again before push

After committing and before pushing, rerun the relevant checks if:

* formatting changed during commit
* generated files changed
* hooks modified files
* `.cursor/` rules, skills, or hooks changed
* tests were not run immediately before commit
* anything changed after the first validation run
* `README.md` or `docs/` changed in step 5b

Do not push if relevant checks are failing.

If the project provides `scripts/check-readme-scope.sh`, include it in validation (or rely on shim `updateReadme` which may call `scripts/update-readme.js`).

## 8. Push only to the approved branch

Before pushing, explicitly verify:

* current branch
* target remote
* target branch
* upstream branch

Push only to the approved non-main branch.

Do not force push unless the project rules explicitly require it and the user explicitly confirms it.

If no upstream branch exists, set upstream only for the approved branch.

If the approved branch is unclear, stop and ask.

## 9. Final report

After pushing, report:

* commit hash
* current branch
* pushed remote branch
* changed files
* validation commands run
* check results
* AgentShield grade and findings (when `.cursor/` was scanned)
* README updated: yes/no; sections touched; Recent changes line (if any)
* assumptions made
* blockers or risks
* anything not validated

Never claim the push is safe unless the relevant checks ran successfully and the target branch was verified.

## Additional resources

- Git inspection, staging, commit, push commands, and report template: [commands.md](commands.md)
- README living sections and Recent changes format: [readme-contract.md](readme-contract.md)
- For commit + push + open PR, see the `@commit-pr-safe` skill.
