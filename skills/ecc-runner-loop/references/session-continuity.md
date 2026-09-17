# ECC Runner Loop — session continuity

## Goal

Keep the ship loop recoverable across a long queue without fake “paused for compact” hard stops. Prefer explicit user `/compact` (or a fresh chat + handoff) over unreliable auto-compact.

## AGENTS.md policy (project wins)

If `AGENTS.md` has **Context compact & long queues (mandatory)** (written by `@project-setup` / AGENTS skeleton), that section **overrides** looser defaults below.

After every shipped issue in an N>1 queue:

1. Update the handoff file with last merged issue/PR/SHA and next issue # + title (`paused: false` unless a true hard stop).
2. **Stop the turn** — tell the user to run `/compact` (or open a fresh chat and `@ecc-runner-loop continue` with the handoff). Use `@strategic-compact` for when/how guidance.
3. Do **not** claim the next issue in the same turn. Resume only after the user continues post-compact (or in the new chat with handoff loaded).

**Never compact mid-implementation** of the current issue.

## When AGENTS compact policy is absent

After issue complete (merge + sync), before starting the next issue, if **any**:

- Queue remaining length > 3
- ≥ 3 issues merged in this agent session
- Large reads / many tool calls / responses getting weaker (context pressure)

**Do:** Invoke `@strategic-compact` and/or ask the user to `/compact`. Prefer ending the turn for `/compact` over continuing mid-pressure.

**Do not:** Write a “Loop — paused” report. **Do not** set `lastError` to “session compact”. Waiting for `/compact` is **not** `paused: true`.

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

Also ban: claiming the next issue in the **same turn** right after a ship when AGENTS compact policy is present.

Correct equivalent:

```text
paused: false
# handoff updated → end turn → user /compact → @ecc-runner-loop continue
# OR @handoff with paused: false for the next agent / fresh chat
```
