---
name: github-pr-merge
description: Merge a GitHub pull request into main with a release-ready commit message. Use when the user mentions merging a PR, landing a branch, or shipping a GitHub pull request.
argument-hint: [PR number]
model: sonnet
allowed-tools: Bash(git *), Bash(gh *)
---

Merge current branch's PR into main with detailed, release-note-ready commit message.

## gh pr merge Flags Reference

```
-s, --squash          Squash commits into one and merge
-m, --merge           Merge commits with base branch
-r, --rebase          Rebase commits onto base branch
-t, --subject TEXT    Subject/title for merge commit
-b, --body TEXT       Body text for merge commit
-F, --body-file FILE  Read body from file (use "-" for stdin)
-d, --delete-branch   Delete local and remote branch after merge
    --auto            Auto-merge when requirements are met (for merge queues)
    --disable-auto    Disable auto-merge for this PR
    --admin           Bypass merge requirements (admin only)
    --match-head-commit SHA  Verify HEAD matches before merging
```

## Process

1. **Identify PR:**
   - $ARGUMENTS provided → use as PR number
   - Else current branch's PR: `gh pr view --json number,title,body,url`
   - No PR → inform user and exit

2. **Verify ready to merge:**
   - Check remote status:
     - `gh pr checks` — CI status
     - `gh pr view --json mergeable` — merge conflicts
     - `gh pr view --json reviewDecision` — review approval
     - `gh pr view --json isDraft` — draft status
   - Not ready (failing checks, conflicts, missing reviews) → inform user of blockers and exit

3. **Analyze changes:**
   - All commits: `gh pr view --json commits`
   - Files changed: `gh pr diff --name-only` or `git diff main..HEAD --stat`
   - Actual diff: `gh pr diff`
   - Identify scope: bug fix, feature, enhancement, refactor, etc.

4. **Update PR description to reflect completed work:**
   - Compare current body (from step 1) vs actual diff and commit history
   - PR description often outdated — reflects original plan, not what was implemented
   - Update to accurately reflect final state:
     ```bash
     gh pr edit <number> --body "$(cat <<'EOF'
     <updated description>
     EOF
     )"
     ```
   - Keep general structure but ensure:
     - Completed items accurate (not aspirational)
     - Removed / abandoned changes no longer listed
     - Additional work beyond original scope included
   - Skip if description already matches actual changes

5. **Generate release-note-ready commit message:**
   - Title: Conventional Commits from PR title with PR number — `type(area): concise imperative description (#42)`
     - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
     - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
     - Derive from PR title; reuse directly if already in format
   - Body sections:
     - **Summary**: 2-3 sentence description of what changed
     - **Changes**: bulleted list of key changes
     - **Breaking Changes**: if applicable
   - Format for squash merge

6. **Post insights as PR comment:**
   - Before merging → comment with notable insights
   - `gh pr comment <number> --body "$(cat <<'EOF'...EOF)"`
   - Include any of:
     - Code quality / pattern observations in diff
     - Tech debt or risks noticed
     - Follow-up suggestions
     - Edge cases or release considerations
   - Concise and actionable. Skip if no meaningful insights.

7. **Merge:**
   - Squash + `--delete-branch`:
     ```bash
     gh pr merge <number> --squash --delete-branch --subject "<title>" --body "$(cat <<'EOF'
     <body>
     EOF
     )"
     ```
   - Alternatives:
     - Merge commit: `gh pr merge <number> --merge --delete-branch`
     - Rebase: `gh pr merge <number> --rebase --delete-branch`
   - Repos with merge queues → `--auto` to queue when checks pass
   - Always pass `--delete-branch` explicitly. Never short form `-d`. Never omit.

8. **Clean up branches:**
   - `--delete-branch` deletes local and remote branches for merged PR
   - Switch to main: `git checkout main`
   - Pull latest: `git pull origin main`
   - Prune stale refs: `git fetch --prune`

9. **Confirm completion:**
   - Show merge commit: `git log -1`
   - Output merged PR URL
   - Display commit message for release notes

## Commit Message Format

```
feat(server): add user authentication system (#42)

## Summary
Implements JWT-based authentication replacing the session-based system.
Users can now log in and receive tokens that expire after 24 hours.

## Changes
- Add JWT token generation and validation
- Create login and registration endpoints
- Add middleware for protected routes
- Add token refresh endpoint

## Breaking Changes
- Session cookies are no longer supported
- API clients must include Authorization header
```

## Requirements

- Squash merge for clean history (unless repo prefers merge commits)
- Conventional Commits with PR number: `type(area): description (#number)`
- Commit message must be release-note suitable
- `--delete-branch` for branch cleanup
- Verify all checks pass before merging
- Don't force merge if checks failing
- Draft PRs → confirm with user before marking ready
