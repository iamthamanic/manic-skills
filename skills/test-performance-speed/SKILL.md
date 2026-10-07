---
name: test-performance-speed
description: >-
  Systematic performance engineering for web apps: measure critical user
  journeys, attribute bottlenecks across UI/runtime/network/backend/DB, prove
  root causes with evidence, compare optimization options with trade-offs, and
  optionally run load/data/complexity scaling. Not a Lighthouse score skill.
  Use when the user mentions slow app, performance bottleneck, laggy UI,
  slow button/action, runtime profiling, backend latency, k6 load test,
  scaling under users/data/complexity, or invokes @test-performance-speed /
  test-performance-speed / scale performance.
disable-model-invocation: true
---

# test-performance-speed

Work like a senior performance engineer. The question is never only “how fast?”
but: **which user action is slow, where time is spent on the critical path, why,
and which change yields the largest measurable effect under which trade-offs.**

Apps such as SagaDrive or VisuDev are **reference workloads only**. Never hardcode
project-specific journeys, ports, schemas, or stack assumptions. Discover each
target repo fresh.

## Iron rules

1. No optimization proposal without a measured or otherwise evidenced bottleneck.
2. No performance claim without evidence.
3. No successful optimization without before/after measurement.
4. Correlation is not causation.
5. No reflexive `useMemo` / caching / workers / indexes / architecture rewrites
   until that layer is proven relevant.
6. Measure → localize → root-cause → evaluate options.
7. Change one essential variable per optimization attempt.
8. Prefer median/p50, p95, p99, errors — not averages alone. Flag small samples.
9. Separate **Perceived Ready** from **Fully Ready**.
10. Never silently trade correctness, security, consistency, UX, or maintainability.

## Modes (select automatically)

| Mode | Trigger signals | Read |
|------|-----------------|------|
| **A. Interaction Investigation** | Default. “slow”, “laggy”, “why does X take…”, “find bottlenecks” | [interaction-performance.md](references/interaction-performance.md) |
| **B. Runtime Profiling** | Main thread, React renders, long tasks, layout, GPU, Three.js, canvas, DOM, graph, parsing, memory | [runtime-performance.md](references/runtime-performance.md) |
| **C. Backend Investigation** | API, Edge Functions, Supabase, Postgres/RLS/RPC, storage, N+1, cold starts, payloads | [backend-performance.md](references/backend-performance.md) |
| **D. Scale / Load** | Explicit `scale`, concurrent users, req/s, capacity, soak — **never automatic** | [load-scaling.md](references/load-scaling.md) |
| **E. Data / Complexity Scaling** | Large datasets, repos, graphs, O-growth suspicion | [data-complexity-scaling.md](references/data-complexity-scaling.md) |

Modes combine when evidence requires it (e.g. Interaction → Backend → Runtime).
Diagnosis + options + report rules always apply:

- [bottleneck-diagnosis.md](references/bottleneck-diagnosis.md)
- [optimization-tradeoffs.md](references/optimization-tradeoffs.md)
- [report-contract.md](references/report-contract.md)

## Autonomous pipeline

```text
discover → journey map → reproduce → measure → rank
  → critical path → white-box trace → diagnose
  → options + rejected → priority → validation plan
```

If the user asks for scale (`@test-performance-speed scale` or clear load wording),
append:

```text
workload model → load ramp → capacity search → sustained test
  → resource attribution → capacity report
```

Do **not** start aggressive load tests unless scale mode is explicit.

## Phase 0 — Project discovery

Before measuring, build a **Performance Map** from what exists:

- `AGENTS.md`, `README.md`, `package.json`, start/build scripts
- `.qa/**`, architecture docs, Docker Compose
- DB / Supabase / Edge Functions / API layer
- Frontend structure, state management
- Browser/E2E tests, existing perf marks/instrumentation
- Local ports, preview/production config

Map (extend as needed):

```text
Browser → UI/React → State → Network → API/Edge → DB/Storage/providers
```

Identify tools available in-environment; pick the smallest set that produces
evidence (Playwright, Performance API/traces, DevTools, k6, EXPLAIN ANALYZE,
docker/process metrics, logs). Lighthouse is **supplementary only**.

Reuse existing Playwright/E2E journeys; instrument rather than rewrite.

## Phase 1 — Critical user journeys

Derive real actions from UI, routing, E2E tests, and product structure.
Prioritize by: frequency → perceived delay → product relevance → complexity → risk.
Do not blind-test every control.

For each slow action reconstruct:

```text
click/input → first visual feedback → handler → state → request
  → backend → response → JS → render → paint → async assets
  → Perceived Ready / Fully Ready
```

## Phase 2 — Measurement

- Warm-up, then multiple repeats; cold vs warm cache when relevant
- Profiles: fast desktop warm/cold; CPU throttle; slower network; large realistic data
- Report p50 / p95 / (p99 if sample allows), errors, outliers, variability
- Label insufficient samples — no false precision

Helper (deterministic percentiles from JSON samples):

```bash
python3 ~/.cursor/skills/test-performance-speed/scripts/summarize_timings.py samples.json
```

## Phase 3 — Attribution & root cause

Build a timed critical path with % contribution. Follow white-box into code/services.
Hypothesis lists ≠ findings. Findings need Observation, Evidence, Interaction,
Measured impact, Likely root cause, Confidence (`PROVEN` | `STRONG EVIDENCE` |
`LIKELY` | `HYPOTHESIS`).

## Phase 4 — Options & priority

For each proven bottleneck: multiple options + rejected options + trade-offs.
Rank by impact × confidence / cost → P0–P3. Micro-opts stay P3 while larger
bottlenecks remain.

Before/after uses the **same** reproducible measurement. Verdict: `KEEP` or
`REJECT / REVERT`. Do not retarget the benchmark to flatter a change.

## Phase 5 — Report

Emit the structure in [report-contract.md](references/report-contract.md).
Lead with the ranking table, then concrete findings (numbers, path, expected
impact, trade-offs). Vague advice (“add caching”) is a failure mode.

## Load-test safety

- Prefer localhost/staging; identify target before strong load
- Production only with explicit permission and safe config
- Mock or avoid third parties that incur cost/rate limits
- Isolate writes; never trash real user data
- Interaction/runtime audits may run locally by default; load tests may not

## Scripts

| Script | Use |
|--------|-----|
| [scripts/summarize_timings.py](scripts/summarize_timings.py) | p50/p95/p99, mean, min/max, errors from timing sample JSON |
