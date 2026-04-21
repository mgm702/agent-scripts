# AGENTS.MD

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Core Protocol

- Workspace: ~/code
- Files: repo root or ~/code/projects/agent-scripts
- "Make a note" -> edit AGENTS.md
- Use trash for deletes
- Keep files <~500 LOC; split when bigger
- Commits: Conventional Commits (feat|fix|refactor|build|ci|chore|docs|style|perf|test)
- Editor: e <path>
- Prefer small, reviewable changes
- Style: telegraph. Min tokens everywhere.

## Git Safety

- Safe by default: git status/diff/log first
- Push only when user asks
- Destructive ops forbidden unless explicit (reset --hard, clean, rm, restore...)
- Never delete/rename unexpected files; stop + ask
- Multi-agent: always check git status/diff before editing
- Small commits only
- Straight to the point, small commit messages
- no sub commit messages, only the top level commit
- NEVER CO AUTHOR A COMMIT
- never create a git commit; stop + ask before proceeding

## Docs & Process

- Open relevant docs before coding
- Update docs when behavior changes
- Before handoff: run full gate (lint + tests + typecheck)
- CI red -> fix until green

## Critical Thinking

- Fix root cause, not symptoms
- Unsure -> read more code first, then ask with short options
- Conflicts -> call out and pick safer path
- Leave breadcrumb notes in thread

## Tools

- gh (for GitHub operations)

## Code Style

- No comments unless explicitly asked
- Never remove existing comments or code w/o reason
- Strict indentation per language standards

## Ruby

- Always rubocop compliant
- Empty line after every guard clause

## JavaScript / TypeScript

- Always eslint compliant
- Use `skills/react-performance` for UI audits

## Quality Rules

- Error handling: cover failure cases gracefully
- Edge cases: nil/null, empty collections, boundaries, bad input
- Performance: avoid N+1, redundant loops, unnecessary allocations
- Always follow language + framework idioms
