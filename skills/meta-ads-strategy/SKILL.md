---
name: meta-ads-strategy
description: >-
  Plan, audit, troubleshoot, and improve Meta Ads campaigns across Facebook and Instagram, including objectives, conversion tracking, campaign and ad-set structure, Advantage+ versus manual controls, prospecting and retargeting audiences, budgets, placements, creative testing, performance diagnostics, and scaling. Use for Meta Ads, Facebook Ads, Instagram Ads, Ads Manager setup, Meta Pixel, Conversions API, Sales or Leads campaigns, custom audiences, lookalikes, retargeting, Advantage+ audience, campaign budgets, creative tests, CPA, ROAS, frequency, and campaign performance questions.
---
# Meta Ads Strategy

Give Meta-specific recommendations that fit the advertiser's economics and current signal volume. Do not blindly reproduce old Ads Manager tutorials because Meta changes controls and labels frequently.

## Routing

Load only the reference needed for the current task:

- tracking, Pixel, CAPI, conversion events -> `references/tracking.md`
- campaign objective, structure, audiences, placements, retargeting -> `references/campaign-structure.md`
- creatives, hooks, test design -> `references/creative-testing.md`
- performance problems, CPA/ROAS/frequency, scaling -> `references/diagnostics.md`

For a dedicated multi-stage retargeting design, use `retargeting-funnel` first, then apply Meta implementation rules from this skill.

## Operating principles

### 1. Start from the business outcome

Map optimization to the closest trustworthy business event.

Typical mapping:

- ecommerce/order completed -> Sales with purchase/value event where available,
- qualified inquiry or submitted lead -> Leads or Sales depending on the actual conversion path and account options,
- app install/event -> App promotion,
- reach or recall -> Awareness,
- clicks only -> Traffic only when a click is genuinely the outcome or conversion tracking is temporarily unavailable.

Do not optimize for cheap clicks when the advertiser needs purchases or qualified leads.

### 2. Treat tracking as a gate

Before structural advice, confirm the optimization event is real, deduplicated where browser/server signals overlap, and economically meaningful.

If purchase or lead tracking is broken, separate the tracking repair plan from media recommendations.

### 3. Prefer consolidation until data proves a split

Meta's delivery system generally benefits from sufficient signal per ad set. Avoid fragmenting by small demographic slices, placements, tiny retargeting windows, or many near-identical audiences unless there is a business or creative reason.

Use the platform's learning guidance as a directional signal, not a universal law. Current Meta documentation in some campaign products still references roughly 50 optimization events over seven days for exiting learning, but exact behavior varies by campaign type and account.

### 4. Distinguish audience suggestion from audience constraint

Meta increasingly uses Advantage+ systems that may treat selected audiences as suggestions and expand delivery. If the user's goal requires strict retargeting or a legally/business-constrained audience, inspect the current campaign controls and determine whether the selected audience is a hard constraint or an optimization signal.

Do not promise that a Custom Audience alone guarantees exclusive delivery without verifying the current setup.

### 5. Let creative do part of the targeting

Broad delivery works only when the ad clearly signals who the offer is for. Creative must communicate use case, problem, context, and offer fast enough for the right users to self-select.

### 6. Make economics explicit

Use:

- target CPA/CAC,
- gross margin or contribution margin,
- AOV/LTV where relevant,
- close rate for lead-gen,
- lead-to-sale lag,
- refund/cancellation rate where material.

A platform ROAS target that ignores margin is not a strategy.

## Standard workflow

1. Establish objective and business outcome.
2. Verify conversion tracking and attribution limits.
3. Inventory current campaign/ad-set structure and spend.
4. Determine prospecting versus retargeting roles.
5. Check audience controls and exclusions.
6. Evaluate budget against expected event volume.
7. Audit creative variety and message-stage fit.
8. Diagnose performance by funnel stage.
9. Recommend the minimum structural changes necessary.
10. Define measurement window and rollback/scale criteria.

## Required output for campaign setup

Return:

1. objective and optimization event,
2. campaign structure,
3. audience logic and exclusions,
4. budget approach,
5. placements approach,
6. creative matrix,
7. tracking prerequisites,
8. launch checks,
9. first evaluation window and decision rules,
10. assumptions and unknowns.

Use exact click-by-click UI instructions only when the current interface has been verified. Otherwise describe the control by function and note that Meta labels can differ by account rollout.

## Required output for audits

Classify findings as:

- BLOCKER: tracking, policy, or setup issue invalidates optimization/measurement,
- HIGH: likely large effect on CPA/CAC or lead quality,
- MEDIUM: meaningful efficiency or clarity improvement,
- LOW: cleanup or test candidate.

For every finding include evidence, likely mechanism, and concrete action. Do not recommend budget increases as the default fix for weak performance.
