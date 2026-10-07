# Data / Complexity Scaling (Mode E)

User concurrency is not the only scale axis. Many apps fail when **data volume** or **structural complexity** grows.

## Three axes

```text
USER SCALE
1 → 10 → 100 → 1.000 → …

DATA SCALE
small → medium → large → extreme
(e.g. 1k → 10k → 100k → 1M records)

COMPLEXITY SCALE
simple project → medium → large → huge monorepo / dense graph
```

Run the axis that matches the hypothesis. Combine with Interaction or Runtime modes.

## Data scale workflow

1. Pick one interaction (list open, search, aggregate, export, …).
2. Prepare fixtures or environments at multiple sizes (synthetic OK if realistic cardinality/shape).
3. Measure Perceived Ready / Fully Ready at each size (same profile).
4. Plot or tabulate growth.
5. Inspect code for loops/joins/layout matching the curve.
6. Do **not** claim Big-O casually — say “consistent with superlinear growth” until code confirms.

Example (illustrative):

```text
1k nodes     80 ms
5k nodes    310 ms
10k nodes  1.2 s
20k nodes  5.1 s
```

## Complexity scale workflow

Especially for analysis / graph / repo tools. Stages to time separately when relevant:

- ingestion
- parsing
- dependency extraction
- graph construction
- graph layout
- rendering
- filtering / search
- selection / path highlighting
- data transfer
- caching
- persistence

Compare small vs huge inputs with the **same** code path instrumented.

## What to look for

| Pattern | Suspicious signal |
|---------|-------------------|
| Superlinear UI freeze | Layout O(n²), full re-render of all nodes |
| Transfer blow-up | Unpaginated payloads |
| Analyze time cliff | Re-parse everything; no incremental |
| Memory climb with size | Retaining full ASTs/graphs in UI |
| Filter slower than build | Naive scans each keystroke |

## Evidence bar

- Size parameters recorded (rows, nodes, edges, files, LOC, …)
- Repeated measurements per size (or honest single-run exploratory label)
- Code pointer to the hot function/algorithm when claiming algorithmic cause

## Handoff

- Hot path is SQL over large tables → Mode C + EXPLAIN at large cardinality
- Hot path is main-thread layout/render → Mode B
- Need many concurrent users on large data → Mode D (explicit) **and** Mode E
