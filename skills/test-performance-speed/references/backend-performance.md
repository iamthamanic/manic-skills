# Backend Investigation (Mode C)

Use when Interaction Investigation shows material Network/Backend Wait, or the user names API/DB/Edge symptoms.

## Scope

- HTTP/API latency and payload size
- Edge / serverless functions (incl. cold starts)
- BaaS clients (e.g. Supabase) and Auth
- PostgreSQL / SQL / RPC
- RLS policy overhead
- Storage downloads / signed URLs
- N+1 and chatty round trips
- Connection pools / queueing
- Serialization / over-fetch (`SELECT *`, wide joins)
- Extra service hops / external APIs
- Missing or incorrect caching (only if proven)

## Workflow

1. Tie every probe to a **user interaction** and request IDs / URLs from that path.
2. Split client-observed time:
   - DNS/TCP/TLS (when relevant)
   - TTFB vs download
   - Server processing (logs, traces, function timing)
3. For each slow request: payload size, row counts, fan-out (parallel vs sequential).
4. White-box: handler → service → DB/RPC → policies.
5. For SQL: `EXPLAIN (ANALYZE, BUFFERS)` on realistic data — staging/local preferred.
6. Check RLS and row filters as first-class cost centers when authz is on the path.
7. Distinguish cold start vs warm invoke for edge/serverless.
8. Re-measure the interaction after any change (before/after contract).

## Hypothesis menu (not findings)

- N+1 queries / per-item requests
- Slow SQL (seq scans, bad joins, missing/wrong indexes)
- RLS re-evaluation cost / non-sargable policies
- Over-fetch / large JSON
- Edge cold start
- Pool exhaustion / wait in queue
- Serial waterfalls that should be parallel or single RPC
- External API on critical path
- Locking / contention under modest concurrency
- Duplicate identical requests from multiple mounts

## Evidence types

| Evidence | Good for |
|----------|----------|
| Resource Timing + response sizes | Client-visible network |
| Server/function logs with durations | Backend Wait |
| EXPLAIN ANALYZE | Query root cause |
| DB stats (pg_stat_statements if available) | Hot queries |
| Repeat cold vs warm invoke | Cold start |
| Parallel request waterfall screenshot/HAR | Chatty client |

## Safety

- Prefer local/staging DB for EXPLAIN and heavy probes
- Do not run destructive migrations or mass writes as “perf tests”
- Redact secrets from logs/HAR in the report

## Anti-patterns

- Adding indexes without proving the slow plan
- “Just cache it” without invalidation/consistency analysis
- Blaming RLS generically without policy/plan evidence
- Optimizing an endpoint not on the slow journey

## Handoff

- Sustained concurrency / capacity → Mode D (explicit only)
- Growth vs table/graph size → Mode E
- Client parse/render of large responses → Mode B
