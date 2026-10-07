# Pricing Evidence, Experiments, and Rollout

Use this reference for price-point confidence, research design, experimentation, and migration.

## Evidence hierarchy

Prefer behavioral evidence over stated preference when available:
1. Actual purchases, renewals, expansions, churn, and negotiated discounts
2. Won/lost deal evidence and price-objection patterns
3. Paid pilots, deposits, preorders, or signed commitments
4. Structured interviews with concrete trade-offs
5. Conjoint / discrete-choice or other well-designed quantitative research
6. Van Westendorp or direct willingness-to-pay surveys
7. Generic market benchmarks
8. Internal intuition

Lower-ranked evidence can still be useful, but label it appropriately.

## Research prompts

Useful interview questions:
- What did you use before this product and what did that cost in money/time/risk?
- What changes economically when this problem is solved?
- Which capabilities are mandatory versus optional?
- What would make the product no longer worth paying for?
- Who owns the budget and what approval thresholds matter?
- Which pricing unit would feel easiest to forecast and control?

Avoid asking only "What would you pay?" without context or trade-offs.

## Price experiments

Use experiments only when they are operationally, legally, and reputationally acceptable.

Possible approaches:
- New-customer cohort tests
- Geographic or channel holdouts where segments are comparable
- Landing-page or offer tests before full billing implementation
- Sales quote bands with controlled approval rules
- Packaging tests that change limits/fences while monitoring adoption
- Sequential tests with pre-defined success/rollback criteria when randomization is impractical

Do not interpret noisy small samples as precise elasticity estimates.

## Discount design

A discount should buy something valuable for the seller, such as:
- Annual/prepaid term
- Multi-year commitment
- Volume commitment
- Lower service scope
- Standard contract terms
- Reference/case-study rights when appropriate

Define:
- List price
- Target price
- Approval threshold
- Absolute floor
- What exchange is required for each discount band

Do not adopt a universal annual-discount percentage without evidence from cash flow, churn, cost of capital, segment behavior, and competitive context.

## Migration decisions

Common options:
- Permanent grandfathering
- Time-limited grandfathering
- Renewal-only migration
- Gradual step-up
- Credit-based transition
- Forced migration at a defined date

Evaluate each against:
- Contractual rights
- Revenue impact
- Customer trust
- Support burden
- Product simplification
- Strategic need to remove legacy plans

## Rollback criteria

Set measurable triggers before launch. Examples:
- Conversion falls beyond the accepted range after controlling for mix
- Churn/downgrade rises materially in affected cohorts
- Discounting rises enough to erase the list-price gain
- Adoption of the priced metric collapses
- Support/escalation volume signals severe confusion
- Sales cycle length increases enough to damage new ARR

Prefer adjustment over full rollback when the model is sound but a tier fence, allowance, or price point is miscalibrated.
