---
name: composition-gate
description: >-
  Cross-hop composition gate: reconstruct a business event's producer→consumer
  path, simulate N-actors / invalid fallback / concurrent consumers, and require
  CLEAR (or documented single-hop skip). Flagged findings must be verified and
  fixed, then the gate re-run. Use after implement / verify-ticket, before review
  ACCEPT, ecc-check READY, commit-pr-safe, or pr-merge-safe; or when the user says
  composition-gate, composition, hop chain, fan-out, pipeline semantics, or path
  logic.
disable-model-invocation: true
---

# Composition Gate

End-to-end **meaning** across hops. Not types, lint, secrets, ticket wording, or UI pixels.

Local files may be correct. This gate fails when the **composed path** changes cardinality, destination, audience, or identity of a business event.

**Flagged findings are not notes.** Verify they are real, **fix them**, re-run until **CLEAR**. `@implement` must write code so this gate would CLEAR.

## Pipeline position

```
@implement → @verify-ticket → @composition-gate → @verify-ui → @review-ticket → @ecc-check
→ @commit-pr-safe → @pr-merge-safe
```

Ship skills (`@commit-pr-safe`, `@pr-merge-safe`, `@ecc-check`) **run this gate or accept a proof** for the current `HEAD` SHA. Missing / stale / `FLAGGED` proof → run now. `FLAGGED` → fix loop, do not ship.

## Exit states

| State | Meaning | Next |
|-------|---------|------|
| **CLEAR** | Simulations match intended meaning; no open blocker/flag | Continue pipeline |
| **SKIPPED** | Documented single-hop / docs-only / no producer–consumer path | Continue pipeline |
| **FLAGGED** | Composed meaning is wrong or can silently change | **Fix, then re-run** — not ACCEPT / READY / PR |
| **BLOCKED** | Fix retries exhausted | Hand to `@implement`; do not ship |

## When to run

- After `@implement` / `@verify-ticket`, before `@review-ticket` ACCEPT
- Inside `@ecc-check`, `@commit-pr-safe`, `@pr-merge-safe` if proof missing or SHA mismatch
- User: `composition-gate`, `composition`, `hop chain`, `Pfad-Logik`, `fan-out`

## When to skip (must document)

Skip **only** if all apply:

- Diff is a single hop (one module, no downstream consumer of new records)
- No bulk→side-effect, queue/worker/cron/webhook/outbox, or write-in-A / read-in-B
- No override/fallback that can change destination, audience, or tenant

Write skip reason + `HEAD` SHA into the proof. Guessing skip is FAIL.

## What this is not

- Not `@review-ticket` (architecture, types, maintainability)
- Not `@verify-ticket` (AC checkboxes, tests green)
- Not `@security-review` / P-06 alone (P-06 is the outbox **specialization**; this is the general method)
- Not domain-rule review (`expiresAt >= publishAt`) — that stays ticket + tests

## Proof (mandatory)

Write both:

1. `.qa/runs/composition-gate-<slug>.md` (create `.qa/runs/` if needed)
2. Acceptance section `## Composition Gate` in `.qa/acceptance/<slug>.md` when that file exists

Proof must include `HEAD_SHA` from `git rev-parse HEAD` (or uncommitted marker: `WORKTREE` + diff stat). Stale SHA → re-run.

```markdown
# Composition Gate — <slug>

- HEAD_SHA: <sha or WORKTREE>
- Date: YYYY-MM-DD
- Verdict: CLEAR | SKIPPED | FLAGGED | BLOCKED

## Event
<one sentence>

## Hop chain
Producer (file) → persist → transform → consumer → side-effect → UI-label

## Simulations
| Case | Intended | Composed | Result |
|------|----------|----------|--------|
| 1 event, N actors | | | pass / tag |
| invalid / missing | | | pass / tag |
| 2 consumers / crash | | | pass / tag |

## Flags
| Tag | Severity | Hops | Why local review missed it | Fix |
|-----|----------|------|----------------------------|-----|
| … | blocker / flag / note | … | … | done / open |

## Skip reason
n/a | <one line>
```

`@commit-pr-safe` / `@pr-merge-safe`: accept proof only if verdict is **CLEAR** or **SKIPPED** and SHA matches current HEAD (or WORKTREE matches current uncommitted scope).

## Method (do not review file-by-file)

### 1. Pick events, not files

From diff + acceptance, name 1–3 business events (“HR publishes an announcement”, “order is paid”). Unchanged files **on the path** still count.

### 2. Reconstruct the hop chain

```
Producer → Persistenz → Transform/Enqueue → Worker/Consumer → Side-effect → UI-label
```

If the producer is new and the worker is old: **read the worker**.

### 3. Run three simulations (mandatory)

| Simulation | Question |
|------------|----------|
| **N-actors** | 1 event × 10 recipients/items/tenants — how often does the user-visible effect happen? |
| **Invalid/missing** | Bad override, missing config, unknown type — fail-closed or silently different meaning? |
| **Two consumers / crash** | Second poll, second instance, crash after claim — duplicate, loss, or starvation? |

### 4. Tests vs the invariant

Do not ask “is the unit test green?”. Ask: would a test of the **composed** invariant fail? Does an existing test **lock in** the accident (`test-lock:`)?

### 5. Fix loop (mandatory)

For every `blocker` and `flag`:

1. Confirm it is real on the hop chain (not a false positive).
2. **Fix it** in scope (or hand to `@implement` if this invocation is review-only *and* the caller is `@review-ticket` — then verdict is not ACCEPT until fixed).
3. Re-run the three simulations on the new code.
4. Max **2** fix rounds here, then **BLOCKED**.

`note` (divergent copy, label-lie, dead-path) must be fixed when it can change meaning; otherwise record and continue.

**Never** ship, ACCEPT, READY, or open a PR with open `blocker`/`flag` rows.

## Tags (domain-agnostic)

| Tag | Question |
|-----|----------|
| `cardinality:` | 1 event → how many side-effects? |
| `identity:` | What uniquely *is* this event? Dedup key survive? |
| `reinterpret:` | Later hop reads a different field for the same fact? |
| `override:` | Generic escape hatch bypasses type/policy? |
| `silent-fallback:` | Invalid input becomes a *different* valid destination? |
| `stuck-state:` | Crash between two writes — recovered? |
| `starvation:` | Poison items occupy the work set and block new work? |
| `race:` | Two consumers, same item, both side-effect? |
| `test-lock:` | Tests freeze the accidental contract? |
| `dead-path:` | Tests cover unused helpers; production duplicates the rule? |
| `divergent-copy:` | Same rule copied in N files? |
| `label-lie:` | UI/schema comment ≠ actual composed rule? |

P-06 (outbox fan-out, non-atomic claim, failed-row starvation, processing without recovery) maps to `cardinality` / `race` / `starvation` / `stuck-state`. Use those tags; still apply the P-06 manual gate when the path is a worker.

## Implement intent (when `@implement` is running)

Do **not** wait for this gate. While coding:

- State cardinality in Happy Path (**once per event** vs **once per recipient**).
- One source of truth per fact (do not let `row.type` and `payload.type` diverge).
- Invalid override/config **fails closed** or stays on the type default — never silently retarget.
- Bulk producer + shared channel/email/webhook → **one** side-effect per event unless acceptance says otherwise.
- Claim work atomically; do not leave `processing` unrecoverable; do not poll terminal failures in the same limited batch.
- Tests lock the intended composed invariant, including N-actors.

If a path would fail the three simulations, **do not write it**.

## Report (chat)

```markdown
## Composition Gate — CLEAR | SKIPPED | FLAGGED | BLOCKED

- HEAD_SHA: …
- Proof: `.qa/runs/composition-gate-<slug>.md`

### Event
…

### Hop chain
…

### Simulations
| Case | Intended | Composed | Result |

### Flags
| Tag | Severity | Status |
```

## Guardrails

- Do not file-review. Trace one event.
- Do not only regex for `pending`+`failed` — that is test-gate / P-06.
- Do not treat green unit tests as composed proof.
- Do not leave `FLAGGED` as “noted”.
- Do not skip because “another skill might catch it”.

## Additional resources

- Worked examples (Slack fan-out is **one** pattern, not the checklist): [examples.md](examples.md)
