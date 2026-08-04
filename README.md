# agent-scripts

Centralized AI agent instructions and domain-specific skills. Source of truth for coding workspace at `~/code/`.

## Structure

```
agent-scripts/
├── AGENTS.md              # Core protocol: git safety, code style, quality rules
├── setup/
│   └── notion-mcp.rb      # One-time Notion MCP setup for Claude Code
└── skills/
    ├── ai-cost-comparision/    # LLM provider cost comparison & model selection
    ├── code-review-and-quality/ # Multi-axis review of local changes before push
    ├── coding-standards/       # Core guardrails to read every time before coding
    ├── create-cli/             # CLI tool scaffolding patterns
    ├── devops-agent/           # AWS infra assessment & phased launch plan
    ├── duckduckgo-search/      # Web search & content extraction via DDG Lite
    ├── find-community/         # Find a community to build a business around
    ├── github/                 # gh CLI workflows & automation
    ├── idea-refine/            # Sharpen a raw idea into a one-pager for planning
    ├── implementation-control/ # Controlled execution & progress feedback
    ├── marketing-plan/         # Minimalist content-first marketing plan
    ├── mobile-developer/       # React Native, step-by-step with explanations
    ├── mvp/                    # Build the smallest viable product, manual-first
    ├── object-oriented-design-patterns/ # SOLID + GoF patterns reference
    ├── performance-optimization/ # Measure-first performance audit & fixes
    ├── plan-and-annotate/      # Structured planning before implementation
    ├── pricing-strategy/       # Pricing model, tier design & recommendation doc
    ├── release-manager/        # Pre-release audit & checklist generation
    ├── research-first/         # Deep codebase/domain research before coding
    └── validate-idea/          # Market research + validate by selling before building
```

## Setup

### New machine

Run these after cloning the repo:

```bash
# Link skills into Claude Code
ruby ~/code/projects/agent-scripts/setup/symlink-skills.rb

# Install hooks into settings.json (coding-standards guardrails on every edit)
ruby ~/code/projects/agent-scripts/setup/install-hooks.rb

# Configure Notion MCP (requires a Notion integration token)
ruby ~/code/projects/agent-scripts/setup/notion-mcp.rb
```

All three respect `CLAUDE_CONFIG_DIR` (default `~/.claude`) and are idempotent —
re-run any of them safely. `install-hooks.rb` merges into `settings.json` without
touching existing hooks, MCP servers, or plugins.

## Usage

### Reference from other projects

Symlink AGENTS.md into your project root:

```bash
ln -s ~/code/projects/agent-scripts/AGENTS.md ~/code/my-project/AGENTS.md
```

Or point agents to this repo directly in your project's config.

### Reference a skill

Point agents to a specific skill when needed:

```
See ~/code/projects/agent-scripts/skills/react-performance/SKILL.md
```

## Skills

| Skill | Purpose |
|-------|---------|
| `ai-cost-comparision` | Compare LLM provider pricing and select a model to minimize spend |
| `code-review-and-quality` | Multi-axis review (correctness, readability, architecture, security, perf) of local changes before pushing |
| `coding-standards` | Core guardrails (the four rules) to read every time before writing or editing code |
| `create-cli` | Design & scaffold CLI tools with proper flags, output, and testing |
| `devops-agent` | Assess AWS infra and produce a phased production-readiness launch plan |
| `duckduckgo-search` | Web search & content extraction via DuckDuckGo Lite (no API key) |
| `find-community` | Identify and evaluate communities to build a minimalist business around |
| `github` | `gh` CLI workflows: issues, PRs, CI checks, releases |
| `idea-refine` | Refine a raw idea into a sharp one-pager, then hand off to `plan-and-annotate` |
| `implementation-control` | Controlled execution, quality gates, and supervisor-style feedback |
| `marketing-plan` | Content-first marketing plan that builds an audience before spending on ads |
| `mobile-developer` | React Native development, step-by-step with explanations |
| `mvp` | Build the smallest viable product — manual, then processized, then productized |
| `object-oriented-design-patterns` | SOLID principles and GoF patterns — when to reach for each, and when not to |
| `performance-optimization` | Measure-first audit & fixes across Go, Ruby, React, RN, Python, C |
| `plan-and-annotate` | Structured plan docs with iterative annotation before implementation |
| `pricing-strategy` | Select a pricing model, design tiers, and produce a recommendation doc |
| `release-manager` | Pre-release audit and go-live checklist generation |
| `research-first` | Deep codebase/domain research with written findings before planning/coding |
| `validate-idea` | Automated market research with evidence-graded scoring, then validate by selling, not building |

## Adding Skills

Create `skills/<name>/SKILL.md`. Pure markdown, telegraph style, ~30-50 lines. Sections: Purpose, Rules/Patterns, Requirements.
