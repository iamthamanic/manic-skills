---
name: pricing-strategy
description: >-
  Design, audit, and revise pricing for SaaS, software, digital products, marketplaces, APIs, and productized services. Use when choosing a pricing model or value metric, designing tiers and packaging, evaluating freemium or trials, benchmarking competitors, setting or changing prices, planning grandfathering and rollout, or diagnosing weak conversion, ARPU, expansion, churn, or monetization. Produces evidence-backed recommendations, assumptions, tier architecture, price logic, migration plans, risks, and metrics.
---
# Pricing Strategy

Build pricing from customer value, segment differences, willingness-to-pay evidence, product economics, and buying friction. Treat pricing as a system: **model -> value metric -> packaging -> price points -> discounts -> migration -> measurement**.

## Operating rules

1. Separate **facts, assumptions, and recommendations**. Never present guessed willingness to pay, conversion benchmarks, competitor prices, or discount norms as facts.
2. When current competitor pricing matters and current web access is available, verify primary pricing pages and date the findings. Prefer official sources over aggregators. If current verification is unavailable, state that limitation.
3. Do not default to cost-plus pricing. Use costs as a floor/constraint; use customer value and alternatives to determine the viable range.
4. Do not force three tiers, freemium, per-seat pricing, or annual discounts. Choose them only when the product and segments justify them.
5. Prefer natural upgrade triggers that correspond to more value, scale, risk, governance, or collaboration. Avoid arbitrary feature withholding that damages the core job-to-be-done.
6. Quantify uncertainty. If evidence is weak, recommend research or a reversible test instead of fake precision.
7. For price changes, protect trust: define migration, grandfathering, communication, exceptions, rollback criteria, and measurement before launch.
8. When the user provides customer or deal data, test the proposed model against real accounts rather than relying only on abstract logic.

## Workflow

### 1. Frame the decision

Establish, from provided context or explicit assumptions:
- Product/service and business model
- Current pricing and packaging, if any
- Buyer, user, and economic buyer
- Priority customer segments
- Primary monetization problem: adoption, conversion, ARPU, expansion, churn, sales friction, margin, or market entry
- Constraints: gross margin, support/serving cost, contracts, procurement, channel economics, regulation, taxes, marketplace fees

Ask only for missing information that materially changes the decision. Otherwise proceed with labeled assumptions.

### 2. Map customer value

For each material segment, identify:
- Core job-to-be-done
- Outcome created: revenue gained, time saved, risk reduced, cost avoided, convenience, status, compliance, or access
- Magnitude and frequency of value
- Existing alternative and its total cost
- Adoption blockers and switching costs
- Evidence of willingness to pay: paid pilots, lost/won deals, price objections, historical upgrades, interviews, surveys, procurement behavior

Do not confuse product usage with value. A good value metric usually scales with value, but some usage metrics merely measure activity.

### 3. Choose the pricing model

Evaluate candidates such as:
- Flat subscription
- Per seat / active user
- Per account / location / workspace
- Usage-based
- Usage-based with commitment floor
- Transaction / take rate
- Outcome-based
- Tiered subscription
- Hybrid platform fee + usage/seat/transaction
- One-time license or productized-service fee

Score the candidates against:
- Correlation with customer value
- Predictability for buyer and seller
- Measurability and auditability
- Customer control over spend
- Ease of explaining and quoting
- Expansion behavior
- Incentives created by the metric
- Risk of suppressing adoption
- Revenue durability
- Implementation/billing complexity

For deeper model trade-offs, read `references/model-selection.md`.

### 4. Choose the value metric

Name the unit that should scale with customer value, such as active users, locations, contacts, transactions, compute, projects, assets, or managed revenue.

Reject a metric when it:
- grows without additional customer value,
- is difficult to forecast,
- causes customers to avoid healthy product usage,
- can be manipulated easily,
- has no clear expansion path,
- creates materially worse incentives than an alternative.

If no single metric works, consider a hybrid with one simple base charge and one scaling dimension.

### 5. Design packaging

Create packages around segment needs, not around an arbitrary number of features.

For each package define:
- Target segment / use case
- Included core outcome
- Limits or scaling dimension
- Governance/security/compliance needs
- Collaboration/integration needs
- Support/service level
- Natural upgrade trigger
- Why the package is sufficient for its intended segment

Use three tiers only when three distinct buying contexts exist. Otherwise use two, four, usage bands, or a custom enterprise layer.

### 6. Decide freemium, trial, or paid-first

Evaluate:
- Marginal cost of free usage
- Time-to-value
- Whether users can experience meaningful value before paying
- Viral/distribution effects
- Support burden
- Abuse/fraud risk
- Clear upgrade trigger
- Sales motion and procurement needs

Use freemium only when the free experience creates genuine value and supports distribution or qualification. Prefer a time-limited/full-feature trial when value can be demonstrated quickly but ongoing free usage has little strategic value. Prefer paid-first when setup, service, compliance, or marginal cost is high.

### 7. Establish price points

Build a defensible price range from several anchors:
- Customer value and ROI ceiling
- Cost and margin floor
- Replacement/alternative cost
- Competitive reference points
- Historical willingness-to-pay evidence
- Sales friction and procurement thresholds
- Segment economics

Do not infer exact price points from competitors alone. Competitor pricing defines context, not customer value.

When useful, present **low / base / high** scenarios and explain what evidence would justify moving between them.

### 8. Simulate the model

If account/deal data exists, calculate what recent or representative customers would have paid under the proposed model.

Check:
- Revenue by customer and segment
- Gross margin impact
- Winners/losers
- Expansion path
- Price shock for existing customers
- Whether best-fit/high-growth customers are penalized
- Whether undesirable segments become disproportionately attractive

A model that reduces monetization from the best-fit customers or suppresses their adoption needs redesign.

### 9. Position against the market

Classify the intended position only after evidence:
- **Premium:** higher price supported by differentiated value, trust, service, compliance, performance, or brand
- **Parity:** comparable price, differentiation elsewhere
- **Value:** lower price as an intentional acquisition or volume strategy with viable unit economics

Do not describe a product as premium merely because its price is higher.

### 10. Design the rollout

For new pricing define:
- New-customer launch date
- Existing-customer treatment
- Grandfathering or migration window
- Contract renewal handling
- Sales enablement and quote rules
- Communication rationale centered on value/packaging, not internal cost
- Support/escalation path
- Rollback or adjustment criteria

For detailed evidence, experiment, and rollout guidance, read `references/evidence-and-rollout.md`.

### 11. Define measurement

Choose primary metrics and counter-metrics before launch.

Typical primary metrics:
- Visitor/trial -> paid conversion
- ARPA/ARPU
- New ARR/MRR
- Expansion revenue / NRR
- Gross margin / contribution margin
- Sales cycle / close rate

Typical counter-metrics:
- Logo and revenue churn
- Downgrades
- Seat/usage suppression
- Support tickets and complaints
- Sales discounting
- Activation/adoption
- Payment failures
- CAC payback

Use segment/tier cohorts; averages can hide pricing damage.

## Competitive research protocol

When the user asks for competitor pricing or the recommendation depends on it:
1. Verify current official pricing/plan pages when possible.
2. Record currency, billing period, taxes if visible, minimums, included usage, overages, and enterprise/custom-price treatment.
3. Distinguish list price from effective price, negotiated price, promotional price, and annualized monthly display.
4. Date the observation.
5. Avoid invented feature parity. Compare the buyer outcome and packaging fence, not only plan names.

## Output format

Use the following structure unless the user requests another format:

### Pricing Strategy — [Product] — [Date]

**Decision:** [one-paragraph recommendation]

**Facts / evidence:**
- [verified facts]

**Assumptions:**
- [assumptions that materially affect the recommendation]

**Customer segments and value:**
| Segment | Core value | Buying trigger | WTP evidence | Main constraint |
|---|---|---|---|---|

**Recommended pricing model:** [model + rationale]

**Value metric:** [metric + why it correlates with value]

**Packaging:**
| Package | Target | Included outcome | Limit / fence | Upgrade trigger | Price or range |
|---|---|---|---|---|---|

**Competitive position:** [premium / parity / value / intentionally unclassified]

**Economics / scenario check:** [low/base/high or account simulation]

**Rollout:**
- New customers:
- Existing customers:
- Grandfathering/migration:
- Communication:
- Rollback/adjustment criteria:

**Risks and mitigations:**
| Risk | Leading signal | Mitigation |
|---|---|---|

**Metrics:** [primary metrics + counter-metrics]

**Confidence:** [high/medium/low] — [what evidence is missing]

## Quality gate

Before finalizing, verify:
- The buyer and priority segments are explicit.
- The recommended metric scales with customer value rather than raw activity alone.
- Package fences reflect real segment needs.
- Upgrade triggers are concrete.
- Current competitor prices are verified or clearly marked unverified.
- WTP claims have evidence or are labeled assumptions.
- Unit-economics constraints are acknowledged.
- Existing customers have a migration plan for pricing changes.
- Primary metrics and counter-metrics are defined.
- The recommendation includes uncertainty and a method to reduce it.

## Anti-patterns

Do not:
- Set price solely from development cost.
- Copy a competitor's tier structure without matching customer segments.
- Invent market benchmarks or current prices.
- Hide the product's core outcome behind a deliberately crippled entry tier.
- Use per-seat pricing when collaboration/adoption is the primary value loop without testing the adoption penalty.
- Use pure usage pricing when spend is too unpredictable for buyers without evaluating commitments or caps.
- Offer unlimited plans without modeling extreme users.
- Make enterprise "contact sales" the entire pricing strategy; define internal floors, target economics, and qualification rules.
- Treat discounting as harmless. Define discount authority, floors, and what customers exchange for the discount (term, volume, prepayment, scope).
- Randomize materially different prices across equivalent customers without considering fairness, contract, compliance, channel, or trust implications.
