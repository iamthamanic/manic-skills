# Report Template

```markdown
## Audit Changes — CLEAN | WARN | BLOCK

### Scope
- Mode: uncommitted | since-commit | branch | pr | keyword
- Base: `<ref>`
- Files: N (~LOC lines)
- Packages: backend | frontend | both | docs | .cursor
- Depth: quick | standard | full

### Phase A — Deterministic
| Check | Command | Result |
|-------|---------|--------|
| Scoped tsc/lint | `…` | PASS / FAIL / SKIPPED |
| RG gates | AGENTS.md patterns | PASS / FAIL |
| Full checks (standard+) | `…` | PASS / FAIL / SKIPPED |

### Phase B — Security
| Check | Result |
|-------|--------|
| Secrets in diff | PASS / FAIL |
| .env staged | PASS / FAIL |
| Auth/tenant guards (if applicable) | PASS / FAIL / N/A |
| AgentShield | PASS / FAIL / SKIPPED |

### Phase C — Review lite
- Verdict contribution: clean | warn | block
- Tags used: parnas, liskov, hoare, brooks, …

| Severity | Tag | File | Issue | Action |
|----------|-----|------|-------|--------|
| critical | hoare | … | … | fix before commit |
| medium | brooks | … | … | optional |

### Phase D — Optional
| Tool | Result |
|------|--------|
| npm audit / snyk | SKIPPED / PASS / FAIL |
| @verify-ui | SKIPPED / PASS / FAIL |
| @verify-ticket | SKIPPED / PASS / FAIL |

### Verdict: CLEAN | WARN | BLOCK

**Summary:** One paragraph — safe to continue, fix list, or ship blocker.

### Next steps
- Continue coding | Fix blockers | Run `@ecc-check` before PR | Run `@verify-ui` for UI
```

## Verdict rules

- **BLOCK**: Phase A fail (standard/full), secrets, critical security, AgentShield critical/high
- **WARN**: medium findings, missing tests for behavior change, UI untested
- **CLEAN**: all required phases pass, no critical/high findings
