# Foundations — expanded checklists

Use with `@foundations`. Tag findings in `@review-ticket` reports.

## Parnas — module decomposition

```
- [ ] Each new/changed module hides exactly one design decision
- [ ] Decision can change without touching unrelated modules
- [ ] Public surface is minimal (functions/types), not file paths
- [ ] No caller reaches into internal folders or private shapes
- [ ] Extension preferred over parallel duplicate module
```

**Example findings:**

- `parnas: Timeline hook imports ripple tree internals — expose extendSceneForAudio() instead.`
- `leaky: Component uses LocalBackend SQL column names — use domain type from adapter.`

## Liskov / ADT — contracts

```
- [ ] Inputs validated at trust boundary; invalid input → defined error
- [ ] Outputs documented: shape, ordering, empty vs null semantics
- [ ] Invariants stated (e.g. scene duration ≥ sum of blocks)
- [ ] Local and cloud paths return equivalent semantics for same input
- [ ] Tests assert behavior, not private fields
```

**Example findings:**

- `liskov: Cloud adapter throws; local returns null for missing id — unify error type.`

## Dijkstra — structure

```
- [ ] Single entry for feature flow; branches explicit
- [ ] No duplicate state sources for same UI field
- [ ] Async: loading/error/success states exhaustive
- [ ] Cleanup on unmount / cancel where subscriptions exist
- [ ] No business rules buried in JSX event handlers
```

**Example findings:**

- `dijkstra: Three useEffects update clip duration — one reducer owns duration.`

## Hoare — acceptance and verification

```
- [ ] Each Happy Path line is observable (UI, API response, test assertion)
- [ ] Edge Cases name the violated precondition or failure mode
- [ ] Unit/integration test covers at least one postcondition per behavior change
- [ ] verify-ticket: every checked AC has evidence in diff or test
- [ ] No PASS without running project checks
```

**Acceptance template pattern:**

```markdown
## Preconditions
- User has project open; scene exists with id …

## Happy Path (postconditions)
- [ ] After TTS attach, block duration equals audio length ± tolerance
```

**Example findings:**

- `hoare: Happy Path "saves correctly" — replace with observable file exists + SQLite row.`

## Brooks — complexity

```
- [ ] Change solves stated acceptance Intent, not hypothetical future
- [ ] New abstraction has ≥2 call sites OR clear roadmap ticket
- [ ] No new dependency for one function
- [ ] Refactor does not split one decision across many deploy units
- [ ] Essential domain complexity separated from framework glue
```

**Example findings:**

- `brooks: RippleStrategyFactory with one strategy — inline until second ripple type.`
- `monolith: functions/ + src/ must deploy together for one flag — merge boundary.`

## Cross-reference: Ponytail tags

| Ponytail tag | Brooks / foundations |
|--------------|----------------------|
| `yagni:` | Brooks — accidental abstraction |
| `delete:` | Brooks — remove non-essential |
| `stdlib:` / `native:` | Brooks — accidental reinvention |

Use `brooks:` when the issue is **essential vs accidental** framing; use `yagni:` when naming a specific cut.
