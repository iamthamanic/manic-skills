# ECC Runner — helper skill routing

Attach inline during phases. Full pipeline table in `SKILL.md` Step 4.

## During `implement`

| Signal | Attach |
|--------|--------|
| New npm dep, unfamiliar API, MCP integration | `@documentation-lookup` |
| Reuse patterns before new code | `@search-first` |
| Unfamiliar module / area | `@zoom-out` then `@search-first` |
| Auth, `/api/`, env vars, user input | `@security-review` |
| New or reshaped UI | `@frontend-design` (via `@implement` §8) |
| Landing / portfolio / marketing redesign | `@design-taste-frontend` (via `@implement` §8) |
| Label `content` or paths `content/topics/` | `@questolin-content-layer` |
| Label `infra` / `refactor` in title or body | `@ponytail-audit` (after implement, before verify) |
| Default implementation discipline | `@ponytail` (via `@implement`) |

## During `research` / codebase map

| Signal | Attach |
|--------|--------|
| "I don't know this area" / large unknown surface | `@zoom-out` |
| Looking for existing utils/patterns | `@search-first` |

## During `verify-ui` (UI diffs only)

| Signal | Attach |
|--------|--------|
| Touched UI files | `@web-design-guidelines` **before** `@verify-ui` |
| Browser proof | `@verify-ui` |
| Never here | `@frontend-design` / `@design-taste-frontend` (create-time only) |

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
| `run all` / `@ecc-runner-loop` / queue length > 3 | `@strategic-compact` between issues — **do not** set `paused: true` |
| Context pressure mid-loop | `@strategic-compact` then continue; if session must end → `@handoff` with `paused: false` |
| New agent / session end mid-queue | `@handoff` (OS-temp doc; suggest next skills) — **after** compact if both needed |
| Hard stop / `needs-human` | `@handoff` so the next session resumes cleanly |
| After 5+ completed issues in project | `@ponytail-debt` (harvest `ponytail:` comments) |

**Compact vs handoff:** `@strategic-compact` = same session, shrink context, **keep looping**. `@handoff` = different agent/session, persist resume brief. **Neither** is a user-facing “please continue” pause for `@ecc-runner-loop`.

## During `ecc-check` / docs

| Signal | Attach |
|--------|--------|
| Material code change since `.project-memory` checkpoint (or memory missing) | `@memory-live-doc` with `mode=apply` (via `@ecc-check` Phase E2) |
| Interactive docs-only request mid-chat | `@memory-live-doc` draft → OK |

## Ship (post-review)

| User intent | Skill |
|-------------|-------|
| Full quality gate (checks + review + AgentShield) | `@ecc-check` |
| Commit + push + open PR | `@commit-pr-safe` (after `@ecc-check` READY) |
| Commit + push only, no PR yet | `@commit-push-safe` |
| PR exists, CI/comments | `@babysit` |
| PR exists, review + merge | `@pr-merge-safe` or `@pr-merge-safe merge` |
| **Entire queue: implement + verify + merge per issue** | `@ecc-runner-loop` |
| Module boundaries / contracts | `@foundations` (design + review reference) |

## First run / missing QA scaffold

| Signal | Action |
|--------|--------|
| `.qa/project.yaml` missing | `@project-setup` mode `audit` |
| No Playwright, no acceptance dir | same |
