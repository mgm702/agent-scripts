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

Structured planning with iterative annotation before any implementation. Decompose work into small, verifiable tasks with explicit acceptance criteria, then refine the plan through annotation cycles until it is approved.

## When to Use

- Any feature touching 3+ files
- Architectural changes or new subsystems
- Work requiring trade-off decisions
- A task feels too large or vague to start
- Work needs to be parallelized across multiple agents or sessions
- After completing a research-first pass

**When NOT to use:** Single-file changes with obvious scope, or when the spec already contains well-defined tasks.

## Plan Document

Write a `${project-name}-${feature name from research.md}-plan.md` in the working directory containing:

- **Goal** — one-sentence outcome
- **Approach** — high-level strategy with rationale
- **Steps** — ordered implementation steps with file paths and code snippets
- **Trade-offs** — alternatives considered and why they were rejected
- **Risks** — what could go wrong, mitigation strategies
- **Out of scope** — explicitly list what this plan does NOT cover
- **Todo List** — a detailed task breakdown with phases, checkpoints, and acceptance criteria (see below)

## Dependency Graph and Vertical Slicing

Before writing tasks, map what depends on what. Implementation order follows the dependency graph bottom-up — build foundations first.

```
Database schema
    │
    ├── API models/types
    │       │
    │       ├── API endpoints
    │       │       │
    │       │       └── Frontend API client
    │       │               │
    │       │               └── UI components
    │       │
    │       └── Validation logic
    │
    └── Seed data / migrations
```

Then slice **vertically**: build one complete feature path at a time rather than all of one layer before the next.

**Bad (horizontal slicing):**
```
Task 1: Build entire database schema
Task 2: Build all API endpoints
Task 3: Build all UI components
Task 4: Connect everything
```

**Good (vertical slicing):**
```
Task 1: User can create an account (schema + API + UI for registration)
Task 2: User can log in (auth schema + API + UI for login)
Task 3: User can create a task (task schema + API + UI for creation)
Task 4: User can view task list (query + API + UI for list view)
```

Each vertical slice delivers working, testable functionality.

## Task Structure

Each task in the Todo List follows this structure:

```markdown
## Task [N]: [Short descriptive title]

**Description:** One paragraph explaining what this task accomplishes.

**Acceptance criteria:**
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

**Verification:**
- [ ] Tests pass: `npm test -- --grep "feature-name"`
- [ ] Build succeeds: `npm run build`
- [ ] Manual check: [description of what to verify]

**Dependencies:** [Task numbers this depends on, or "None"]

**Files likely touched:**
- `src/path/to/file.ts`
- `tests/path/to/test.ts`

**Estimated scope:** [Small: 1-2 files | Medium: 3-5 files | Large: 5+ files]
```

Each task should be a single atomic change that maps directly to a plan step. Mark tasks complete during implementation to track progress.

## Task Sizing and Checkpoints

| Size | Files | Scope | Example |
|------|-------|-------|---------|
| **XS** | 1 | Single function or config change | Add a validation rule |
| **S** | 1-2 | One component or endpoint | Add a new API endpoint |
| **M** | 3-5 | One feature slice | User registration flow |
| **L** | 5-8 | Multi-component feature | Search with filtering and pagination |
| **XL** | 8+ | **Too large — break it down further** | — |

If a task is L or larger, break it into smaller tasks. An agent performs best on S and M tasks.

**When to break a task down further:**
- It would take more than one focused session (roughly 2+ hours of agent work)
- You cannot describe the acceptance criteria in 3 or fewer bullet points
- It touches two or more independent subsystems (e.g., auth and billing)
- You find yourself writing "and" in the task title (a sign it is two tasks)

Order tasks so that dependencies are satisfied, each task leaves the system in a working state, and high-risk tasks come early (fail fast). Add explicit checkpoints between phases:

```markdown
## Checkpoint: After Tasks 1-3
- [ ] All tests pass
- [ ] Application builds without errors
- [ ] Core user flow works end-to-end
- [ ] Review with human before proceeding
```

## Parallelization Opportunities

When multiple agents or sessions are available:

- **Safe to parallelize:** Independent feature slices, tests for already-implemented features, documentation
- **Must be sequential:** Database migrations, shared state changes, dependency chains
- **Needs coordination:** Features that share an API contract (define the contract first, then parallelize)

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

## Notion Sync

After writing the local plan file, sync it to Notion using the plan sync script.

**Primary — Stop hook (automatic):**
`~/code/projects/agent-scripts/scripts/notion_plan_sync.rb` runs as a Claude Code Stop hook after every turn. It detects modified `*-plan.md` files via `git diff` and syncs them automatically. No manual action needed.

**Fallback — call the script directly** (use this if the hook didn't fire or you need to force a sync):
```bash
NOTION_TOKEN=ntn_your_integration_token_here \
  ruby ~/code/projects/agent-scripts/scripts/notion_plan_sync.rb \
  path/to/plan.md
```

**How the script works:**
- On first sync: creates a new Notion page under the correct project parent, writes `notion_page_id` and `notion_page_url` into the plan file's YAML front matter
- On subsequent syncs: reads `notion_page_id` from front matter, wipes old blocks, pushes fresh content
- Converts full Markdown (headings, code fences, checkboxes, bullets, dividers) to native Notion blocks
- Routes to the correct project parent page based on the file path (hatchfinder / agent-scripts / odds-api / scaffold)

**Rules:**
- Local file is source of truth; Notion is a mirror
- Never block the plan workflow if Notion sync fails — log the error and continue

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll figure it out as I go" | That's how you end up with a tangled mess and rework. 10 minutes of planning saves hours. |
| "The tasks are obvious" | Write them down anyway. Explicit tasks surface hidden dependencies and forgotten edge cases. |
| "Planning is overhead" | Planning is the task. Implementation without a plan is just typing. |
| "I can hold it all in my head" | Context windows are finite. Written plans survive session boundaries and compaction. |

## Red Flags

- Starting implementation without a written task list
- Tasks that say "implement the feature" without acceptance criteria
- No verification steps in the plan
- All tasks are XL-sized
- No checkpoints between tasks
- Dependency order isn't considered

## Verification

Before starting implementation, confirm:

- [ ] Every task has acceptance criteria
- [ ] Every task has a verification step
- [ ] Task dependencies are identified and ordered correctly
- [ ] No task touches more than ~5 files
- [ ] Checkpoints exist between major phases
- [ ] The human has reviewed and approved the plan

## Rules

- Never generate code during planning phase
- Plan lives in a markdown file, not in conversation
- Include code snippets in the plan for clarity, not as final implementation
