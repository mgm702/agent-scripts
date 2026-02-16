# Research First

Deep codebase/domain research before planning or coding.

## When to Use

- Unfamiliar codebase or module
- Complex feature spanning multiple systems
- Bug with unclear root cause
- New domain/integration (third-party API, protocol, etc.)

## Process

1. Read broadly — all relevant files, not just entry points
2. Trace data flow end-to-end (input → processing → output)
3. Identify conventions, patterns, and constraints already in place
4. Write findings to `${insert feature name}-research.md` in the working directory

## Research Artifact

Output a `${insert feature name}-research.md` covering:

- **Purpose** — what the system/module does
- **Architecture** — key files, data flow, dependencies
- **Conventions** — naming, patterns, error handling style
- **Constraints** — performance, compatibility, business rules
- **Gotchas** — edge cases, implicit assumptions, tech debt

## Prompting Style

- Use emphatic language: "deeply", "in detail", "all specificities"
- Demand written proof of understanding before moving on
- Ask for specifics: file paths, function names, data shapes

## Anti-Patterns

- Skimming top-level files only
- Jumping to plan/code without written research
- Assuming conventions from other projects apply here
- Generating a research doc without actually reading the code
