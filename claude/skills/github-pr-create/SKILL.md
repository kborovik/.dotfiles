---
name: github-pr-create
description: Create a GitHub pull request from an issue number or objective description. Use when the user mentions GitHub PRs, pull requests, or wants to open a PR.
argument-hint: [issue number or PR objective]
model: opus
allowed-tools: Bash(git *), Bash(gh *), Bash(make *), Read, Grep, Glob, Edit, Write
---

Create a pull request from a GitHub issue number or a free-form objective description.

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

### Phase 1: Parse input and create PR

1. **Determine input type from $ARGUMENTS:**
   - If no argument provided: use AskUserQuestion to ask for a GitHub issue number to work on
   - If argument is a number: treat as GitHub issue number (go to step 2a)
   - If argument is text: treat as free-form objective (go to step 2b)

2a. **From issue number — fetch issue details:**

- Fetch issue: `gh issue view <number>`
- Extract issue title, body, and labels
- PR title: Conventional Commits format matching the issue -- `type(area): concise imperative description`
  - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
  - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
  - Derive from the issue title; if the issue already uses this format, reuse it directly
- PR body: include `Resolves #<number>` to auto-close the issue
- Branch name format: `<issue-number>-<slugified-title>` (e.g., `42-add-rate-limiting`)
- Slugify: lowercase, replace spaces with hyphens, remove special chars, max 50 chars
- Create branch and PR:
  - Ensure starting from main: `git checkout main && git pull origin main`
  - Create branch: `git switch --create <issue-number>-<slugified-title>`
  - Empty commit: `git commit --allow-empty --message "wip: <issue-title> (#<issue-number>)"`
  - Push: `git push --set-upstream origin <branch-name>`
  - Create regular PR: `gh pr create --title "..." --body "$(cat <<'EOF'...EOF)"`
  - Output the PR URL

2b. **From free-form objective:**

- Generate a PR title in Conventional Commits format from the objective -- `type(area): concise imperative description`
  - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
  - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
- Do NOT investigate the codebase yet — derive the title directly from the objective
- Slugify title: lowercase, replace spaces with hyphens, remove special chars, max 50 chars
- Create branch and PR:
  - Ensure starting from main: `git checkout main && git pull origin main`
  - Create branch with temporary name: `git switch --create <slugified-title>`
  - Empty commit: `git commit --allow-empty --message "wip: <PR title>"`
  - Push: `git push --set-upstream origin <slugified-title>`
  - Create regular PR: `gh pr create --title "..." --body "$(cat <<'EOF'...EOF)"`
  - Extract the PR number from the output URL

### Phase 2: Implement (after PR exists)

3. **Use `/code-development` skill for implementation:**
   - Invoke the skill with the PR objective/issue description as the argument
   - The skill handles codebase exploration, clarifying questions, architecture design, and implementation
   - Let it drive the full cycle: explore → ask → plan → build

### Phase 3: Refine

4. **Use `/code-simplification` skill on modified files:**
   - Invoke the skill to clean up the implementation
   - This preserves functionality while improving clarity and consistency

### Phase 4: Review

5. **Use `/code-review` skill on branch diff:**
   - Invoke the skill with the branch name to review all changes against main
   - Fix any Critical issues before proceeding
   - Discuss Important issues with the user

### Phase 5: Verify

6. **Run verification gate:**
   - Run `make check` (or project-specific verification sequence) after major code changes
   - If no verification target exists, inform the user and suggest creating one
   - Must pass before the PR is considered complete
   - If the tests fail, diagnose from the output and fix until they pass

### Phase 6: Finalize

7. **Post model insights as PR comment:**
   - After implementation, add a comment to the PR with any notable insights discovered during the work
   - Use `gh pr comment <number> --body "$(cat <<'EOF'...EOF)"`
   - Include any of the following that apply:
     - Architectural observations or design decisions made
     - Technical debt discovered or trade-offs chosen
     - Edge cases identified and how they were handled
     - Alternative approaches considered and why they were rejected
     - Potential risks or areas that may need future attention
   - Keep the comment concise and actionable — skip this step if there are no meaningful insights

## Requirements

- Always create a regular PR (do not use `--draft`)
- Keep branch names concise but descriptive
- When from an issue: always link PR with "Resolves #<number>" in the body
- When from an objective: PR body should contain enough context for reviewers
- The code-development skill handles its own interactive checkpoints — let it drive
- Success is measured by the verification gate passing and code-review finding no Critical issues
