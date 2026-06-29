# PR Merge Safe — project discovery

Run at skill start in **any** repository. Do not assume Scriptony or a specific stack.

## 1. Documentation (required)

Read in order until branch/check rules are clear:

| File | Look for |
|------|----------|
| `AGENTS.md` | Checks command, branch rules, PR workflow, desktop/cloud modes |
| `README.md` | Dev commands, PR base branch |
| `CONTRIBUTING.md` | Review requirements, merge policy |
| `.cursor/rules/*.mdc` | Stack-specific gates |

If PR base branch is undocumented → **NEEDS_HUMAN**; ask user.

## 2. QA config (optional but preferred)

| File | Keys |
|------|------|
| `.qa/project.yaml` | `checksCommand`, `checksSnippet`, `acceptanceDir`, `e2eCommand` |
| `.qa/runner-profile.yaml` | `checksSnippet`, `helperSkills`, `stackProfile` |
| `.qa/merge-gate.yaml` | `mergeStrategy`, `deleteBranchAfterMerge`, `requireHumanApproval`, `allowDraftMerge` |

Default when `checksCommand` missing:

1. `package.json` → `scripts.checks` or `scripts.verify`
2. `npm run checks` or `npm run verify`
3. `npm run build && npm test`

## 3. Scoped checks for PR

When project uses snippet/shim mode, scope to PR files:

```bash
files=$(gh pr diff <n> --name-only | tr '\n' ',' | sed 's/,$//')
# Example pattern (adjust per AGENTS.md):
CHECK_MODE=snippet SHIM_CHECKS_ARGS="--frontend" SHIM_CHANGED_FILES="$files" npm run checks
```

Include `src-tauri/` paths when PR touches Rust or `tauri.conf.json`.

## 4. Acceptance artifact

Link PR to acceptance:

1. PR body `Closes #N` → `gh issue view N`
2. Branch name `issue/<N>-<slug>` or similar
3. `.qa/acceptance/<slug>.md` exists → use in `@verify-ticket`

No acceptance file → verify-ticket still runs checks + diff review; document gap.

## 5. Merge policy defaults

When `.qa/merge-gate.yaml` is missing:

```yaml
mergeStrategy: squash
deleteBranchAfterMerge: true
requireHumanApproval: false
allowDraftMerge: false
cloudDeployAfterMerge: false
```

Repo branch protection may override — respect `reviewDecision` and required reviewers.

## 6. Platform notes

| Platform | Tool |
|----------|------|
| GitHub | `gh` (this skill default) |
| GitLab | Project docs — use `glab` if documented; else **NEEDS_HUMAN** |

## 7. Optional repo override

Projects may add `.qa/merge-gate.yaml` from [merge-gate.example.yaml](merge-gate.example.yaml) to customize merge behavior without changing the global skill.
