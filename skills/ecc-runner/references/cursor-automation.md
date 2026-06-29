# ECC Runner — Cursor Automation (optional)

Optional hands-free start when an issue is marked `agent-ready` in GitHub.

## Pattern

1. GitHub Action or scheduled trigger is **not** required — use [Cursor Automations](https://cursor.com) if available.
2. Trigger: manual, or webhook on `issues` labeled `agent-ready`.
3. Prompt for automation:

```
@ecc-runner
```

Runs **batch mode** — same as manual invoke. Expect long run; monitor `.qa/queue/runs/`.

## Guardrails for automation

- Require `agent-ready` label (never auto-label from automation alone)
- Respect `needs-human`, `agent-blocked`, `wontfix`
- Set max one concurrent run (`agent-in-progress` check + `stale-lock-check.sh`)
- Do not enable auto-push; PR still needs `@commit-pr-safe` or explicit user rule

## Suggested automation prompt

```markdown
Run @ecc-runner in continue mode for this repository.
Execute one pipeline phase, update .qa/queue/state.json, then stop.
Do not push unless the issue comment explicitly requests it.
```

## Local alternative

No automation: user runs `@ecc-runner` once per session or `ecc-runner run all` for batch.
