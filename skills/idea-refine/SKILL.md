---
name: Idea Refine
description: Refine a raw, vague idea into a sharp, actionable concept through structured divergent then convergent thinking, ending in a one-pager ready for planning.
triggers:
  - ideate
  - refine this idea
  - stress-test my plan
  - help me think through
  - sharpen this idea
  - is this idea any good
---

# Idea Refine

Turn a raw idea into a sharp, buildable concept. This is an interactive dialogue, not a template — three phases, each doing one thing well. The output feeds directly into the `plan-and-annotate` skill.

## When to Use

- An idea is still vague and you need to sharpen it before planning
- You want to expand options before converging on one
- You need to stress-test assumptions before committing to a build
- Deciding what NOT to do is as important as what to do

## Philosophy

- Simplicity is the ultimate sophistication — push to the simplest version that still solves the real problem.
- Start with the user experience, work backwards to the technology.
- Say no to 1,000 things. Focus beats breadth.
- Challenge every assumption. "How it's usually done" is not a reason.
- Be honest, not supportive. A good ideation partner is not a yes-machine.

## Process

### 1. Understand & Expand (Divergent)
- Restate the idea as a crisp "How Might We…" problem statement.
- Ask 3–5 sharpening questions (use `AskUserQuestion`): who is this for specifically, what does success look like, real constraints, what's been tried, why now. Don't proceed until you know the user and the success criteria.
- Generate 5–8 variations using lenses: inversion, constraint removal, audience shift, combination, 10x-simpler, 10x-scale, expert lens.
- If inside a codebase, ground variations in existing architecture and prior art.

### 2. Evaluate & Converge
- Cluster the variations that resonated into 2–3 meaningfully distinct directions.
- Stress-test each on: user value (painkiller vs vitamin), feasibility (hardest part?), differentiation (would someone switch?).
- Surface hidden assumptions for each: what you're betting is true, what could kill it, what you're choosing to ignore. **This is where most ideation fails — don't skip it.**

### 3. Sharpen & Ship
Produce the one-pager (below). Save to `docs/ideas/[idea-name].md` only after the user confirms.

## Output

```markdown
# [Idea Name]

## Problem Statement
[One-sentence "How Might We" framing]

## Recommended Direction
[The chosen direction and why — 2-3 paragraphs max]

## Key Assumptions to Validate
- [ ] [Assumption — how to test it]

## MVP Scope
[Minimum version that tests the core assumption. In / out.]

## Not Doing (and Why)
- [Thing] — [reason]

## Open Questions
- [What needs answering before building]
```

The **Not Doing** list is the most valuable part — make the trade-offs explicit.

## Hand-off to Planning

Once the user confirms the one-pager, the idea is sharp but not yet a plan. Hand off to the `plan-and-annotate` skill to turn the Recommended Direction and MVP Scope into an ordered, verifiable task breakdown:

- Offer the hand-off explicitly: "Want me to turn this into an implementation plan?"
- The one-pager becomes the input — its MVP Scope maps to plan steps, its Open Questions seed the plan's Open Questions, and its "Not Doing" list seeds the plan's "Out of scope."
- Do not start implementing here. Idea Refine ends at the approved one-pager; `plan-and-annotate` owns the plan and its "don't implement yet" guard.

## Red Flags

- Generating 20+ shallow variations instead of 5–8 considered ones
- Skipping "who is this for"
- No assumptions surfaced before committing to a direction
- Yes-machining weak ideas instead of pushing back with specificity
- Jumping straight to the output without running phases 1 and 2
- Sliding into implementation instead of handing off to `plan-and-annotate`
