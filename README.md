# agent-scripts

Centralized AI agent instructions and domain-specific skills. Source of truth for coding workspace at `~/code/`.

## Structure

```
agent-scripts/
├── AGENTS.md              # Core protocol: git safety, code style, quality rules
└── skills/
    ├── create-cli/          # CLI tool scaffolding patterns
    ├── duckduckgo-search/   # Web search & content extraction via DDG Lite
    ├── frontend-design/     # Production UI/UX & semantic HTML/CSS
    ├── github/              # gh CLI workflows & automation
    └── react-performance/   # React rendering audit & optimization
```

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
| `create-cli` | Design & scaffold CLI tools with proper flags, output, and testing |
| `duckduckgo-search` | Web search & content extraction via DuckDuckGo Lite (no API key) |
| `frontend-design` | Semantic HTML, accessible UI, Tailwind/CSS Modules, loading/error states |
| `github` | `gh` CLI workflows: issues, PRs, CI checks, releases |
| `react-performance` | Audit re-renders, memo/callback optimization, virtualization |

## Adding Skills

Create `skills/<name>/SKILL.md`. Pure markdown, telegraph style, ~30-50 lines. Sections: Purpose, Rules/Patterns, Requirements.
