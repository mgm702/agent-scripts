---
name: DuckDuckGo Search
description: Web search and content extraction via DuckDuckGo Lite — use when current information, documentation, or external references are needed.
triggers:
  - search the web
  - look up
  - find online
  - web search
  - current pricing
  - latest docs
  - search for
---

# DuckDuckGo Search

Web search and content extraction via DuckDuckGo Lite. No API key needed.

## Setup

```bash
cd ~/code/projects/agent-scripts/skills/duckduckgo-search
bundle install
```

## Commands

Search the web:
```bash
ruby search.rb <query>              # 5 results (default)
ruby search.rb -n 3 <query>         # limit results
ruby search.rb --content <query>    # include page content as markdown
```

Extract content from a URL:
```bash
ruby content.rb <url>               # readable markdown output
```

## Output

- Search returns: title, URL, snippet per result
- With `--content`: appends extracted page content (truncated to 5000 chars)
- Content extractor: full readable markdown of the page

## When to Use

- Answering questions requiring current information
- Researching libraries, APIs, documentation
- Fetching and summarizing web page content
- Finding code examples or tutorials

## Notes

- Uses DuckDuckGo Lite (HTML-only endpoint); no API key or account required
- Content extraction uses Readability + ReverseMarkdown for clean output
- 15s timeout on all HTTP requests; follows up to 3 redirects
- Sponsored results are automatically filtered out
