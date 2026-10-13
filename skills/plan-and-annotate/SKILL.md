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

### The granularity bar

**Write every task so a junior developer or a weak model can execute it without judgment.**

That is the bar, and it is not the same as "a competent engineer could figure this out". The
implementer may be a model that follows directions literally, does not push back, does not
notice a missing step, and will invent something plausible rather than stop. Anything you leave
implicit, it will fill in — wrongly, confidently, and in a way that looks finished.

So a task is not done being written until it answers all of these without the reader thinking:

| | |
|---|---|
| **Where** | Exact file paths, created or edited. Not "the auth module" |
| **What exactly** | Function signatures, type definitions, SQL DDL, env var names, route paths — written out |
| **In what order** | Numbered steps. "Do A, then B" when B depends on A |
| **Against what** | The files to read *before* starting, with line numbers where it helps |
| **How to know it worked** | A **Done when** checklist of observable facts, not "it works" |
| **With what command** | The literal command to run, copy-pasteable |
| **What not to do** | An explicit **Do not** list wherever a plausible wrong turn exists |

**Include real code in the plan.** Not the finished implementation — the shape: the interface,
the type, the migration SQL, the table of values. A weak implementer handed a signature writes
the right function; handed a description, it invents one.

**Write the contract as data where you can.** A permission matrix, a field allowlist, a state
table — put it in the plan as a table and say "implement exactly this". Then the test is
"assert every cell", which is checkable by someone who does not understand the domain.

**State what reality is, so a mismatch is loud.** "`requireAdmin` is wired to zero routes —
`grep` finds it only in its own test." If that stops being true, the implementer notices instead
of quietly working around it. Add a standing rule to the list: *if reality contradicts the plan,
stop and report it — do not improvise.*

### Task template

```markdown
### Task [N]: [Short descriptive title]

**Description:** One paragraph: what this accomplishes and why it exists.

**Before you start:** Read `path/to/file.ts` (lines X–Y) — [the specific thing to notice].
[Any fact about the current state that the steps depend on.]

**Steps:**
1. Create `exact/path.ts`:
   ```ts
   export function exactSignature(arg: Type): ReturnType;
   ```
2. [Next step, with the values/SQL/route written out]
3. [...]

**Done when:**
- [ ] [Observable fact someone can check without understanding the design]
- [ ] [Another]

**Do not:** [the plausible wrong turn, and one clause on why]

**Verification:** `the exact command`

**Files:** `path/a.ts`, `path/b.test.ts`

**Dependencies:** [Task numbers, or "none"] · **Scope:** [XS|S|M|L]
```

Each task should be a single atomic change that maps directly to a plan step. Mark tasks
complete during implementation to track progress.

### Standing rules block

Put these once at the top of the Todo List, not in each task. A weak implementer needs the
guardrails stated, because it will not supply them:

```markdown
> **Rules for every task, without exception:**
> 1. Do not start a task whose dependencies are unchecked.
> 2. Run the full lint + build gate before marking a task done.
> 3. Never widen scope. If a task needs a file it does not list, stop and ask.
> 4. Never commit. Leave changes in the working tree.
> 5. Never weaken a test to make it pass. A failing test is information.
> 6. If reality contradicts this plan, stop and report it. Do not improvise around it.
```

### Group tasks, and gate the groups

Past roughly ten tasks, a flat list stops being navigable. Group them by what they deliver
("the model", "the boundary", "the surface") and put a **review with human** checkpoint between
groups. Mark which checkpoints are security or schema gates — those are the ones where a weak
implementer proceeding unreviewed does real damage.

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

**Setup — provide the Notion token via env var (required once):**
The script reads `NOTION_TOKEN` from the environment. Export it in your shell for the current session:
```bash
export NOTION_TOKEN=ntn_your_integration_token_here
```
To persist it across sessions, add that line to your shell profile (`~/.zshrc` or `~/.bashrc`) or your Claude Code hook environment. Never hardcode the token in this file.

**Fallback — call the script directly** (use this if the hook didn't fire or you need to force a sync):
```bash
ruby ~/code/projects/agent-scripts/scripts/notion_plan_sync.rb path/to/plan.md
```
The script aborts with `NOTION_TOKEN env var not set` if the variable is missing.

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

Granularity red flags — each one means a weak implementer will guess:

- A step that names a concept instead of a path ("update the auth layer")
- A new function with no signature written out
- A migration with no SQL
- "Add tests" with no named cases
- "Verify it works" with no command
- A rule stated in the Approach section but not repeated in the task that must honour it
- A task where the reader must infer the order of steps
- No **Do not** anywhere in a task that has an obvious tempting shortcut

## Verification

Before starting implementation, confirm:

- [ ] Every task has acceptance criteria
- [ ] Every task has a verification step
- [ ] Task dependencies are identified and ordered correctly
- [ ] No task touches more than ~5 files
- [ ] Checkpoints exist between major phases
- [ ] The human has reviewed and approved the plan

Then the granularity check — **read one task as if you knew nothing about the project**:

- [ ] Could you start it from the task alone, without reading the rest of the plan?
- [ ] Is every file path literal, and every new signature written out?
- [ ] Could someone who does not understand the feature tell whether it is done?
- [ ] Is there a command to run, not a description of testing?
- [ ] Does it say what *not* to do where a shortcut exists?

If any answer is no, the task is a description, not an instruction. Expand it.

## Rules

- Never generate code during planning phase
- Plan lives in a markdown file, not in conversation
- Include code snippets in the plan for clarity, not as final implementation
