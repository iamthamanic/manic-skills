# Optimization Options, Rejected Solutions & Before/After

## Option comparison format

For each relevant bottleneck, compare multiple sensible options — do not emit a single “just do X”.

```text
BOTTLENECK
Evidence:
...
Root cause:
...

OPTION A — <title>
Expected impact:
Why:
Advantages:
Trade-offs:
Risks:
Implementation complexity:
Confidence:

OPTION B — <title>
...

REJECTED OPTION — <title>
Why rejected:
```

## Dimensions to weigh

Evaluate at least where applicable:

- Expected impact (ms / % on p50 & p95 of the interaction)
- Implementation effort
- Architecture complexity
- Maintainability
- Memory / CPU / network
- Data consistency & cache invalidation
- Security / authz correctness
- UX (especially Perceived Ready)
- Operating cost
- Scalability (user / data / complexity axes)
- Regression risk

Optimizations must not silently worsen correctness, security, consistency, UX, or maintainability.

## Rejected solutions (mandatory when considered)

Document tempting ideas that evidence kills. Example:

```text
REJECTED: Replace client state management library

Reason:
State updates account for ~4% of the measured critical path.
Migration cost is disproportionate to expected improvement.
```

This prevents performance work from becoming architecture activism.

## Priority

Sort by qualitative **Impact × Confidence / Cost** (do not fake numeric precision).

| Priority | Meaning |
|----------|---------|
| **P0** | Severe user-facing bottleneck |
| **P1** | High-impact optimization |
| **P2** | Meaningful improvement |
| **P3** | Micro-optimization / low leverage |

Do not prioritize P3 while P0/P1 remain open.

## Before / After contract

An optimization is successful only after the **same** reproducible measurement.

```text
BEFORE
Interaction: …
Profile: …
p50 …
p95 …

CHANGE
<one essential variable>

AFTER
p50 …
p95 …

RESULT
p50 …%
p95 …%

REGRESSIONS
…

VERDICT
KEEP | REJECT / REVERT
```

Rules:

- One essential variable per attempt when possible
- Do not change the benchmark definition to make a change look good
- If improvement is not measurable → `REJECT / REVERT`
- Note any Perceived Ready vs Fully Ready shifts

## Validation plan

For each recommended option, state:

1. Exact interaction + profile + sample size
2. Metrics that must improve
3. Guardrail metrics that must not regress
4. How to roll back
