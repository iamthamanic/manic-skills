# Runtime Profiling (Mode B)

Use when Interaction Investigation shows substantial time in main-thread JS, rendering, layout, GPU, parsing, or memory — or when the user names those symptoms.

## Scope

Investigate only layers with measured contribution:

- Main thread / event loop / long tasks
- JavaScript execution (sync handlers, parsers, layout algorithms)
- React rendering and re-renders (only if render time is material)
- Layout / reflow / style recalc / paint
- GPU / WebGL / Three.js / canvas
- Large DOMs / virtualization gaps
- Graph layout and graph rendering
- Asset decode / texture upload / shader compilation
- MediaPipe or similar WASM/worker pipelines
- Memory growth / leaks / GC pressure

## Workflow

1. Start from a **named interaction** and its critical-path slice.
2. Capture a performance trace for that interaction (cold and warm if relevant).
3. Attribute wall time to: script, render, layout, paint, GPU, idle/wait.
4. If React is suspected: Profiler or render instrumentation **only after** render % is non-trivial.
5. For 3D/canvas: separate download vs parse vs GPU upload vs shader compile vs frame cost.
6. For graphs/lists: measure with increasing node/row counts → see Mode E.
7. Confirm with a second run; watch for trace overhead distorting absolute times.

## Hypothesis menu (not findings)

Use as a search checklist. Promote to finding only with evidence.

**Frontend / runtime**

- Unnecessary re-renders / context fan-out
- Sync main-thread work on click path
- Long tasks >50ms blocking input
- Layout thrashing (read/write interleaving)
- Oversized DOM without virtualization
- Wrong data structures for hot loops
- Eager imports / large chunks on critical path
- Request waterfalls in client logic
- Expensive JSON parse on large payloads
- GLB/texture decode on first interaction
- Shader compilation stalls
- Unbounded listeners / leaks

## Evidence types

| Evidence | Good for |
|----------|----------|
| Performance trace (script/layout/paint) | Main-thread attribution |
| Long Task entries | Input jank |
| React Profiler commit durations | Re-render cost |
| `performance.measure` around known functions | Code-path timing |
| Heap snapshots / allocation timelines | Leaks / retained size |
| Frame times / GPU work | 3D/canvas |

## Anti-patterns

- Recommending memoization when render is <~15% of the interaction
- Blaming “React is slow” without commit timings
- Treating FPS drops during idle animations as equal to interaction latency
- Optimizing micro-benchmarks that never appear on the user journey

## Handoff

- If wait time is mostly network/server → Mode C
- If cost grows superlinearly with data/graph size → Mode E
- Always close findings per [bottleneck-diagnosis.md](bottleneck-diagnosis.md)
