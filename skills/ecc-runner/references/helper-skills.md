# ECC Runner — helper skill routing

Attach inline during phases. Full pipeline table in `SKILL.md` Step 4.

## During `implement`

| Signal | Attach |
|--------|--------|
| New npm dep, unfamiliar API, MCP integration | `@documentation-lookup` |
| Reuse patterns before new code | `@search-first` |
| Auth, `/api/`, env vars, user input | `@security-review` |
| Label `content` or paths `content/topics/` | `@questolin-content-layer` |
| Label `infra` / `refactor` in title or body | `@ponytail-audit` (after implement, before verify) |
| Default implementation discipline | `@ponytail` (via `@implement`) |

## During `design`

| Signal | Attach |
|--------|--------|
| After `@pingpong-solution`, hard tradeoffs remain | `@grill-me` (optional; user or `needs-design` + ambiguous) |
| Roadmap conflict | Read `.qa/design/product-roadmap.md` if present |

## During `review`

| Signal | Attach |
|--------|--------|
| Module boundaries, leaky API, contracts | `@foundations` (tag findings) |
| Non-trivial diff | `@review-bugbot` |
| API, auth, secrets | `@review-security` |
| Always | `@review-ticket` (orchestrates above) |

## During `security-scan` phase

| Signal | Action |
|--------|--------|
| `app/api/`, tutor, auth, new env | `npx ecc-agentshield scan` |
| `.cursor/` agent config changed | same |

## Session / queue management

| Signal | Attach |
|--------|--------|
| `run all` or queue length > 3 | `@strategic-compact` between issues |
| After 5+ completed issues in project | `@ponytail-debt` (harvest `ponytail:` comments) |

## Ship (post-review)

| User intent | Skill |
|-------------|-------|
| Full quality gate (checks + review + AgentShield) | `@ecc-check` |
| Commit + push + open PR | `@commit-pr-safe` (after `@ecc-check` READY) |
| Commit + push only, no PR yet | `@commit-push-safe` |
| PR exists, CI/comments | `@babysit` |
| PR exists, review + merge | `@pr-merge-safe` or `@pr-merge-safe merge` |
| Module boundaries / contracts | `@foundations` (design + review reference) |

## First run / missing QA scaffold

| Signal | Action |
|--------|--------|
| `.qa/project.yaml` missing | `@project-setup` mode `audit` |
| No Playwright, no acceptance dir | same |
