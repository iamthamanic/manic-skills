---
name: retargeting-funnel
description: >-
  Design, audit, and simplify paid-media retargeting funnels using intent depth, recency windows, exclusions, budget constraints, message sequencing, and frequency control. Use when the user asks about retargeting, remarketing, website visitor audiences, cart or checkout abandoners, engaged social audiences, customer exclusions, warm/hot audience structure, recency segmentation, retargeting budgets, frequency, creative sequencing, or whether a retargeting campaign is over-fragmented. Works across paid social platforms and should hand Meta-specific implementation details to meta-ads-strategy when Meta/Facebook/Instagram is the platform.
---
# Retargeting Funnel

Build the smallest retargeting system that preserves meaningful intent differences and can still gather enough signal to optimize.

## Core rule

Do not split audiences because a framework says to. Split only when the segment changes at least one of these:

1. user intent,
2. message or offer,
3. recency value,
4. exclusion logic,
5. economic value,
6. bidding or optimization requirement.

If none changes, consolidate.

## Workflow

### 1. Run the tracking gate

Before recommending campaign structure, establish whether the downstream conversion event is trustworthy.

Check:

- primary conversion event and business outcome,
- browser and server-side event sources if used,
- duplicate-event risk,
- value and currency consistency for purchase/value optimization,
- purchaser or qualified-lead suppression availability,
- attribution/reporting source used for final decisions.

If tracking is materially unreliable, label the plan `TRACKING BLOCKED` and separate tracking fixes from campaign recommendations.

### 2. Inventory available warm signals

Classify audiences by behavioral depth, not by arbitrary channel labels.

Use this default hierarchy and adapt it to the business:

| Tier | Typical signals | Intent |
| --- | --- | --- |
| T1 | checkout started, quote started, booking started, pricing flow abandoned | very high |
| T2 | product/service detail viewed, configurator used, key CTA clicked | high |
| T3 | multiple site visits, long session, high-value content, video completion | medium |
| T4 | social engagement, profile engagement, video views, broad site visit | low-medium |
| Suppression | purchase, closed-won, disqualified, refund/cancel if relevant | exclude or treat separately |

Never assume an event exists. Use the signals the advertiser can actually build.

### 3. Choose recency windows from buying-cycle logic

Use business urgency to determine windows.

Starting heuristics:

- urgent/local services: 1-7, 8-14, 15-30 days,
- considered consumer purchase: 1-14, 15-30, 31-90 days,
- long B2B cycles: 1-30, 31-90, 91-180 days where audience size supports it.

Treat these as starting points, not rules. Shorten windows when intent decays quickly. Extend only when the buying cycle supports it.

### 4. Decide whether to segment or consolidate

Prefer one consolidated retargeting ad set when:

- total warm audience is small,
- weekly optimization events are sparse,
- the same creative/message works across segments,
- separate ad sets would create substantial audience overlap,
- budget cannot fund each segment independently.

Split hot vs warm only when volume supports it and the message meaningfully changes.

A common two-stage structure is:

- HOT: deepest intent, shortest recency,
- WARM: broader site/social engagement, longer recency.

Do not create many 1-3 / 4-7 / 8-14 / 15-30 day ad sets unless there is enough audience and budget to justify distinct treatment.

### 5. Define exclusions before budgets

Build explicit exclusions so stages do not bid against each other.

Default logic:

- exclude converters from acquisition retargeting,
- exclude HOT from WARM when stages are separate,
- exclude existing customers when the offer is new-customer-only,
- do not suppress customers when cross-sell, repeat purchase, or renewal is the actual objective,
- document consent and data-source constraints for customer-list audiences.

### 6. Map message to stage

Use a message ladder rather than showing the same prospecting ad again.

| Stage | Message role | Typical angle |
| --- | --- | --- |
| HOT | remove final friction | reminder, objection handling, trust, deadline, process clarity |
| WARM | strengthen preference | proof, problem/solution, differentiation, use case |
| LOW-WARM | rebuild intent | education, demonstration, social proof, category pain |

Do not invent urgency, scarcity, reviews, savings, or claims.

### 7. Set budget from audience capacity

Do not force spend into a small retargeting pool.

Evaluate:

- estimated reachable audience,
- expected conversion rate,
- acceptable CPA/CAC,
- expected weekly conversion volume,
- frequency trend,
- creative rotation capacity.

If spend rises while reach stagnates and frequency climbs without incremental conversions, reduce budget, widen the eligible pool, or refresh the message rather than increasing bids blindly.

### 8. Define measurement and decision rules

Report at minimum:

- spend,
- reach,
- impressions,
- frequency,
- CPM,
- outbound/link CTR when relevant,
- landing-page views if available,
- conversions,
- CPA/CAC,
- conversion value and ROAS where economically valid,
- incremental or blended business outcome when available.

Do not treat platform-attributed ROAS as ground truth when CRM/checkout data disagrees. Flag attribution gaps.

## Required output

For a design request, return:

1. tracking readiness verdict,
2. audience map,
3. recommended recency windows,
4. exact include/exclude logic,
5. campaign/ad-set structure,
6. budget logic,
7. message/creative map,
8. measurement and kill/scale rules,
9. assumptions and missing data.

Prefer a compact table plus a short rationale.

## Meta handoff

When the platform is Meta/Facebook/Instagram, load or invoke `meta-ads-strategy` for current implementation details such as objective choice, Advantage+ behavior, audience controls, placements, optimization event, and Ads Manager structure.

## References

For evidence and platform-independent design notes, read `references/retargeting-principles.md`.
