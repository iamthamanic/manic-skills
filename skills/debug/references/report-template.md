# Debug Report — `<slug>`

**Date:** YYYY-MM-DD  
**Project:** `<repo name>`  
**Shell:** tauri | web | api-only  
**Repro grade:** full | partial (vite-only) | not-reproduced  

---

## Summary

One sentence root cause hypothesis.  
**Confidence:** high | medium | low

---

## Bug description

| | |
|--|--|
| **Expected** | … |
| **Actual** | … |
| **Steps** | 1. … 2. … |

---

## Reproduction

- **Command / URL:** …
- **Playwright spec:** `e2e/debug-repro-<slug>.spec.ts` (or existing spec name)
- **Result:** reproduced | intermittent | not reproduced
- **Hard path:** no | yes → red command: `…` (paste one run output)

---

## Evidence

### Console

```
(paste errors/warnings)
```

### Network

| Method | URL | Status | Note |
|--------|-----|--------|------|
| GET | … | 500 | … |

### Screenshot / trace

- Screenshot: (path or attached)
- Playwright trace: `.qa/test-results/...` (if any)

### Tauri native (if applicable)

```
(terminal excerpt, invoke error)
```

---

## Prior art

- [ ] Repo grep: `file:line` — …
- [ ] GitHub issue/PR: #… — …
- [ ] LightRAG: …
- [ ] Ledger / debug-log: …

---

## Root cause

Technical explanation (which layer: UI / adapter / backend / Tauri / Rust).

**Hypotheses tested (hard path):** 1. … 2. …  
**Fix attempts this bug:** 0 | 1 | 2 | ≥3 → architecture stop  

---

## Suggested fix (minimal)

1. File(s): …
2. Change: …
3. Regression test: …

**Next step:** `@implement` (unless user asked to fix in same turn)

---

## Notes

- Assumptions: …
- Out of scope: …
