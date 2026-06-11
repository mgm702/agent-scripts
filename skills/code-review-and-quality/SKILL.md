---
name: Code Review and Quality
description: Review local code changes before pushing, across correctness, readability, architecture, security, and performance.
triggers:
  - review this code
  - code review
  - review my changes
  - is this ready to push
  - check this change before I push
---

# Code Review and Quality

Multi-dimensional review of your working changes **before they're pushed**. Catch problems while the code is still local and cheap to fix.

**Standard:** the change should *definitely improve overall code health*, even if imperfect. Don't hold it to "exactly how I'd have written it." If it improves the codebase and follows project conventions, it's good to push.

## When to Use

- Before pushing a set of local changes
- After finishing a feature, refactor, or bug fix (review the fix *and* its regression test)
- When evaluating code written by another agent or model before it leaves your machine

## The Five Axes

1. **Correctness** — Does it do what it claims? Spec match, edge cases (null/empty/boundary), error paths (not just the happy path), off-by-one / race / state bugs, tests that actually test the right thing.
2. **Readability & Simplicity** — Understandable without the author explaining it? Clear names (no bare `temp`/`data`/`result`), straightforward control flow, no clever tricks. Could it be fewer lines? Are abstractions earning their complexity (don't generalize before the third use)? Any dead code?
3. **Architecture** — Fits the system's design? Follows existing patterns (new ones justified), clean module boundaries, no duplication that should be shared, dependencies flowing the right way, appropriate abstraction level.
4. **Security** — Input validated/sanitized at boundaries, secrets out of code and logs, auth checked where needed, queries parameterized, output encoded, external data treated as untrusted. (See the `release-manager` and `devops-agent` skills for launch-time hardening.)
5. **Performance** — N+1 queries, unbounded loops or fetches, sync work that should be async, unnecessary re-renders, missing pagination, large objects in hot paths. (See `performance-optimization` for profiling.)

## Change Sizing

Keep each logical change small and focused — easier to reason about and safer to ship.

```
~100 lines  → Good. Reviewable in one sitting.
~300 lines  → Acceptable if it's a single logical change.
~1000 lines → Too large. Break it into smaller commits.
```

Split large changes by: **stacking** (sequential deps), **file group**, **horizontal** (shared code first), or **vertical** (smaller full-stack slices). Separate refactoring from feature work — that's two changes. Exception: bulk deletions / automated refactors where you verify intent, not every line.

## Process

1. **Understand the context** — what is this change trying to accomplish, and why?
2. **Review the tests first** — do they exist, test behavior (not implementation), cover edge cases, and catch regressions?
3. **Review the implementation** — walk each changed file through the five axes.
4. **Categorize findings** — label each by severity so it's clear what must be fixed before pushing.
5. **Verify the verification** — what tests ran, did the build pass, was it manually checked?

### Severity labels

| Prefix | Meaning | Action |
|---|---|---|
| *(none)* | Required | Fix before pushing |
| **Critical:** | Blocker | Security, data loss, broken functionality — fix now |
| **Nit:** | Minor / optional | May ignore — style preference |
| **Optional:** / **Consider:** | Suggestion | Worth considering, not required |
| **FYI** | Informational | No action |

## Honesty in Review

- Don't rubber-stamp — "looks fine" without evidence helps no one.
- Don't soften real issues. Quantify when possible ("this N+1 adds ~50ms per item" beats "could be slow").
- Push back on flawed approaches and propose alternatives — sycophancy is a failure mode.
- Don't defer cleanup with "I'll fix it later" — it rarely happens. Fix it now or file a self-assigned note.
- Comment on the code, not the author.

## Dependency Discipline

Before adding any dependency: does the existing stack solve it? How large is it? Actively maintained? Known vulnerabilities? Compatible license? **Prefer standard library and existing utilities — every dependency is a liability.**

## Checklist

```markdown
## Review: [change title]
- [ ] I understand what this change does and why
- [ ] Correctness: spec match, edge cases, error paths, tests adequate
- [ ] Readability: clear names, straightforward logic, no needless complexity
- [ ] Architecture: follows patterns, no bad coupling, right abstraction level
- [ ] Security: no secrets, input validated, no injection, auth in place
- [ ] Performance: no N+1, no unbounded ops, pagination on lists
- [ ] Verification: tests pass, build succeeds, manual check done
- [ ] All Critical and Required findings resolved → safe to push
```

## Red Flags

- Pushing changes with no self-review beyond "tests pass"
- Security-sensitive changes without a security-focused pass
- Changes "too big to review properly" (break them up)
- Bug fixes with no regression test
- Findings without severity labels
- Deferring fixes with "I'll get to it later"
