# Hard bugs — escalation discipline

Use when the default `@debug` flow stalls: flaky, non-deterministic, performance regression, or no clear red signal after a normal reproduce attempt.

Sources (principles only — do not install as parallel entry skills):
- [mattpocock diagnosing-bugs / diagnose](https://www.skills.sh/mattpocock/skills/diagnose) — tight feedback loop first
- [obra systematic-debugging](https://www.skills.sh/obra/superpowers/systematic-debugging) — no fix without root cause; 3-strike architecture stop

Stay inside `@debug` → report → `@implement`. Do not start a second debug skill.

---

## Iron Law (always)

```
NO FIX PROPOSAL WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

In `@debug`: no Step-8 root-cause claim and no `@implement` handoff until evidence exists (repro and/or red-capable command + DevTools/logs). Symptom patches are failure.

---

## When to escalate to this doc

Escalate if any of:

- Flaky / timing / race (intermittent)
- Performance regression (“slow”, p95, jank)
- Cannot get a deterministic repro after one honest attempt
- Two+ fix attempts already failed (user or prior agent)
- Multi-component boundary unclear (CI → build → app, API → DB)

Otherwise stay on the main `@debug` checklist.

---

## A — Tight feedback loop (Matt)

**This is the escalation skill.** Without a fast, deterministic, agent-runnable pass/fail for *this* bug, do not hypothesise from reading code alone.

Try in order (stop when you have one red-capable command):

1. Failing test at the seam that hits the bug
2. `curl` / HTTP script against running server
3. CLI + fixture, diff stdout
4. Playwright asserting the user’s exact symptom
5. Replay captured payload/trace
6. Throwaway harness (minimal subset)
7. Fuzz / property loop (sometimes-wrong output)
8. `git bisect` harness (known-good → known-bad)
9. Differential (old vs new version/config)
10. Structured HITL only as last resort

**Tighten:** faster, sharper assertion on the symptom, more deterministic (pin time/RNG/network).

**Non-deterministic:** raise reproduction rate (loop 100×, stress, narrow windows) until debuggable — do not treat 1% flake as “done”.

**Cannot build a loop:** stop. List attempts. Ask for env access, HAR/log/dump, or temporary instrumentation. Do not invent a root cause.

**Done when:** one named command already run once (paste invocation + output), red on the user’s symptom, deterministic (or high flake rate), seconds not minutes, agent-runnable.

---

## B — Hypotheses (falsifiable)

After the loop is red:

1. Rank **3–5** hypotheses before testing any.
2. Each must predict: “If X is cause, then changing Y makes it disappear / Z makes it worse.”
3. Show the list to the user when cheap; proceed if AFK.
4. Instrument **one variable at a time**, mapped to a prediction. Tag logs `[DEBUG-<shortid>]` for cleanup.
5. Perf: measure baseline first (timing/profiler/query plan), then bisect — don’t spam logs.

Optional: `@zoom-out` once for module/caller map before deep instrumentation.

---

## C — Three-strike architecture stop (obra)

Count failed fix attempts (this session + known prior on same bug).

| Attempts | Action |
|----------|--------|
| 1–2 | Return to evidence / new hypothesis; one change at a time |
| ≥3 | **STOP.** Do not attempt fix #4. Question architecture (coupling, wrong layer, missing seam). Discuss with user; optionally `@foundations`. Note in report. |

Signs of architectural thrashing: each fix moves the symptom; “needs massive refactor”; new bugs appear elsewhere.

---

## D — Handoff back to main flow

1. Fill `@debug` report: red command, ranked hypotheses, strike count, architecture flag if ≥3.
2. Minimal fix hint only after root cause (Iron Law).
3. Regression: failing test at a **correct seam** before `@implement` applies the fix when a seam exists; if no seam, say so (architecture finding).
4. Cleanup: remove tagged `[DEBUG-*]` instrumentation in the implement pass.
