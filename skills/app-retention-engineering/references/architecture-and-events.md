# Retention Architecture and Event Contracts

Read when defining product analytics, cohort metrics, scoring, or integration architecture. These are portable contracts, not a mandate to create every table/service.

## Value-event contract

Define five separate concepts:

1. **Eligible population:** Who could benefit and be reached legitimately?
2. **Activation:** First successful meaningful product outcome.
3. **Return:** A meaningful product outcome in a later interval, not merely app launch.
4. **Intervention:** One specific, attributable user-facing action.
5. **Outcome:** The incremental action/retention change after exposure, plus guardrails.

Do not substitute a push-open or pageview metric for product success. For daily-use products, D1/D7/D30 can be useful; for irregular-use products prefer return within a relevant usage window, successful task recurrence, subscription renewal, or reactivation after demand returns.

## Minimal event envelope

Adapt to existing schemas. The conceptual contract is:

```text
Event {
  event_id: UUID or equivalent unique key,
  user_id: stable pseudonymous internal key,
  event_name: versioned controlled vocabulary,
  occurred_at: UTC timestamp from event source,
  received_at: UTC timestamp at ingestion,
  source: first_party_app | backend | delivery_provider,
  schema_version: integer,
  properties: minimal documented allowlist
}
```

Suggested domain events: `app_open`, `meaningful_action_completed`, `session_completed`, `workflow_failed`, `notification_preference_changed`, `notification_decision`, `notification_sent`, `notification_delivered`, `notification_opened`, `notification_deep_link_landed`. Do not infer delivery or user attention from an API request accepted by the provider. Deduplicate by source event ID and normalize app event sources without including device fingerprints.

Store per-user preferences separately from events:

```text
NotificationPreferences {
  user_id,
  channel: push | email | in_app,
  purpose: user_requested_reminder | product_update | marketing,
  permitted: boolean,
  changed_at,
  timezone,
  preferred_local_window: optional start/end,
  daily_cap: optional positive integer
}
```

A push token is sensitive contact data and must not be logged in analytics. Keep it in a tightly scoped delivery store. Consent/legal-basis status must reflect applicable law, actual purpose, and valid OS permissions. OS permission alone is not blanket GDPR consent.

## Snapshot and outcome definitions

- Use the user's stored IANA timezone for local calendar-day labeling, with explicit DST handling; avoid relying on server-local midnight.
- At scoring instant `t`, permit only features observed strictly before or at `t` and available by `t`.
- For `return_on_next_local_calendar_day`, label positive only if a meaningful event occurs in the next local calendar day; do not count future data as a feature.
- Train and evaluate using time-based splits plus a later holdout period; check exposure leakage from prior notifications.
- Store the score as `{user_id, as_of, horizon, probability, model_version, signal_quality}`, not a permanent immutable user trait.
- Do not reidentify deleted accounts. Define deletion/retention behavior for raw events, derived features, delivery state, and backups.

## Metrics and error checks

| Metric | Definition / caution |
| --- | --- |
| Activation rate | Activated eligible signups / eligible signups for a stated cohort window |
| D1 retention | Users in signup cohort with qualifying return on day 1 / users in cohort |
| D7 retention | Users in signup cohort with qualifying return on day 7 / users in cohort; not 7-day rolling retention |
| Rolling 7-day retention | Users with qualifying action during days 1-7 / users in cohort; different metric |
| Re-engagement | Dormant eligible users with a qualifying value action in stated window |
| Churn score | Predictive probability; requires validation and calibration, not an explanation of cause |
| Incremental lift | Difference in outcome rate between randomized treatment and eligible holdout |
| Notification open rate | Diagnostic only; neither causal lift nor user value |

Use cohort size, outcome window, event freshness, and confidence intervals where meaningful. Never advertise unsupported precision or assume a model must improve retention. For scoring metrics prefer proper scoring rules (for example, Brier score), calibration by segment, and temporal stability; review class imbalance and drift.

## Minimal architecture

```text
App/backend events -> validated, deduplicated event log -> cohort metrics
                                            |
                                      feature snapshot
                                            |
                            rules baseline -> optional score model
                                            |
Preferences/permissions -> eligibility gate -> experiment assignment
                                            |
                                   decision + dedupe log
                                            |
                                      delivery queue
                                            |
                                  existing push/email SDK
                                            |
           decision/sent/outcome events -> dashboards + holdout analysis
```

Reuse the existing DB, queue/scheduler, analytics pipeline, and provider where possible. Do not introduce separate ML infrastructure until an experiment shows incremental value. Preserve the distinction between a notification's eligibility, its assignment, send attempt, provider acceptance, actual delivery (if observable), and useful downstream action.

## Typical project slices

1. Product-value definition + instrumentation validation.
2. Dashboard for activation, cohort retention, and opt-outs.
3. Opt-in preference UI, server-side eligibility, quiet hours, and suppression tests.
4. Fixed reminder baseline plus holdout and event logging.
5. Contextual copy variants with deep links and frequency limits.
6. Only then: simple risk scoring, send-time tests, and optionally calibrated model-based decisioning.

Each slice needs acceptance criteria, privacy review, failure mode, measured outcome, and rollback. Stop expanding the system when no incremental benefit is evidenced.
