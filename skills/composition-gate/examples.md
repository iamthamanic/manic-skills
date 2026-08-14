# Composition Gate — examples

These illustrate **tags**, not a domain checklist. Do not only hunt for Slack fan-out.

## 1. Cardinality — one announcement, N channel posts

**Event:** HR publishes one announcement to 100 members.

**Hops:** `announcements.service` (1 notification per `targetUserId`) → `notifications.service` `createBulk` (1 outbox row per notification) → worker (`ANNOUNCEMENT` → channel post).

Each file is locally plausible (1:1 notification, 1:1 enqueue, 1:1 send). Composed: **100 identical channel messages**.

| Simulation | Intended | Composed | Tag |
|------------|----------|----------|-----|
| 1 event, 100 actors | 1 channel post | 100 posts | `cardinality:` |

**Fix:** Enqueue one channel job per announcement (not per recipient), or send DMs per user — match acceptance. Tests must use **N > 1** recipients.

## 2. Override + silent-fallback — policy escape

**Event:** LEAVE notification (private HR).

**Hops:** API accepts `metadata.channel` → enqueue stores any valid channel → worker posts to that channel. Tests assert `LEAVE + #hr-news → channel`.

PR text said “other types → DM”. Composed: a generic override publishes private data. Invalid channel is dropped to `null` → announcement worker uses org default (wrong channel, no error).

| Simulation | Intended | Composed | Tag |
|------------|----------|----------|-----|
| LEAVE + channel | DM | channel post | `override:` `test-lock:` |
| ANNOUNCEMENT + bad channel | reject or stay | org default | `silent-fallback:` |

**Fix:** Channel override only for allowed types; invalid override fails closed; do not lock the leak in tests.

## 3. Other domains (same tags)

| Domain | Composed failure | Tags |
|--------|------------------|------|
| Checkout | 1 order × N line items → N payment captures | `cardinality:` `identity:` |
| Import | Row written `pending`; job reads only `ready`; crash leaves rows stuck | `stuck-state:` |
| i18n | Unknown locale silently falls back to another **market** | `silent-fallback:` |
| Webhook | No `eventId`; provider retries → duplicate provision | `identity:` `race:` |
| Feature flag | UI shows “Connected” while worker flag is off | `label-lie:` |
| Routing | Tests cover `resolveDelivery`; worker copies regex and ignores it | `dead-path:` `divergent-copy:` |

## What local review misses

If you can describe the bug **inside one file**, `@review-ticket` / P-06 heuristics may catch it. This gate exists for bugs that **need two or more hops** to exist.
