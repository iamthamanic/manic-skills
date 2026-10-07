# Meta tracking

## Readiness checklist

Confirm the following before optimizing to a website conversion:

- Pixel or dataset is connected to the correct business/ad account.
- The intended conversion event fires on the actual success condition.
- Browser and server events are deduplicated when both represent the same conversion.
- Event timestamps, currency, value, and IDs are coherent where applicable.
- Test events do not contaminate production reporting.
- Domain/URL changes and redirects do not break event logic.
- CRM or order-system totals can be reconciled against platform-attributed totals.

## Evidence standard

Do not infer tracking health from Ads Manager showing some conversions. A tracking audit needs event-level evidence or a credible first-party reconciliation.

## Conversion priority

Optimize to the deepest event that is both trustworthy and frequent enough to learn from. If purchase volume is extremely sparse, state the tradeoff before moving to a shallower event.

## Source note

Meta documentation changes frequently. For current implementation details, verify against Meta Business/Developer documentation and the account's Events Manager UI.
