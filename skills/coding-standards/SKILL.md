---
name: Coding Standards
description: Core guardrails to read EVERY TIME before writing or editing code — four non-negotiable rules plus pointers to deeper design guidance.
triggers:
  - writing code
  - editing code
  - implement
  - add a feature
  - fix a bug
  - refactor
  - write a function
  - create a class
  - coding
---

# Coding Standards

Read this **every time coding happens** — before writing, editing, or refactoring any code.

## The Four Rules (most important)

1. **Don't make assumptions. Ask.**
2. **Don't over-engineer. Match the existing complexity.**
3. **Don't touch code you weren't asked to touch.**
4. **Don't invent libraries that don't exist.**

These override convenience. When in doubt about any of them, stop and ask.

## Applying Each Rule

- **Ask, don't assume** — unclear requirement, ambiguous naming, missing context → ask a short question with options. Never guess intent and build on the guess.
- **Match complexity** — read the surrounding code first. Mirror its patterns, abstraction level, naming, and structure. Don't add layers, config, or generality the codebase doesn't already have.
- **Stay in scope** — change only what the task requires. No drive-by refactors, reformatting, or "while I'm here" edits. Flag unrelated issues instead of fixing them silently.
- **Real libraries only** — verify a dependency exists in the manifest (package.json, Gemfile, go.mod, etc.) before importing it. Don't invent APIs, methods, or packages. Check the actual installed version's surface.

## Design Guidance

When the work involves classes, interfaces, or object structure, hook into the
[object-oriented-design-patterns](../object-oriented-design-patterns/SKILL.md) skill
for SOLID principles and the right pattern — but apply Rule 2 first: only reach for a
pattern the existing code's complexity justifies.

## Anti-Patterns

- Inventing requirements to avoid asking
- Adding abstraction "for the future" the code doesn't need
- Refactoring or reformatting files outside the task
- Importing a package or calling an API without confirming it exists
- Reaching for a design pattern when a plain function would do
