---
name: Product Launch
description: Launch-day distribution checklist — coordinate posts across Product
  Hunt, HN, Reddit, social, and existing audiences to maximize a launch moment.
triggers:
  - launch checklist
  - launch my product
  - product hunt launch
  - launch plan
  - announce this
---

# Product Launch

## Prereq
Run `release-manager` first — don't launch what isn't production-ready.

## Channels (adapt per product)
- [ ] Product Hunt — schedule 12:01am PT, first comment ready
- [ ] Hacker News — Show HN, plain-spoken title
- [ ] Indie Hackers — post + product page
- [ ] Reddit — 2–3 relevant subs (r/Entrepreneur, r/SideProjects, niche subs);
      follow each sub's self-promo rules
- [ ] Twitter/X — 1 launch post + 2 follow-up angle posts spread over the day
- [ ] LinkedIn post
- [ ] Email — waitlist first, then users of your other products
- [ ] Facebook groups / Telegram / Discord communities you already belong to

## Rules
- Native copy per channel — never cross-post identical text
- Prep all copy the day before; launch day is for replying, not writing
- Track signups per channel (UTM links); best channel feeds the next launch

## Output
- `launch-plan.md` — per-channel copy drafts + timing table

## Notion Sync
Same pattern as `release-manager`:
- On creation: `notion_create_page` under the parent from MEMORY.md (`## Notion`),
  title `Launch: <Product Name>`, store `notion_page_id`/`notion_page_url` as
  front matter in the local file
- On updates: delete + re-create the Notion page, refresh front matter
- Notion MCP unavailable → skip silently; local file is source of truth
