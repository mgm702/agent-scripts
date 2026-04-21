---
name: GitHub
description: Expert gh CLI usage for issues, PRs, code review, and repository automation.
triggers:
  - create PR
  - open issue
  - gh cli
  - pull request
  - github automation
  - merge PR
---

# GitHub

Expert `gh` CLI usage for issues, PRs, and automation.

## Flow

- Discovery: `gh issue list` -> `gh issue view <num>`
- Branch: `gh issue develop <num>` or manual branch from issue
- Work: commit locally, push when ready
- PR: `gh pr create --fill` or `gh pr create --title "..." --body "..."`
- Review: `gh pr checks`, `gh pr review`
- Merge: `gh pr merge --squash` (prefer squash)

## Safety

- Never push without asking user first
- Check CI before merge: `gh run list --branch <branch>`
- Review PR diff before merge: `gh pr diff`
- Draft PRs for WIP: `gh pr create --draft`

## Automation

- Complex queries: `gh api` with GraphQL or REST
- Bulk operations: `gh api graphql` with pagination
- Labels/milestones: `gh issue edit --add-label`
- Release: `gh release create` with auto-generated notes

## Patterns

- Link issues to PRs: "Closes #N" in PR body
- Use `gh repo clone` over raw git clone
- `gh auth status` to verify credentials
- `gh status` for cross-repo notification overview
