# Bottleneck Diagnosis & Evidence

## Critical path attribution

For each slow interaction, produce a timed breakdown. Example shape:

```text
OPEN ENTITY — 2590 ms   (profile B, n=12, p50)

UI event handling ............ 24 ms    (1%)
Backend request ............. 1035 ms   (40%)
  network .................... 42 ms
  auth / policy .............. 85 ms
  SQL ....................... 908 ms
React rendering ............. 286 ms   (11%)
Async assets ............... 1210 ms   (47%)
  download .................. 410 ms
  parse ..................... 260 ms
  texture decode ............ 370 ms
  shader compilation ........ 170 ms
```

Use percentages to kill irrelevant levers (“React is 11% → memoization is not P0”).

## White-box trace

After the largest slices are known, follow the real path:

```text
UI control → handler → domain/service → client SDK
  → API / Edge → RPC → DB → policies / storage / external
```

Stop when evidence explains the measured slice. Do not tour unrelated architecture.

## Finding contract

Every real finding **must** include:

```text
Observation
Evidence
Affected interaction
Measured impact
Likely root cause
Confidence
```

### Confidence levels

| Level | Meaning |
|-------|---------|
| **PROVEN** | Controlled measurement + causal link (e.g. before/after or direct trace to code/plan) |
| **STRONG EVIDENCE** | Multiple consistent signals; residual uncertainty documented |
| **LIKELY** | Best explanation fits data; alternative not ruled out |
| **HYPOTHESIS** | Plausible; next experiment defined; **not** an implementation mandate |

Never inflate confidence. If root cause unproven, mark `HYPOTHESIS` and define the next test.

## Concrete vs vague

**Bad:**

```text
The application could benefit from caching.
```

**Good:**

```text
Opening the editor issues the same ~780 KB metadata request three times
during one navigation.

Measured contribution: ~640 ms of the 2.4 s p50 interaction time.
Cause: three independently mounted components fetch the identical resource.
Recommendation: fetch once at the route/domain boundary and reuse.
Expected impact: ~400–650 ms on cold navigation.
Trade-off: shared request lifecycle ownership.
Confidence: STRONG EVIDENCE.
```

## Correlation ≠ causation

Examples of non-causal traps:

- Slow page *and* large bundle → bundle may be unrelated to this click path
- High DB CPU under load → maybe lock waits, not “needs bigger CPU”
- Re-render count high → may be cheap renders; check duration

## Unknowns

List what was not measured (no staging data, no prod traces, missing EXPLAIN rights, …) and how that bounds confidence.
