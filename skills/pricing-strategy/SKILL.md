---
name: Pricing Strategy
description: Select a pricing model, design tier structure, and produce a pricing recommendation doc covering SaaS, API, open-source, B2B, and bootstrapped products.
triggers:
  - pricing
  - monetization
  - pricing model
  - how to charge
  - pricing tiers
  - what should I charge
  - revenue model
---

# Pricing Strategy

Select the right pricing model, design tier structure, and produce a written pricing recommendation.

## When to Use

- Deciding how to monetize a new product or feature
- Auditing whether current pricing is working
- Competitive repositioning (price increase, new tier, bundling)
- Choosing between free, freemium, trial, or paid-only entry

## Frameworks

### Value-Based
Charge what the outcome is worth to the buyer, not what it costs to build. Requires knowing the customer's next-best alternative and the delta your product creates.

### Cost-Plus
Floor: COGS + margin. Use as a sanity check, never as the ceiling. If value-based price > cost-plus floor, capture the spread.

### Competitive
Anchor to the market rate then justify deviation with differentiation. Price above: better outcomes. Price below: volume play or land-and-expand.

### Usage-Based
Meter by the unit that correlates with value (API calls, seats, records, compute). Lowers entry barrier; revenue scales with customer success.

### Freemium
Free tier is a marketing channel, not a product. Only works when: (1) free users have viral distribution value, or (2) conversion rate × LTV covers the cost of free users. If neither is true, use a time-limited trial instead.

## Model Selector

Work through this decision tree top-to-bottom:

1. **Who is the buyer?**
   - Individual / prosumer → self-serve, low friction, clear monthly price
   - SMB → self-serve ok, need annual option, some human touch at close
   - Enterprise → sales-led, custom contracts, procurement cycles; price anchors high

2. **What scales with value for the customer?**
   - Seats / users → per-seat pricing
   - Volume / throughput → usage-based
   - Business outcomes (revenue, saved hours) → flat tiers or value-based
   - Hard to measure → flat tiers with feature gates

3. **What is the competitive entry point?**
   - Category is new → education first, price second; freemium or trial acceptable
   - Category is crowded → don't compete on price; compete on packaging
   - Replacing a spreadsheet / manual process → anchor to cost of the old way

4. **What is the growth motion?**
   - Product-led growth → usage-based + free tier; viral within org
   - Sales-led → high entry price, land-and-expand on seats/usage
   - Community-led (OSS) → open-core; free core, paid enterprise features

## Tier Design

- **Three tiers max** for self-serve: Starter / Pro / Business (or free / paid / enterprise)
- **Middle tier is the target** — design it first, then build up and down from it
- **Anchor effect** — the highest tier makes the middle look reasonable
- **Decoy pricing** — make the low tier meaningfully worse so the upgrade is obvious
- **Feature gates, not usage gates** for the low tier: usage limits frustrate; feature limits teach what's missing
- **Annual discount** — 15–20% off for annual; positions monthly as a premium
- **Enterprise** — never show a price; "contact us" is the filter

## Metrics to Track

| Metric | What it tells you |
|---|---|
| LTV (Lifetime Value) | How much a customer is worth over their lifetime |
| CAC (Customer Acquisition Cost) | What it costs to acquire one customer |
| LTV:CAC ratio | Healthy = 3:1 or better |
| Payback period | Months to recoup CAC from gross margin |
| Expansion MRR | Revenue growth from existing customers (upsell/cross-sell) |
| Churn by tier | Which tiers retain vs. churn; signals mis-priced tiers |
| Free-to-paid conversion | Freemium health metric; benchmark: 2–5% |

## Model-Specific Playbooks

### SaaS / Subscription
- Lead with annual pricing; show monthly as "billed monthly at $X"
- Seat-based: charge per active seat, not total seats (reduces churn objection)
- Usage-based hybrid: flat base + overage; predictable floor, scales with success

### API / Consumption
- Free tier = enough to build and demo, not enough to run in production
- Pricing page must show a worked example: "10,000 requests/month = $Y"
- Bundle tiers for predictability; pure pay-as-you-go causes billing anxiety

### Open-Source / Developer Tools
- Open-core: free CLI/library, paid dashboard/teams/SSO/audit log
- Sponsorware: feature ships to sponsors first, then goes public after N sponsors
- Support contracts: enterprise SLA + priority triage; price at 20–30% of license value

### Enterprise / B2B
- Start high; you can discount but can't raise
- Land with one team, expand by department
- Procurement needs: MSA, DPA, SOC 2, SSO — price these in or they kill deals
- Annual contracts only; monthly is a red flag to procurement

### Minimalist / Bootstrapped
- Charge on day one — free tiers delay learning what people will pay
- Raise prices before you think you're ready
- One tier is fine to start; complexity comes later
- Lifestyle math: target MRR ÷ conversion rate = traffic needed; work backwards

## Common Mistakes

- **Free tier with no upgrade trigger** — users park in free forever; add a value wall
- **Feature-stuffing the middle tier** — makes the top tier look pointless; hold back power features
- **Discounting culture** — 30% off coupons train customers to wait; deprecates your price
- **Underpricing to compete** — attracts the worst customers; raises churn, kills margins
- **Pricing by cost** — your costs are irrelevant to the buyer; price by value
- **No annual option** — leaves ARR on the table and increases churn exposure
- **Too many tiers** — cognitive overload → no decision; three is almost always enough

## Output

Produce a `project-pricing.md` in the working directory with:

```
# Pricing Recommendation: <Project Name>

## Recommended Model
<model name and one-sentence rationale>

## Tier Structure
| Tier | Price | Key Features | Target Customer |
|---|---|---|---|

## Rationale
- Why this model over alternatives
- Key assumptions about buyer, volume, and value

## Metrics Baseline
- Target LTV:CAC ratio
- Expected free-to-paid conversion (if freemium)
- Payback period target

## Open Questions
- What to validate before locking in pricing
- Experiments to run (A/B test anchors, annual vs. monthly mix, etc.)
```
