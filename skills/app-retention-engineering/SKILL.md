---
name: app-retention-engineering
description: >-
  Audit, design, implement, and experiment with product/app user retention: activation and habit loops, churn or next-day-return scoring, event instrumentation, lifecycle messaging, personalized push reminders, send-time optimization, streaks, and re-engagement. Use when a user asks how to improve D1/D7/D30 retention, reduce app churn, build Duolingo-like retention systems, personalize notifications, analyze return probability, implement notification decisioning, or add privacy-respecting behavioral analytics to an app. For video audience-retention curves use retention-graph-audit instead; for paid ad retargeting use retargeting-funnel.
---

# App Retention Engineering

Turn the useful engineering ideas from the Duolingo reverse-engineering reel into an ethical, measurable retention system for the user's actual product. Do not clone unverified internal code or optimize notification volume at the expense of user value.

## Operating modes

- **Audit:** Inspect the current retention funnel, tracking, messages, opt-outs, and data flows; identify evidenced gaps.
- **Design:** Produce a minimal target architecture, prioritized implementation slices, measurement plan, and privacy controls.
- **Implement:** Read the repository and existing conventions, make scoped changes, write tests and migrations, and verify behavior. Never assume a framework or database.
- **Experiment:** Define incremental-lift tests, holdouts, guardrails, and rollout/rollback criteria.

If the user does not specify a mode, select the smallest mode that delivers their request. Do not implement infrastructure just because it appeared in a viral video.

## Workflow

### 1. Establish the value event and measurement

1. Identify the product, primary user job, repeat-use cadence, activation milestone, meaningful return event, and business outcome. A login/open is not automatically meaningful retention.
2. State the population and exclusions: new vs existing users, paying vs free, timezone, bots/test accounts, deleted accounts, dormant cohorts.
3. Examine available event definitions and their reliability. Distinguish event time from ingestion time; verify deduplication and user identity stitching.
4. Compute/cohort baseline D1/D7/D30 or a domain-appropriate interval, activation rate, feature adoption, and notification opt-out. Define local calendar-day vs rolling-24-hour retention explicitly.
5. If evidence is absent, mark **MEASUREMENT BLOCKED** and propose the minimum instrumentation before introducing ML or personalization.

Use `references/architecture-and-events.md` for event contracts, metrics, and model safeguards.

### 2. Build a signal inventory, not a surveillance system

Prefer first-party, necessary events already arising from core product use:

- app/session open, source (`notification`, `widget`, `launcher`, `direct_link`, `unknown`), and meaningful activity;
- completed workflows, learning/tasks completed, errors or crashes, and session frequency;
- user-chosen goals, streak state if useful, engagement preferences, local timezone, and opt-in/opt-out state;
- notification eligibility, decisions, sends, delivery when available, opens, and downstream value events.

Track only demonstrably useful fields. Never require raw Wi-Fi identifiers, device fingerprinting, inferred home location, microphone, or ringer/silent-mode surveillance. The reel mentions such claims; they are **not** implementation requirements. Check `references/source-fidelity-and-privacy.md` before using unusual device/context signals.

### 3. Select the least complex effective prediction

1. Start with cohort rules and transparent recency/frequency metrics (for example, days since last meaningful action); compare against a no-model baseline.
2. Define a future label without leakage: `return_on_next_local_calendar_day`; features must be available **before** the score timestamp.
3. Add a calibrated probability model only with sufficient clean history, valid labels, appropriate privacy basis, and evidence that it improves decisions. Keep model version, timestamp, feature freshness, and uncertainty.
4. Evaluate calibration and cohort stability, not just classification accuracy. Critically, high churn risk does **not** imply a notification will cause the person to return. Measure causal incremental lift separately.
5. Use safe fallbacks for cold starts, no consent, stale features, missing model output, or low confidence.

### 4. Design the intervention policy

Create a deterministic **eligibility gate** before any personalization:

`active account -> valid purpose/legal basis -> channel permission/preferences -> not already completed goal -> suppression/quiet hours -> frequency/cooldown -> dedupe -> experiment allocation -> timing/content -> send`

- Match message to the user's opted-in goal, not inferred vulnerabilities or fear of loss.
- Prefer user-selected reminder windows; only optimize timing from permitted historical activity when validated.
- Use relevant in-app guidance when push is unavailable; never work around an opt-out through another channel.
- Suppress already-completed goals and recently active users. Prevent repeated identical reminders.
- Use streaks, leaderboards, and friends only if those features already exist and are beneficial; never fabricate social activity or urgency.
- Document an off switch, idempotency key, delivery tracing, user preference controls, and rollback.

Read `references/notification-decisions-and-experiments.md` for a policy template, architecture choices, and test matrix.

### 5. Prove incremental value

- Randomize at user level, maintain a persistent eligible no-message holdout, and log both treated and suppressed decisions.
- Optimize a **meaningful completed action** and D7/D30 retention, not just push CTR or app opens.
- Track harm: disables/unsubscribes, complaint rate, excessive sends, disengagement, and technical errors.
- Avoid selection bias: compare all users assigned to a group, not only recipients who opened a push.
- Set stop/rollback criteria and examine segmentation fairness before increasing volume.

### 6. Deliver and validate

For an **audit/design**, output: current evidence and unknowns; measurement verdict; minimum event contracts; baseline vs model choice; eligibility/notification policy; architecture mapped to the real stack; prioritized tasks; experiment design; privacy blockers; acceptance criteria.

For **implementation**, inspect code and integration boundaries first. Change only approved/specified scope; use existing scheduler, queue, auth, observability, and notification provider. Include complete files when supplying replacement source code. Validate at least: opt-out, delete account, timezones/DST, duplicate deliveries, worker retry, quiet hours, frequency cap, already-completed goal, cold start, holdout allocation, and failure fallback. Run relevant existing project tests; never claim tests passed without executing them.

## Hard gates

- **PRIVACY BLOCKED:** No verified lawful purpose/basis, missing channel preferences/OS permission, or undisclosed profiling/device tracking. Do not launch personalized sends until resolved.
- **MEASUREMENT BLOCKED:** No reliable user/action timestamps, population definition, or attributable outcomes. Instrument first.
- **DELIVERY BLOCKED:** No idempotency, opt-out enforcement, suppression, or rate limiting. Do not ship an automatic messaging worker.
- **NO BENEFIT:** No plausible user-value hypothesis, or randomized tests show negative outcomes. Disable the intervention rather than raise notification frequency.

## Evidence discipline and related skills

Read `references/source-fidelity-and-privacy.md` when discussing the reel, Duolingo, device signals, permissions, or GDPR. Distinguish **verified public evidence**, **reel observation**, and **proposed design**. Never represent decompiled on-screen fragments as authenticated Duolingo source or current app behavior.

Invoke `marketing-psychology` for deeper behavioral mechanics, `security-review` for personal data and notification infrastructure, and `feature-intake` / `implement` / `verify-ticket` for integration into the local engineering workflow where available. `retention-graph-audit` concerns video audience curves, not this kind of app retention.
