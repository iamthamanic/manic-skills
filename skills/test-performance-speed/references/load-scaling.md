# Scale / Load Test (Mode D — explicit only)

Activate only when the user asks for scale/load/capacity (`@test-performance-speed scale`, “concurrent users”, “req/s”, soak, capacity, etc.).

Do **not** attach aggressive load tests to a normal interaction audit.

Methodology inspiration: scientific load testing workflows (e.g. capacity discovery via ramp + binary search), not a specific vendor stack. Prefer **k6** for HTTP/backend load when available and appropriate.

## Safety (mandatory before strong load)

1. Identify target environment
2. Prefer localhost / staging
3. Production only with **explicit** permission and documented safe config
4. Avoid or mock third-party APIs that create cost or rate-limit damage
5. Isolate write scenarios; never mutate real user data
6. Confirm abort criteria (error rate, latency cliff, owner signal)

## Scientific sequence

```text
1. Functional sanity / conformance
2. Warm-up
3. Baseline (single-VU or low load)
4. Realistic virtual-user workload
5. Fast capacity probes
6. Increase load
7. Find pass/fail boundary
8. Binary-search-like narrowing
9. Sustained confirmation (soak)
10. Resource saturation diagnosis
```

Separate short discovery runs from sustained runs in the report.

## Realistic load model

Primary capacity test = **journey-weighted** workload, not pure endpoint hammering.

Include:

- Think/wait times
- Read/write mix
- Weighted actions
- Auth when required
- Different personas if product-relevant

Endpoint hammering is optional **supplement** for raw throughput ceiling.

Example shape (adapt per product):

```text
open primary surface → wait
open entity → wait
sometimes edit → rarely create
repeat
```

## Capacity search

Do not only hit round numbers (100 / 1000 / 10000). Search the boundary:

```text
100 → 250 → 500 → 1000 → 2000  FAIL
→ 1500 PASS → 1750 PASS → 1875 FAIL → …
```

Report:

| Metric | Meaning |
|--------|---------|
| Safe capacity | Load with healthy headroom vs thresholds |
| Degradation point | Where p95/p99 or UX clearly worsens |
| Failure boundary | Where errors/timeouts/saturation break SLO |

## Thresholds

- Prefer project SLOs if present
- Else propose defaults and **label them as defaults**

Example API-oriented defaults (not universal truth):

```text
p95 <= 500 ms
p99 <= 1000 ms
errors <= 1%
```

User-facing browser interactions may need different budgets; state them explicitly.

## Soak / sustained

After a candidate safe level, run longer to detect:

- Memory leaks / GC pressure
- Pool exhaustion / connection leaks
- Queue growth
- Cache degradation
- Locking / rising latency over time
- Thermal/CPU saturation

## Resource attribution

Observe separately when possible:

```text
reverse proxy · app · edge/functions · database · workers
CPU · RAM · network · disk · connection pools
```

High CPU on one process is a clue, not a verdict. Example: App 22% + Postgres 64% → investigate DB/query/IPC next.

## Output additions

Extend the main report with:

- Workload model
- Ramp / capacity search table
- Safe / degrade / fail points
- Soak results
- Saturated resource(s) with evidence
