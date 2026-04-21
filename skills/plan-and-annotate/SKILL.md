---
name: Plan and Annotate
description: Produce a structured plan document with iterative annotation cycles before any implementation begins.
triggers:
  - make a plan
  - plan this
  - create plan doc
  - plan before
  - plan and annotate
  - put together a plan
---

# Plan and Annotate

Structured planning with iterative annotation before any implementation.

## When to Use

- Any feature touching 3+ files
- Architectural changes or new subsystems
- Work requiring trade-off decisions
- After completing a research-first pass

## Plan Document

Write a `${project-name}-${feature name from research.md}-plan.md` in the working directory containing:

- **Goal** — one-sentence outcome
- **Approach** — high-level strategy with rationale
- **Steps** — ordered implementation steps with file paths and code snippets
- **Trade-offs** — alternatives considered and why they were rejected
- **Risks** — what could go wrong, mitigation strategies
- **Out of scope** — explicitly list what this plan does NOT cover
- **Todo List** — create a detailed checklist with phases and individual tasks

## Annotation Cycle

1. Generate initial plan
2. User annotates inline with corrections, rejections, domain knowledge
3. Revise plan incorporating all annotations
4. Repeat 1-6 times until plan is approved
5. Guard phrase: always include "don't implement yet" until approved

## Annotation Types

- **Domain correction** — "use X instead of Y, because..."
- **Approach rejection** — "remove this section entirely"
- **Constraint addition** — "this must not change the public API"
- **Scope cut** — "drop this, not needed now"
- **Reference pointer** — "make it work like [existing module/OSS example]"

## Todo List

After plan approval, append a detailed checklist:

- Break into phases and individual tasks
- Each task is a single atomic change
- Tasks map directly to plan steps
- Mark tasks complete during implementation to track progress

## Rules

- Never generate code during planning phase
- Plan lives in a markdown file, not in conversation
- Include code snippets in the plan for clarity, not as final implementation
