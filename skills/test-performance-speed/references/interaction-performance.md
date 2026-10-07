# Interaction Investigation (Mode A — default)

Goal: identify which real user actions are slow, quantify Perceived Ready vs Fully Ready, and attribute time along the critical path.

## Journey discovery

Derive candidates from:

1. Existing Playwright / E2E / QA flows (prefer reuse)
2. Router / navigation structure
3. Primary product surfaces (open entity, edit, save, preview, analyze, …)
4. User-reported slow actions (highest priority)

Prioritize by frequency → perceived delay → product relevance → technical complexity → risk.

Do **not** exhaustively click every UI control.

Journey examples are illustrative only — discover per project:

```text
auth → open primary workspace → open entity → open editor
  → switch tabs → open related detail → preview / media
  → save → return / open session
```

```text
open project → analyze / ingest → build graph or blueprint
  → render large view → filter → select node → show path
  → start preview
```

## Critical path template

For each action under test:

```text
click / input
→ first visual feedback          (Input Delay + early Presentation)
→ event handler                  (Processing)
→ state update
→ request start
→ server / backend work          (Backend Wait)
→ response received              (Network Wait split from backend when possible)
→ JS processing / parse
→ React / rendering
→ paint
→ async assets / workers
→ Perceived Ready
→ Fully Ready
```

### Timing buckets

| Bucket | Meaning |
|--------|---------|
| Input Delay | Event queued → handler start |
| Processing Duration | Handler + sync work before yield |
| Presentation Delay | Commit → pixels |
| Network Wait | Client wait excluding known server time |
| Backend Wait | Server / DB / edge time |
| Rendering | Framework render + layout/paint attributable to the action |
| Asset Loading | Downloads, decode, GPU upload, shader compile |
| Background Work | Non-blocking work after Perceived Ready |

## Perceived Ready vs Fully Ready

| Milestone | Definition |
|-----------|------------|
| **Perceived Ready** | User can meaningfully continue (content usable, primary controls live) |
| **Fully Ready** | All related async resources finished (models, textures, secondary fetches, background graphs, …) |

Always report both when they diverge (common with 3D, media, heavy graphs).

Insufficient alone:

```text
click → request complete
```

## Reproducibility protocol

1. Confirm environment (build mode preferred for absolute claims; note if dev-only)
2. Warm-up run(s) discarded or labeled
3. Repeat N times (prefer ≥10 for p95; ≥20 for p99)
4. Cold cache and warm cache when caching can dominate
5. Record errors / timeouts / outliers separately
6. Summarize with `scripts/summarize_timings.py`
7. If N is small: report median + range; **omit** p95/p99 or mark as exploratory

## Test profiles

Apply as relevant to the claim:

| Profile | Conditions |
|---------|------------|
| A | Fast desktop, warm cache |
| B | Fast desktop, cold cache |
| C | Average device (CPU throttle) |
| D | Average / slower network |
| E | Large realistic dataset / project |

State which profile produced each number. Goal: realistic user conditions, not only developer-Mac warm cache.

## Measurement tooling (pick what fits)

- Playwright: scripted journey + `performance.mark/measure` or trace
- Chrome performance traces / CDP
- Resource Timing / Navigation Timing / Long Task API
- Network waterfall (waterfall ≠ root cause by itself)
- Existing app marks if present

Reuse E2E helpers; add only minimal fixtures when required.

## Ranking slow interactions

Produce:

```text
| Rank | Interaction | p50 | p95 | Bottleneck (preliminary) | Confidence | Priority |
```

Then deepen the top offenders via [bottleneck-diagnosis.md](bottleneck-diagnosis.md).

## Exit criteria for Mode A

- Journeys listed with prioritization rationale
- Slowest interactions measured under named profiles
- Critical path with time splits for top issues
- Clear next mode if needed (Runtime / Backend / Data scale)
