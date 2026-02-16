# Implementation Control

Controlled execution and supervisor-style feedback during implementation.

## When to Use

- Executing an approved plan
- Any multi-step implementation session
- When course-correcting mid-implementation

## Execution

- Implement continuously — don't pause for confirmation between tasks
- Mark each task/phase complete in the plan document as you go
- Run quality gates continuously (typecheck, lint, tests) — don't batch at the end
- Stop immediately on red quality gates; fix before continuing

## Progress Tracking

- The plan document is the source of truth for progress
- Update todo checkboxes as tasks complete
- Plan survives context compaction; conversation does not

## Feedback Style

- Short, direct corrections — one sentence when possible
- Point to reference implementations: "make it look like X"
- Use screenshots for visual/UI issues
- No need to re-explain context; the plan document has it

## Course Correction

- Prefer **revert + re-scope** over patching a bad approach
- When reverting: narrow the scope, don't retry the same plan
- Cherry-pick good parts from a failed attempt; discard the rest

## Scope Control

- Cut features from the plan rather than letting complexity grow
- Set hard constraints: "these function signatures must not change"
- Override over-engineering: "just use Promise.all, keep it simple"
- No unnecessary comments, jsdocs, or `any` types

## Anti-Patterns

- Patching broken code instead of reverting and re-scoping
- Stopping after each task to ask for confirmation
- Letting the plan drift from the approved version without flagging it
- Adding features not in the plan
