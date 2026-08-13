---
name: issue-contract
description: >-
  Canonical GitHub issue template contract. Every skill that creates issues
  (feature-intake, ad-hoc authoring) must use this template; consuming skills
  (ecc-runner, implement, verify-ticket) assume this structure. Triggers:
  issue template, issue contract, issue erstellen, ticket template.
disable-model-invocation: true
---

# Issue Contract

Single source of truth for GitHub issue structure across all projects.

## Rule

Every skill that creates a GitHub issue MUST build the body from
[references/issue-template.md](references/issue-template.md) — no skill-specific body shapes.

## Resolution order

1. `.qa/issue-template.md` in the project repo (project override — full replacement)
2. `~/.claude/skills/issue-contract/references/issue-template.md` (global default)

```bash
# Bash resolution snippet
if [[ -f ".qa/issue-template.md" ]]; then
  TEMPLATE=".qa/issue-template.md"
else
  TEMPLATE="$HOME/.claude/skills/issue-contract/references/issue-template.md"
fi
```

## Project-specific values (never in the template file)

Read from `.qa/project.yaml` → `issueContract` when present:

```yaml
issueContract:
  template: global            # global | path to project override
  labels: [P0, P1, P2, needs-design]
  maxAcceptanceBullets: 5
  runtimeAxes: []             # e.g. [Local, Cloud, Appwrite Functions]
  securitySection: true
  locale: de
```

Fallbacks when `issueContract` is absent: labels `P0/P1/P2/needs-design`, max 5 acceptance
bullets, no runtime axes, security section on, locale from `project.yaml` root or `de`.

## Consumption contract

- `ecc-runner` seeds `.qa/acceptance/<slug>.md` from `## Intent` + `## Acceptance` (unchanged).
- `## Scope` (In/Out) is the diff-scope gate for `@verify-ticket` / `@audit-changes`.
- `## Runner` → `Feature slug:` drives the acceptance filename.

## Resources

- [references/issue-template.md](references/issue-template.md)
