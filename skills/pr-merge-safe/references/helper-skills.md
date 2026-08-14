# PR Merge Safe — helper skill routing

Attach during review phases. This skill orchestrates; helpers deepen specific areas.

## Always (in pipeline order)

| Phase | Skill | Exit |
|-------|-------|------|
| Verify | `@verify-ticket` | PASS |
| Composition | `@composition-gate` | CLEAR or SKIPPED (same PR head SHA); FLAGGED → fix, do not merge |
| UI (conditional) | `@verify-ui` | PASS or skipped |
| Review | `@review-ticket` | ACCEPT |
| Architecture blockers | [architecture-blockers.md](../../review-ticket/references/architecture-blockers.md) + `.qa/design/architecture-freeze.md` | no hard blockers |
| Architecture / boundaries | `@foundations` | Read-only reference |
| Quality gate | `@ecc-check` | READY (includes optional `fallow audit` when `.fallowrc.*` exists) |
| PR hygiene | `@babysit` | mergeable + green CI |
| GitHub ops | ECC `github-ops` patterns | checks + merge commands |

## During `@review-ticket` (Phase 3)

| Signal | Attach |
|--------|--------|
| Non-trivial diff (> ~50 lines or > 3 files) | `@review-bugbot` |
| Auth, API routes, env, user input, secrets | `@review-security` |
| Trust-boundary checklist | `@security-review` |
| Unresolved CodeRabbit review threads | `@autofix` (repo `.agents/skills/autofix`) |
| CodeRabbit CLI available, no autofix | `code-review` / `coderabbit review --agent` |
| Label `infra` / large refactor in PR title | `@ponytail-review` (optional) |

## During verify (Phase 1)

| Signal | Attach |
|--------|--------|
| Full build/test checklist | `@verification-loop` (superset; prefer project `checksCommand`) |
| Missing `.qa/project.yaml` | `@project-setup` audit — then retry |

## ECC catalog (reference only — do not import whole repo)

Use skills from [affaan-m/ECC/skills](https://github.com/affaan-m/ECC/tree/main/skills) when stack matches:

| ECC skill | When |
|-----------|------|
| `github-ops` | PR status, CI failures, merge readiness |
| `git-workflow` | Branch naming, rebase vs merge policy |
| `verification-loop` | Generic gate pattern if no `AGENTS.md` checks |
| `coding-standards` | Style/architecture nits in review |
| `frontend-patterns` | React/UI PRs |
| `error-handling` | New API or error paths |
| `deployment-patterns` | PR touches deploy/infra — review only, no auto-deploy |

Skip domain-specific ECC skills (Django, Flutter, healthcare, etc.) unless the project uses that stack.

## Prior pipeline (context)

```
@implement → @verify-ticket → @composition-gate → @verify-ui → @review-ticket → @ecc-check
→ @commit-pr-safe → @pr-merge-safe [→ merge]
```

## Ship map (adjacent skills)

| User intent | Skill |
|-------------|-------|
| Open PR | `@commit-pr-safe` |
| Push only | `@commit-push-safe` |
| Local gate before PR | `@ecc-check` |
| PR exists, only CI/comments | `@babysit` |
| Review + merge | `@pr-merge-safe` or `@pr-merge-safe merge` |
| Issue queue | `@ecc-runner` (optional merge at end) |
