---
name: review-ticket
description: >-
  Static code-quality review after verify-ticket and verify-ui: architecture fit,
  maintainability, security hotspots, and diff scope vs acceptance. Uses review-bugbot
  and review-security subagents when appropriate. Use after @verify-ui before PR,
  or when user says review ticket, code review ticket, or pre-PR review.
disable-model-invocation: true
---

# Review Ticket

Code-quality audit for the current ticket. **Not** build verification (`@verify-ticket`) and **not** browser UX (`@verify-ui`).

## Pipeline position

```
@implement  →  @verify-ticket  →  @verify-ui  →  @review-ticket  →  @ecc-check  →  PR
```

## Global helper skills

| Helper | Trigger in review-ticket |
|--------|--------------------------|
| `@foundations` | Architecture findings; tag with `parnas:` `liskov:` `dijkstra:` `hoare:` `brooks:` `leaky:` `monolith:` |
| `@ponytail-review` | Large diff or new abstractions — accidental complexity (Brooks) |

Read `@foundations` when module boundaries, contracts, or scope vs acceptance are in question.

## Checklist

```
- [ ] Load .qa/acceptance/<slug>.md — Intent + scope boundary
- [ ] Load AGENTS.md, styleguide, changed files (git diff)
- [ ] Architecture layers respected (no React in content/, etc.)
- [ ] No scope creep vs acceptance Intent
- [ ] Foundations quick pass (@foundations): parnas, liskov, dijkstra, hoare, brooks
- [ ] Error handling adequate at trust boundaries
- [ ] No obvious security issues (secrets, XSS, unsafe redirects)
- [ ] Tests meaningful (not trivial); missing coverage flagged
- [ ] Verdict: ACCEPT | CHANGES_REQUESTED
```

## Subagent helpers (when diff is non-trivial)

| Trigger | Skill |
|---------|-------|
| Logic bugs, edge cases, regression risk | `@review-bugbot` |
| Auth, API routes, env, user input, secrets | `@review-security` |
| Inline security checklist | `@security-review` |

Run subagents **after** static read; merge findings into one report.

## Report format

```markdown
## Verdict
ACCEPT | CHANGES_REQUESTED

## Scope
- Acceptance slug: …
- Files reviewed: N
- Scope creep: none | list files

## Findings
| Severity | Tag | File | Issue | Action |
|----------|-----|------|-------|--------|
| critical | parnas | … | … | must fix before PR |
| suggestion | hoare | … | … | optional |

Tags: `parnas` `liskov` `dijkstra` `hoare` `brooks` `leaky` `monolith` — see `@foundations`

## Subagent
Bugbot: … | skipped
Security: … | skipped

## Empfehlung
Proceed to @verification-loop / PR | Return to @implement with list above
```

## When CHANGES_REQUESTED

List **blockers only** (critical + required for acceptance). Do not rewrite code unless user asks — hand off to `@implement`.

## When ACCEPT

Recommend `@ecc-check` then `@commit-pr-safe` or `@commit-push-safe`.
