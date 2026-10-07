# Performance Report Contract

Deliver this structure at the end of a full investigation. Omit empty scale sections only if Mode D/E were not requested — then state “not in scope”.

## Lead table (required)

```text
| Rank | Interaction | p50 | p95 | Bottleneck | Confidence | Priority |
|------|-------------|-----|-----|------------|------------|----------|
```

## Full outline

```markdown
# Performance Investigation

## Verdict
<!-- 2–5 sentences: what hurts users most, top lever, confidence -->

## Test Environment
<!-- machine/browser class, build mode, URLs/ports, data set, throttling, tool versions -->

## User Journeys Tested
<!-- prioritized list + why chosen; note reused E2E -->

## Baseline
<!-- profiles A–E used; sample sizes; warm-up policy -->

## Slowest Interactions
<!-- expand lead table with Perceived Ready vs Fully Ready -->

## Critical Paths
<!-- timed breakdowns with % -->

## Proven Bottlenecks
<!-- Finding contract fields per item -->

## Root Causes
<!-- white-box paths; PROVEN vs HYPOTHESIS clearly marked -->

## Scaling Behaviour
<!-- Mode D and/or E results; or "not in scope" -->

## Recommended Optimizations
<!-- OPTION A/B format with impact & trade-offs -->

## Rejected Optimizations
<!-- mandatory for considered-and-discarded ideas -->

## Priority Order
<!-- P0–P3 -->

## Expected Impact
<!-- per recommendation, on which metric -->

## Risks / Trade-offs

## Unknowns
<!-- unmeasured areas, blocked access, sample limits -->

## Validation Plan
<!-- before/after protocol per change -->
```

## Quality bar

- Numbers have profile + sample context
- No finding without evidence
- No recommendation without a bottleneck link
- Rejected options present when relevant
- Lighthouse score alone never constitutes the verdict
- Project names in examples must come from the investigated repo, not skill defaults

## Minimal mode

If the user asks for a quick pass: still include Verdict, Environment, Slowest Interactions table, top Critical Path, top Finding, and Validation Plan. Mark depth as `quick`.
