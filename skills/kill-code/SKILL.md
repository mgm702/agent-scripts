---
name: Kill Code
description: Find and delete dead/unused code — unreferenced functions, unused
  deps, stale feature flags, commented-out blocks — with evidence before every deletion.
triggers:
  - kill code
  - dead code
  - unused code
  - clean up the codebase
  - delete old features
---

# Kill Code

## When to Use
- After a new feature replaces an old one
- Periodic hygiene on codebases >1 year old

## Targets
- Unreferenced functions, classes, modules, files
- Unused dependencies (Gemfile, package.json, go.mod)
- Stale feature flags (fully rolled out or abandoned)
- Commented-out code blocks
- Unreachable branches, dead constants
- Orphaned tests (testing deleted behavior)
- Dead assets, routes, and templates

## Process
1. Candidate sweep — grep/LSP references, coverage data if present, plus the
   per-language tool for the project (below)
2. Verify zero references, including dynamic call sites (Ruby `send`/`const_get`,
   metaprogramming, string-built routes, reflection)
3. Confirm not public API (gem/package exports, CLI commands, HTTP endpoints)
4. Delete in small batches; run full gate (lint + tests + typecheck) per batch

## Per-Language Tools
Detect language from the project; use the matching tool as the candidate sweep,
never as sole evidence (still verify references manually):
- **Go** — `staticcheck` (U1000 unused), `go mod tidy` for deps
- **Ruby** — `rubocop` (Lint/UselessAssignment, unused-arg cops), `bundle clean --dry-run`
- **JS/TS** — `knip` (unused files/exports/deps), `ts-prune` for exports
- **Python** — `vulture` for dead code, `pip-extra-reqs`/`deptry` for deps
- Tool missing → note it, fall back to grep/LSP sweep only

## Safety (per AGENTS.md)
- Evidence required for every deletion — show the zero-reference proof
- Small, reviewable commits; one concern per commit
- Stop + ask before committing (never auto-commit)
- Never delete config, migrations, or public API without explicit approval
- Unsure → keep it, flag it in the summary instead
