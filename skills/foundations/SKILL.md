---
name: foundations
description: >-
  Software engineering foundations (Parnas, Liskov/ADT, Dijkstra, Hoare, Brooks):
  module boundaries, data contracts, structured control flow, pre/post conditions,
  essential vs accidental complexity. Reference skill — not a pipeline step. Use
  when designing modules, writing acceptance, reviewing architecture, or user says
  foundations, information hiding, leaky abstraction, distributed monolith.
disable-model-invocation: true
---

# Foundations

Read-only reference for **architecture and contract decisions**. Composes with `@implement`, `@review-ticket`, `@pingpong-solution`, `@ponytail-review` — does **not** replace them.

## When to load

| Situation | Action |
|-----------|--------|
| New module, adapter, or service boundary | Read § Parnas + § Related |
| Writing `.qa/acceptance` | Read § Hoare |
| Pre-PR review, ACCEPT/CHANGES_REQUESTED | Read § all — use quick checklist |
| Over-engineering / new abstraction | Read § Brooks (+ `@ponytail-review`) |
| Async hooks, control flow bugs | Read § Dijkstra |
| Local vs cloud / mock vs prod behavior | Read § Liskov |

**Skip** for typo fixes, copy-only changes, and single-line bugfixes.

## Finding tags (use in review reports)

| Tag | Paper | Meaning |
|-----|-------|---------|
| `parnas:` | Parnas (1972) | Wrong module boundary, information leak |
| `liskov:` | Liskov & Zilles (1974) | Broken data contract / substitution |
| `dijkstra:` | Dijkstra (1968) | Unstructured control flow, hidden jumps |
| `hoare:` | Hoare (1969) | Missing or untested pre/post condition |
| `brooks:` | Brooks (1986) | Accidental complexity, not domain-essential |
| `leaky:` | Related | Abstraction exposes internals to callers |
| `monolith:` | Related | Distributed monolith — split files, coupled decisions |

Full checklists: [references/checklists.md](references/checklists.md)

---

## Parnas — Information hiding (1972)

Decompose by **design decisions that may change**, not by processing steps.

**Ask:**

1. What single decision does this module hide?
2. Can that decision change without editing callers?
3. Do callers import only the public API (not internal paths/types)?
4. Is this a new module — or an extension of an existing boundary?

**Red flags (`parnas:`, `leaky:`):** UI imports persistence schema; adapter callers use cloud-only IDs; “util” that is really domain logic; two modules sharing the same secret struct.

---

## Liskov / ADT — Data contract (1974)

A type = values + operations + **invariants**. Callers rely on the contract, not representation.

**Ask:**

1. What invariants must always hold (ordering, IDs, non-negative duration)?
2. Do all implementations (local, cloud, mock) satisfy the same postconditions?
3. Can a substitute break callers silently?

**Red flags (`liskov:`):** Subclass or adapter changes error semantics; optional field becomes required; sort order undefined after mutation.

---

## Dijkstra — Structured programming (1968)

Control via sequence, selection, iteration — not unstructured jumps.

**Ask:**

1. Is there one clear owner for state updates after async work?
2. Can you follow the happy path without mental goto?
3. Are side effects at the edges (I/O, persist), core logic readable?

**Red flags (`dijkstra:`):** Callback pyramids; scattered `useEffect` updating same state; early returns that skip cleanup; flag variables encoding implicit states.

**Related — sympathy for the hardware:** Hot paths and persistence respect real cost (I/O, re-renders, full tree walks). Do not pretend everything is free.

---

## Hoare — Preconditions and postconditions (1969)

`{Pre} Code {Post}` — correctness as testable claims.

**Ask:**

1. What must be true **before** this runs?
2. What is guaranteed **after**?
3. Does each acceptance checkbox map to a postcondition with evidence (test or verify step)?

**In `.qa/acceptance`:** Happy Path items = postconditions; Edge Cases = preconditions violated or handled.

**Red flags (`hoare:`):** “Works correctly” without observable check; behavior change without test; PASS claimed without running checks.

---

## Brooks — Essential vs accidental complexity (1986)

No silver bullet: tools remove **accidental** complexity, not domain **essential** complexity.

**Ask:**

1. Does this change address the real domain problem or add framework ceremony?
2. Is there a second caller for this abstraction today?
3. Would removing it simplify without losing a product requirement?

**Red flags (`brooks:`, `monolith:`):** New config layer with one consumer; micro-files with shared undeployable assumptions; “flexibility” no ticket asked for.

**Pair with:** `@ponytail`, `@ponytail-review` — Brooks frames *why*; Ponytail finds *what to delete*.

---

## Related ideas

| Idea | Agent check |
|------|-------------|
| **Leaky abstraction** | Public API ok, but callers need internal knowledge to use it |
| **Distributed monolith** | Many packages/services, one change forces coordinated deploy |
| **Sympathy for the hardware** | Timeline/UI: avoid full reloads; local: respect SQLite/Tauri I/O |

---

## Integration (do not duplicate pipelines)

| Skill | Foundations role |
|-------|------------------|
| `@pingpong-solution` | Module boundaries in Step 4 options + Step 7 sketch |
| `@implement` | Pre/Post in acceptance §0; Parnas in §2–3 |
| `@verify-ticket` | Hoare: checkbox ↔ diff ↔ tests |
| `@review-ticket` | Full quick checklist; tag findings |
| `@ponytail-review` | Brooks tag `brooks:` |
| `@pr-merge-safe` | Scope = acceptance intent (Parnas + Hoare) |

## Quick checklist (review / design)

```
- [ ] parnas: Boundaries hide one decision; no leaky imports
- [ ] liskov: Contracts and invariants explicit; substitutes safe
- [ ] dijkstra: Control flow readable; async state owned
- [ ] hoare: Acceptance/tests match pre/post claims
- [ ] brooks: No accidental layers; essential complexity only
```

## Additional resources

- [references/checklists.md](references/checklists.md) — expanded questions + example findings
