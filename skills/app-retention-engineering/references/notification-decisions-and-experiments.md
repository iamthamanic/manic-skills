# Notification Decision Policy and Experiments

Use when designing actual automated reminders, lifecycle orchestration, message variants, or A/B tests. Prefer product value over engagement manipulation.

## Decision record

Persist a decision for every evaluated eligible user, including suppressed or held-out users:

```text
NotificationDecision {
  decision_id,
  user_id,
  decided_at,
  campaign_or_goal_id,
  policy_version,
  experiment_id: nullable,
  variant: holdout | control | treatment,
  decision: send | suppress,
  suppression_reason: nullable,
  channel: nullable,
  template_id: nullable,
  intended_send_at: nullable,
  idempotency_key
}
```

Decision storage and experiment allocation should not contain raw device identifiers. For a retryable send, use a unique key such as `(user_id, campaign_or_goal_id, local_date, channel, policy_version)` and persist before contacting the delivery provider. Verify semantics against actual product cadence; do not deduplicate legitimately distinct customer-requested messages.

## Eligibility decision order

1. Account exists, active, not deleted, and is not an internal/test user.
2. Requested purpose is valid; correct legal basis and communication preferences allow this channel, and OS permissions (where applicable) allow delivery.
3. User has not already completed the specific goal and is not in an incompatible lifecycle state.
4. User is not in quiet hours or a prohibited time window; timezone available or conservative fallback used.
5. Daily/weekly cap and minimum cooldown satisfied. User-level caps apply across overlapping campaigns.
6. Recent identical message not sent; no live duplicate/idempotency conflict.
7. User has a meaningful next action available through a valid deep link.
8. Stable experiment assignment says whether to suppress, send baseline, or use personalized content.
9. Select template and timing from permitted signals; log the decision and enqueue once.

Enforce steps 1-7 again immediately before delivery, not only when scheduled. A preference or goal can change between queueing and sending. If preference lookup fails, fail closed. Use platform-level cancellation when possible for queued reminders after a user opts out.

## Message relevance hierarchy

Prefer, in this order:

- User-selected action/time: "Your daily review is scheduled for 18:00."
- Unfinished meaningful goal: "You have one saved task ready to finish."
- Transparent progress: "Two lessons completed this week."
- Optional community relevance: real friend progress or a genuine leaderboard movement.

Do not invent friend activity, simulate a personal relationship, expose private data in push previews, rely on shame/fear, or claim personalized urgency without evidence. Implement user-configurable pause, frequency and notification purposes. Avoid a dark pattern where a notification permission denial leads to repeated prompts.

## Experiment contract

**Hypothesis:** For a defined population, one reminder about an unfinished valuable action increases qualifying completion within a predeclared period without materially increasing opt-outs.

- **Unit:** persistent user-level random assignment (not per send or open).
- **Arms:** no-reminder holdout vs existing baseline; then baseline vs personalized, without conflating both comparisons.
- **Primary:** meaningful action completion in the measurement window.
- **Secondary:** D7/D30 retention and sustained usage cadence.
- **Guardrails:** opt-out/unsubscribe, negative feedback, excessive sends, crashes, delivery failures, complaints, time spent without value.
- **Analysis:** intention-to-treat (every assigned eligible user); disclose exclusions, sample sizes and uncertainty; inspect novelty and heterogeneity.
- **Stopping:** predefine minimum duration/evidence and safety thresholds; avoid repeated significance peeking, post-hoc subgroup claims, and cherry-picking opened notifications.
- **Rollout:** small exposure -> monitored ramp -> broad rollout only on demonstrated benefit; kill switch always available.

A predicted probability of return is **not** an estimate of the causal value of sending a notification. A high-risk cohort can have low persuadability; consider uplift/counterfactual modeling only when randomized data support it.

## Acceptance test matrix

| Test | Expected behavior |
| --- | --- |
| Notification permission off | No push; in-app alternatives only if independently valid |
| App goal already completed | Suppress goal reminder |
| User opted out while queued | Recheck permission and cancel/suppress |
| Two workers same decision | At most one accepted send attempt per dedupe key |
| Provider times out after acceptance | Retry strategy avoids duplicate send or records uncertain status |
| Timezone changes and DST shift | Reschedule against actual IANA local time; honor quiet hours |
| Model missing/stale | Explicit baseline fallback; no uncontrolled sends |
| User deleted | Suppress and execute data deletion policy |
| Experiment holdout | No intervention; include in outcome analysis |
| Same user eligible for multiple campaigns | User-wide frequency cap and priority rule enforce one clear action |
| Crash/error state | Avoid broken deep links and known failing flows |
| Delivery rate spike | Alert, circuit breaker, and reversible rollback |

## Reporting template

```markdown
## App Retention System
- Mode and stack:
- Primary user value and repeat-use cadence:
- Baseline metric and evidence quality:
- Measurement verdict: READY | MEASUREMENT BLOCKED
- Privacy verdict: READY | PRIVACY BLOCKED
- Delivery verdict: READY | DELIVERY BLOCKED

### Minimum implementation
- Event contracts and existing source of truth:
- State / scoring approach:
- Eligibility policy, suppression and dedupe:
- Notification content, timing and deep links:
- Changes, owners and rollout order:

### Proof
- Acceptance tests with real results:
- Experiment design, holdout and success/stop criteria:
- Trade-offs and unresolved assumptions:
```
