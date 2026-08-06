---
name: Morning Metrics
description: Pull business + infrastructure metrics (Stripe, Mercury, AWS, Mixpanel,
  Sentry, Firecrawl, scraping backends) and build a single personalized HTML
  dashboard browsable in 30 seconds.
triggers:
  - morning metrics
  - business dashboard
  - how is the business doing
  - daily metrics
  - pull my numbers
  - morning ritual
---

# Morning Metrics

## When to Use
- Start of day, before roadmap/feature planning
- Before investor or status updates
- After a launch or deploy, to check impact

## Scope
Project-scoped: run from a project directory. Inspect the codebase first to
determine which sources apply (Stripe SDK/gem, Mixpanel instrumentation, Sentry
DSN, AWS infra, Firecrawl usage, scraper jobs) — then pull metrics for THAT
project only. No global all-business dashboard unless explicitly asked.

## Data Sources
Credentials come from env vars and authenticated CLIs (aws, stripe, etc.).
If a required source isn't connected, STOP and ask the user to connect it
(name the exact env var or CLI login command), then re-run. Don't skip silently.

- **Stripe** — MRR, new customers, churned customers, failed payments, disputes
- **Mercury** — account balances, recent large transactions, cash runway estimate
- **AWS** — month-to-date spend vs last month (Cost Explorer), budget alarms,
  service health for running workloads (ECS/EC2/Lambda errors, CloudWatch alarms)
- **Mixpanel** — DAU/WAU, key event counts, funnel conversion, retention deltas;
  derive key events from the tracking calls found in the project's code, confirm
  the list with the user on first run
- **Sentry** — new errors, error-rate deltas, regressions on recent releases
- **Firecrawl (self-hosted)** — instance up/healthy, crawl job success/failure
  counts, queue depth
- **Scraping (backend)** — scraper job runs since yesterday: success/failure
  rates, last successful run per scraper, stale-data warnings
- **Web analytics** — visitors, signups, conversion rate

## Output
- ONE self-contained HTML file (inline CSS/JS, no external deps)
- Location: `~/code/metrics/<project>-<YYYY-MM-DD>.html` (create dir if missing)
- Red/green flags section at the top — anything needing action today
- Each metric: yesterday vs 7-day vs 30-day delta
- Group: Money (Stripe, Mercury, AWS spend) → Product (Mixpanel, analytics) →
  Infra (Sentry, AWS health, Firecrawl, scrapers)
- Footer: sources not applicable to this project

## Rules
- Read-only — never mutate billing, banking, or analytics data
- Never embed API keys/tokens in the HTML output
- Mercury/banking data: local file only, never sync to Notion or external services
- If a source errors, show the error in the dashboard — don't fail the whole run
