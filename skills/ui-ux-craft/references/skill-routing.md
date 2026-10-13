# Skill routing — compose, don’t duplicate

`ui-ux-craft` is the **UI/UX orchestrator**. Call sibling skills when installed; otherwise use the fallback column.

| Phase | Prefer (if present) | Fallback inside ui-ux-craft |
|-------|---------------------|----------------------------|
| Visual direction | `@frontend-design` | [design-direction.md](design-direction.md) |
| Landing / portfolio anti-slop | `@design-taste-frontend` | [design-direction.md](design-direction.md) marketing bias |
| UX laws / task completion | `@ux-design-laws` (manic-skills) | [ux-engineering.md](ux-engineering.md) |
| Mobile screen **concepts** (images) | `@imagegen-frontend-mobile` | Describe layouts; do not fake screenshots |
| Static guidelines / Adaptive soft | `@web-design-guidelines` | Pass 2 checklist in [quality-gates.md](quality-gates.md) |
| Browser proof | `@verify-ui` | Manual Pass 1–3 + mark UNVERIFIED |
| Complexity control | `@ponytail` / `@search-first` | Prefer local components; minimal deps |
| Deterministic build/lint | `@test-gate` | Project `checks` / `lint` if present |
| Mobile shell perf | `@mobile-performance-audit` | Pass 3 notes only |
| Journey perf | `@test-performance-speed` | Measure only if user/signals ask |
| Fast security/maintainability | `@audit-changes` | Not a substitute for visual QA |
| Ship gate | `@ecc-check` Phase E | Recommend after UI craft |

## Pipeline placement

```
@implement §8  →  @ui-ux-craft (orchestrate create)
     ↓
@web-design-guidelines → @verify-ui → @review-ticket → @ecc-check
```

During `@ecc-runner` / `@ecc-runner-loop` **implement** phase: attach `@ui-ux-craft` for new/reshaped UI (alongside or instead of calling design helpers ad hoc).

During **verify** phase: do **not** re-run full craft (A–E). Use `@web-design-guidelines` + `@ux-design-laws` spot-check + `@verify-ui`. `@verify-ui` may **read** [quality-gates.md](quality-gates.md) as a soft checklist — it must **not** invoke craft’s create loop.

## Anti-recursion

- Do not nest `@ui-ux-craft` inside itself.  
- Do not invoke `@implement` from within craft unless the user asked for a full ticket pipeline.  
- If both `@frontend-design` and craft run: craft owns workflow; frontend-design owns visual taste pass inside Phase C.

## Detection

Treat a skill as available if its `SKILL.md` is discoverable in the agent’s skill paths (`~/.cursor/skills`, `~/.claude/skills`, workspace skills, or manic-skills install symlinks). Missing → fallback; never fail the task solely because a sibling is absent.
