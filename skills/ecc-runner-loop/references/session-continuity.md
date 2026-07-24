# ECC Runner Loop — session continuity

## Goal

Keep the ship loop running across a long queue. Context management must **not** look like a user-facing pause.

## When to compact (same session)

After issue complete (merge + sync), before starting the next issue, if **any**:

- Queue remaining length > 3
- ≥ 3 issues merged in this agent session
- Large reads / many tool calls / responses getting weaker (context pressure)

**Do:** Invoke `@strategic-compact` (or ask the user to `/compact` only if the skill requires a manual compact step — then **resume the loop in the same turn series** without setting `paused: true`).

**Do not:** Write a “Loop — paused” report. **Do not** set `lastError` to “session compact”.

## When to handoff (new agent / session)

If the **current** Cursor session cannot continue (hard window limit, user closing chat, agent swap):

1. Write `@handoff` OS-temp brief with: repo path, `state.json` snapshot, next queue issue `#N`, branch strategy (`main`), last merged PR, phase `idle` / next `implement`, `paused: false`
2. Leave `runMode: "loop"`, `paused: false`
3. End turn **without** a pause report (or one line: handoff written — next agent `@ecc-runner-loop continue`)

Next agent: bootstrap → sync → pick next issue — no waiting for merge approval.

## When pause is allowed

Only:

- User: `ecc-runner-loop pause`
- Hard stops in `SKILL.md` (merge blocked, retries exhausted, secrets, etc.)

Then: `paused: true`, `@handoff`, user-facing report.

## Anti-patterns (seen in the wild — ban these)

```text
paused: true
lastError: "session compact pause after CR-0xx"
# chat: "Resume: @ecc-runner-loop continue"
```

Correct equivalent:

```text
paused: false
# @strategic-compact then implement next issue
# OR @handoff with paused: false for the next agent
```
