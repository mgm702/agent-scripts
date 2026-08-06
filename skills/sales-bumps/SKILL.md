---
name: Sales Bumps
description: Scan email threads for leads that have gone cold and draft short
  bump messages to nudge them — drafts only, never auto-send.
triggers:
  - sales bumps
  - cold leads
  - follow up with leads
  - who went quiet
  - bump email
---

# Sales Bumps

## When to Use
- Daily/weekly sales hygiene
- Pipeline feels stalled

## Process
1. Pull recent sent threads (Gmail MCP when available)
2. Cold = last message is yours AND no reply for >1 week (configurable)
3. Present the cold threads as a checklist — user selects which are actual
   sales leads worth bumping (AskUserQuestion / numbered list)
4. Rank selected leads by deal value, then recency
5. Draft one bump per selected lead

## Bump Style
- 2–4 sentences
- Reference the last concrete point discussed
- One clear ask (a question or a proposed time)
- No guilt-tripping, no fake "just checking in"

## Output
- Primary: create Gmail drafts via MCP (one draft per selected lead)
- Fallback (MCP unavailable/unauthenticated): one markdown file with all drafts

## Rules
- NEVER send — drafts only, user reviews and sends from Gmail
- Max 1 bump per lead per week
- 3+ bumps with no reply → flag as dead, stop bumping
- Skip threads marked personal/non-sales
