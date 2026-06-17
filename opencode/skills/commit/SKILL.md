---
name: commit
description: |
  Commit staged changes with a Conventional Commits message. Inspects
  `git diff --cached`, drafts the message, commits the index w/o staging.
  Phrasings: "commit the staged changes", "commit what's staged",
  "commit the index", "commit this". Do NOT use to stage files (`git add`),
  amend, push, or open a PR.
license: MIT
compatibility: opencode
---

# commit — staged commit in-session

Inspect the staged diff, draft a Conventional Commits message, and commit the
index as-is. Runs in the main session for speed.

## Steps

1. Note any guidance the user typed alongside the request (e.g.
   "commit the staged changes — tighten the retry logic"). It shapes the
   message; with no hint, infer everything from the diff.

2. Run `git diff --cached --stat`. If nothing is staged, stop and report
   exactly: "Nothing staged — no commit made." Never run `git add` to
   manufacture something to commit.

3. Read the staged change with `git diff --cached`. Commit the index exactly
   as it stands: no `git add`, no `git commit -a`, no `git commit -A`. A file
   that is only partially staged must keep its unstaged hunks out of the
   commit.

4. Match house style — read `git log --oneline -10`.

5. Write a Conventional Commits message — `type(scope): subject`:
   - type is one of: feat | fix | chore | refactor | docs | test | style | perf | build | ci
   - scope: the tool or directory the change touches
   - subject: imperative mood, lowercase, no trailing period, ~50 chars or fewer
   - Add a body (wrapped at 72 cols) only when the change isn't self-evident.
   - If the user gave guidance, let it drive the wording, but keep the format.

6. Commit with `git commit -m "<subject>"` (add another `-m "<body>"` if you
   wrote a body). Commits are GPG-signed automatically; a pinentry dialog is
   expected. If the commit fails (e.g. a pre-commit hook rejects it), report
   the error output verbatim and stop — do not retry blindly.

7. Relay the result as a single line: short hash + subject, e.g.
   `abc1234 fix(auth): handle expired refresh tokens`. No diff, no preamble.