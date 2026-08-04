---
name: Validate Idea
description: Validate a business idea before building anything — automated market research with evidence-graded scoring, then the minimalist entrepreneur principle that validation happens through selling, not building.
triggers:
  - validate my idea
  - is this worth building
  - should I build this
  - test my business idea
  - will anyone pay for this
  - is there a market for
  - research the market for
---

# Validate Idea

Test whether an idea is worth pursuing before writing code or spending money. Runs in two phases:

1. **Automated market research** — sweep public sources for evidence, score six dimensions, cite everything.
2. **Sell-first validation** — **validation happens through selling, not building.** Sell a manual version before automating anything.

Phase 1 tells you whether the market exists. Phase 2 tells you whether *you* can sell into it. Neither replaces the other.

## When to Use

- Someone has a business idea and wants a go/no-go before building
- Deciding whether to commit time or money to a concept
- Pressure-testing demand that so far rests only on "people think it's cool"

## Phase 1 — Automated Market Research

Use the [duckduckgo-search](../duckduckgo-search/SKILL.md) skill (`search.rb` / `content.rb`) to sweep these sources. Derive search phrases from the *problem*, not the product name — search how frustrated users talk, not how founders pitch.

### Sources

| Source | How |
|---|---|
| Reddit | `ruby search.rb "site:reddit.com <problem phrases>"`; `content.rb` on promising threads |
| Community forums / HN | `curl "https://hn.algolia.com/api/v1/search?query=<terms>"` |
| Product Hunt | `ruby search.rb "site:producthunt.com <category>"` |
| Competitor pricing | Search for competitors, then `content.rb <pricing page URL>` |
| App Store reviews | `ruby search.rb "site:apps.apple.com <category>"` (also play.google.com) — few reviews render; often lands on INSUFFICIENT DATA |
| Google Trends | Not scrapeable with this stack — always INSUFFICIENT DATA; instruct a manual check at trends.google.com |

### Evidence Rules (non-negotiable)

- Every rating above LOW requires **2+ cited sources** — quote or paraphrase plus URL.
- Can't find evidence → the rating is **INSUFFICIENT DATA**, never a confident guess.
- Never infer demand from an absence of competitors — no competitors usually means no market.
- An empty search result is a finding; report it as such.

### Scorecard

Rate each dimension **HIGH / MEDIUM / LOW / INSUFFICIENT DATA**, with evidence cited inline:

1. **Problem evidence** — unprompted complaints about this pain in the wild
2. **Market demand** — search interest, thread volume, engagement trends
3. **Competitive landscape** — who exists, what gaps they leave
4. **Willingness to pay** — people already paying for solutions; observed price points
5. **Distribution** — identifiable channels where these customers gather
6. **Timing** — why now; what changed to make this newly viable

Summarize as **STRONG SIGNAL / MIXED SIGNAL / WEAK SIGNAL**, then list every INSUFFICIENT DATA gap with a concrete manual verification step.

## Phase 2 — Sell-First Validation

### 1. Define the problem, not the solution
- Who *specifically* has this problem? (Not "businesses" — "freelance designers who hate invoicing.")
- How are they solving it today? The current workaround is the real competition (cross-check against the Phase 1 competitive landscape).
- How painful is it — mild annoyance or hair-on-fire?
- Would they pay to make it go away?

### 2. Can you solve it manually first?
- "Processize" it — do it by hand for a few people before automating anything.
- If you can solve it manually for a few customers, you can eventually automate it.
- (Gumroad began with Sahil collecting PayPal info and paying creators one by one.)

### 3. Will people pay?
- The ultimate validation is a transaction.
- Have you talked to 10+ potential customers? Have 3+ said they'd pay (or actually paid)?
- What price point feels natural to them? (Anchor against Phase 1 competitor pricing.)

### 4. The four pre-build questions
1. Can I ship the first version in a weekend?
2. Does it make customers' lives a little better?
3. Is a customer willing to pay for it? (Profitable from day one.)
4. Can I get feedback quickly?

## Green Flags

- People already pay for inferior solutions
- You've manually solved this for a few people and they loved it
- The community is actively complaining about this problem
- You can describe the customer and pain in one sentence
- You're scratching your own itch

## Red Flags

- Nobody is currently trying to solve this (no existing workarounds)
- You can't name 10 specific people with this problem
- The only validation is "my friends think it's cool"
- You'd have to educate people that they even have the problem
- You're building for a community you don't belong to

## Output

Deliver one report:

1. **Scorecard** — six dimensions with ratings and cited evidence, overall signal, and INSUFFICIENT DATA gaps with manual next steps.
2. **Verdict**:
   - **Validated** — strong signals, proceed to MVP (hand off to the `mvp` skill)
   - **Needs more validation** — specific next steps to gather evidence (including the manual checks from Phase 1)
   - **Pivot** — the idea needs fundamental changes; suggest directions
