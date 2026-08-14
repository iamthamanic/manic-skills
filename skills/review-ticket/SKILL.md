---
name: review-ticket
description: >-
  Static code-quality review after verify-ticket, composition-gate, and verify-ui:
  architecture fit, maintainability, security hotspots, and diff scope vs acceptance.
  Uses review-bugbot and review-security subagents when appropriate. Use after
  @verify-ui before PR, or when user says review ticket, code review ticket, or
  pre-PR review.
disable-model-invocation: true
---

# Review Ticket

Code-quality audit for the current ticket. **Not** build verification (`@verify-ticket`) and **not** browser UX (`@verify-ui`).

## Pipeline position

```
@implement  →  @verify-ticket  →  @composition-gate  →  @verify-ui  →  @review-ticket  →  @ecc-check  →  PR
```

## Review principles

Borrowed from [obra requesting-code-review](https://www.skills.sh/obra/superpowers/requesting-code-review) — kept inside this skill (do not install a parallel review-dispatch skill).

1. **SHA-scoped diff** — Review a concrete commit range, not “whatever is in chat”. Resolve:
   ```bash
   BASE_SHA=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || git rev-parse HEAD~1)
   HEAD_SHA=$(git rev-parse HEAD)
   git diff --stat "$BASE_SHA..$HEAD_SHA"
   ```
   Prefer `origin/main...HEAD` when tracking a PR branch. Record both SHAs in the report.

2. **Fresh reviewer context** — When dispatching `@review-bugbot` / `@review-security` (or any Task subagent), pass **only**: acceptance Intent path, BASE/HEAD SHAs, short implementation summary, and requirements. **Do not** dump this session’s chat history into the subagent. The reviewer judges the work product, not the author’s thought process.

3. **Severity triage** — Act on findings by severity before claiming ACCEPT:
   | Severity | Action |
   |----------|--------|
   | **Critical** | Fix immediately (handoff `@implement`) — blocks ACCEPT |
   | **Important** | Fix before proceeding to `@ecc-check` / PR — blocks ACCEPT |
   | **Minor** | Note for later — does not block ACCEPT |

Push back on wrong findings with technical reasoning (code/tests), not vibes.

## Global helper skills

| Helper | Trigger in review-ticket |
|--------|--------------------------|
| `@test-gate` | Prerequisite: ACCEPT requires prior `@test-gate` PASS this session (or invoke depth=standard before verdict) |
| `@composition-gate` | Prerequisite: ACCEPT requires CLEAR or documented SKIPPED proof for current HEAD SHA. Missing/stale/FLAGGED → run now. FLAGGED findings **must be fixed** before ACCEPT |
| `@foundations` | Architecture findings; tag with `parnas:` `liskov:` `dijkstra:` `hoare:` `brooks:` `leaky:` `monolith:` |
| `@system-design-reference` | New cache/queue/gateway/distributed pattern — validate fit; cite trade-offs vs over-engineering |
| `@ponytail-review` | Large diff or new abstractions — accidental complexity (Brooks) |
| `@typed-strict` | Covered by `@test-gate`; if escape hatches remain → Important (blocks ACCEPT) |

Read `@foundations` when module boundaries, contracts, or scope vs acceptance are in question.

## Checklist

```
- [ ] Resolve BASE_SHA..HEAD_SHA and review that diff only
- [ ] Confirm `@test-gate` PASS this session (depth≥standard) — if missing, run it before ACCEPT
- [ ] Confirm `@composition-gate` CLEAR or SKIPPED for current HEAD SHA (`.qa/runs/composition-gate-<slug>.md`); missing/stale/FLAGGED → run + **fix** flags before ACCEPT
- [ ] Load .qa/acceptance/<slug>.md — Intent + scope boundary
- [ ] Load AGENTS.md, styleguide, changed files (git diff BASE..HEAD)
- [ ] Architecture layers respected (no React in content/, etc.)
- [ ] No scope creep vs acceptance Intent
- [ ] Foundations quick pass (@foundations): parnas, liskov, dijkstra, hoare, brooks
- [ ] Error handling adequate at trust boundaries
- [ ] No obvious security issues (secrets, XSS, unsafe redirects)
- [ ] Secure-by-Default Coverage: if AGENTS.md has a Security Checklist block, verify the diff satisfies applicable rows (Frontend F-xx / Backend B-xx / Practical P-xx); Critical violations (incl. B-10) block ACCEPT
- [ ] Worker/Outbox/Bulk-side-effect in diff → P-06 Manual Gate + `@review-bugbot` ran (skip is a process blocker)
- [ ] `@typed-strict` on touched paths — no language-specific escape hatches left (Boy Scout)
- [ ] Tests meaningful (not trivial); missing coverage flagged
- [ ] Subagents (if any) got SHA + requirements only — no session dump
- [ ] Severity triage: Critical/Important fixed or blocking; Minor noted
- [ ] Verdict: ACCEPT | CHANGES_REQUESTED
```

## Subagent helpers (when diff is non-trivial)

| Trigger | Skill |
|---------|-------|
| Logic bugs, edge cases, regression risk | `@review-bugbot` |
| Worker, outbox, queue, poller, bulk send/enqueue | `@review-bugbot` **Pflicht** + P-06/B-10 Manual Gate (Skip → CHANGES_REQUESTED) |
| Auth, API routes, env, user input, secrets | `@review-security` |
| Inline security checklist | `@security-review` |

Run subagents **after** static read; merge findings into one report.

Dispatch payload (minimum): `{DESCRIPTION}`, acceptance path / Intent, `{BASE_SHA}`, `{HEAD_SHA}`. No transcript paste.

For `@review-security`: also instruct „Prüfe gegen den **Security Checklist (Secure by Default)** Block in AGENTS.md (Frontend/Backend/Practical Habits Tabellen — Inhalte eingebettet, keine externen Links); dokumentiere zutreffende Item-IDs (F-xx, B-xx, P-xx) und Coverage im Report".

## Report format

```markdown
## Verdict
ACCEPT | CHANGES_REQUESTED

## Scope
- Acceptance slug: …
- BASE_SHA..HEAD_SHA: …..…
- Files reviewed: N
- Scope creep: none | list files

## Findings
| Severity | Tag | File | Issue | Action |
|----------|-----|------|-------|--------|
| Critical | parnas | … | … | fix now — blocks ACCEPT |
| Important | hoare | … | … | fix before ecc-check/PR |
| Minor | brooks | … | … | note later |

Tags: `parnas` `liskov` `dijkstra` `hoare` `brooks` `leaky` `monolith` `seclv` — see `@foundations`; `seclv` = Secure-by-Default Checklist item (F-xx / B-xx / P-xx)

## Subagent
Bugbot: … | skipped (context: SHAs only)
Security: … | skipped
Composition-gate: CLEAR | SKIPPED | FLAGGED (must fix) — SHA …

## Empfehlung
Proceed to @ecc-check / PR | Return to @implement with Critical/Important list above
```

## When CHANGES_REQUESTED

List **blockers only** (Critical + Important). Minor stays in the table as notes. Do not rewrite code unless user asks — hand off to `@implement`.

## When ACCEPT

Allowed only when no open Critical or Important items remain (Minor OK) **and** `@test-gate` PASS is recorded **and** `@composition-gate` is CLEAR or SKIPPED (same HEAD SHA). Recommend `@ecc-check` then `@commit-pr-safe` or `@commit-push-safe`.
