---
name: github-pr-create
description: Create a GitHub pull request from an issue number or objective description. Use when the user mentions GitHub PRs, pull requests, or wants to open a PR.
argument-hint: [issue number or PR objective]
model: opus
allowed-tools: Bash(git *), Bash(gh *), Bash(make *), Read, Grep, Glob, Edit, Write
---

> Notation: terse. See [legend](../legend/SKILL.md) for symbols (`!`, `⊥`, `→`, `∀`, `>`).

Create PR from issue number or free-form objective.

## gh pr create Flags Reference

```
-a, --assignee login       Assign people by their login (@me to self-assign)
-B, --base branch          The branch into which you want your code merged
-b, --body string          Body for the pull request
-F, --body-file file       Read body text from file (use "-" for stdin)
-d, --draft                Mark pull request as a draft
    --dry-run              Print details instead of creating the PR
-f, --fill                 Use commit info for title and body
    --fill-first           Use first commit info for title and body
    --fill-verbose         Use commits msg+body for description
-H, --head branch          The branch that contains commits for your PR (default: current branch)
-l, --label name           Add labels by name
-m, --milestone name       Add the PR to a milestone by name
    --no-maintainer-edit   Disable maintainer's ability to modify PR
-p, --project title        Add the PR to projects by title
-r, --reviewer handle      Request reviews from people or teams by handle
-T, --template file        Template file to use as starting body text
-t, --title string         Title for the pull request
-w, --web                  Open the web browser to create a PR
```

## Process

### Phase 1: Parse input & create PR

1. **Determine input type from $ARGUMENTS:**
   - No argument → AskUserQuestion for issue number
   - Number → issue number (step 2a)
   - Text → free-form objective (step 2b)

2a. **From issue number — fetch details:**

- `gh issue view <number>`
- Extract title, body, labels
- PR title: Conventional Commits matching issue — `type(area): concise imperative description`
  - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
  - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
  - Derive from issue title; reuse directly if issue already uses format
- Body: include `Resolves #<number>` to auto-close issue
- Branch name: `<issue-number>-<slugified-title>` (e.g., `42-add-rate-limiting`)
- Slugify: lowercase, spaces → hyphens, strip special chars, max 50 chars
- Create branch & PR:
  - Start from main: `git checkout main && git pull origin main`
  - Branch: `git switch --create <issue-number>-<slugified-title>`
  - Empty commit: `git commit --allow-empty --message "wip: <issue-title> (#<issue-number>)"`
  - Push: `git push --set-upstream origin <branch-name>`
  - Regular PR: `gh pr create --title "..." --body "$(cat <<'EOF'...EOF)"`
  - Output URL

2b. **From free-form objective:**

- Generate Conventional Commits title from objective — `type(area): concise imperative description`
  - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
  - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
- ⊥ investigate codebase yet — derive title directly from objective
- Slugify: lowercase, spaces → hyphens, strip special chars, max 50 chars
- Create branch & PR:
  - Start from main: `git checkout main && git pull origin main`
  - Branch w/ temp name: `git switch --create <slugified-title>`
  - Empty commit: `git commit --allow-empty --message "wip: <PR title>"`
  - Push: `git push --set-upstream origin <slugified-title>`
  - Regular PR: `gh pr create --title "..." --body "$(cat <<'EOF'...EOF)"`
  - Extract PR number from output URL

### Phase 2: Implement (after PR exists)

3. **Use `/code-development` skill:**
   - Invoke w/ PR objective / issue description as argument
   - Skill handles exploration, clarifying questions, architecture, implementation
   - Let it drive: explore → ask → plan → build

### Phase 3: Refine

4. **Use `/code-simplification` on modified files:**
   - Cleans up implementation
   - Preserves functionality, improves clarity & consistency

### Phase 4: Review

5. **Use `/code-review` on branch diff:**
   - Invoke w/ branch name → review all changes vs main
   - Fix Critical issues before proceeding
   - Discuss Important issues w/ user

### Phase 5: Verify

6. **Run verification gate:**
   - `make check` (or project-specific) after major changes
   - No verification target → inform user, suggest creating one
   - ! Must pass before PR considered complete
   - Tests fail → diagnose & fix until pass

### Phase 6: Finalize

7. **Post insights as PR comment:**
   - After implementation → comment with notable insights
   - `gh pr comment <number> --body "$(cat <<'EOF'...EOF)"`
   - Include any of:
     - Architectural observations / design decisions
     - Tech debt discovered or trade-offs chosen
     - Edge cases identified & how handled
     - Alternatives considered & why rejected
     - Risks or future-attention areas
   - Concise & actionable. Skip if no meaningful insights.

## Requirements

- ! Always regular PR (⊥ `--draft`)
- Branch names concise but descriptive
- From issue → ! "Resolves #<number>" in body
- From objective → body must contain enough context for reviewers
- code-development skill drives its own checkpoints — let it
- Success = verification gate passes & code-review finds no Critical issues
