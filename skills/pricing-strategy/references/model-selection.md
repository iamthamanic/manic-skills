# Pricing Model Selection

Use this reference when choosing between flat, seat-based, usage, tiered, transaction, outcome, or hybrid pricing.

## Decision sequence

1. **Does customer value scale with a measurable unit?**
   - Predictable unit such as active seats, locations, or stored contacts: consider per-unit pricing.
   - Variable/unpredictable consumption such as compute or API usage: consider usage pricing with commitments, included usage, caps, or predictable bands.
   - No useful scaling unit: continue to flat/tiered/platform-fee options.

2. **Do identifiable segments require materially different capabilities?**
   - If yes, use packaging/tiering around those needs. Strong fences are needs such as governance, compliance, scale, integrations, workflow complexity, or service level.
   - Weak fences are arbitrary conveniences that do not map to a distinct buyer context.

3. **Is value diffuse and hard to meter?**
   - Consider a flat platform fee or negotiated account fee, with a deliberate review mechanism for growing accounts.

4. **Does more product usage clearly create more monetizable customer value?**
   - If yes, usage or hybrid pricing may align incentives.
   - If usage is merely a means to the outcome, metering it can punish adoption.

5. **Does the business intermediate monetary transactions?**
   - A transaction/take-rate model may fit when the platform directly enables the transaction and the fee remains proportional to value.

6. **Can the outcome itself be defined and audited?**
   - Outcome-based pricing can work when causality, measurement, attribution, timing, and dispute handling are sufficiently clear.

## Common regrets

### Per seat
- Can punish internal adoption and collaboration.
- Encourages account sharing or limiting seats.
- Monitor activation, seats-to-eligible-users, and expansion friction.

### Usage based
- Makes customer bills and seller revenue less predictable.
- Product efficiency improvements can reduce revenue.
- Consider commitments, included usage, spend controls, and volume curves.

### Tiered
- Middle tiers can absorb nearly everyone if top-tier fences are weak.
- Too many feature gates create buying friction and mistrust.
- Fence on segment needs, not arbitrary feature scarcity.

### Flat fee
- Can underprice large/high-value customers for long periods.
- Needs a review mechanism, account segmentation, or explicit scale boundaries.

### Transaction / take rate
- Creates pressure to bypass the platform when fees feel detached from delivered value.
- Must account for payment costs, refunds, fraud, channel conflict, and high-ticket sensitivity.

### Outcome based
- Attractive in theory but vulnerable to attribution disputes and delayed realization.
- Requires precise outcome definitions, baselines, data access, and contractual dispute rules.

### Hybrid
- Often improves alignment but can become difficult to explain.
- Keep the number of charging dimensions minimal; every dimension must earn its complexity.

## Account simulation test

For the most recent or representative customers, compute what each would pay under every serious candidate model. Reject or redesign a model when it:
- disproportionately reduces revenue from best-fit customers,
- penalizes the fastest-growing customers,
- creates a large unexplained price shock,
- makes spend impossible to forecast,
- rewards customers the business does not want to optimize for.
