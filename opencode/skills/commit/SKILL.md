---
name: commit
description: |
  Delegate commit of staged changes to a subagent — diff + message draft stay
  out of the main session context. Subagent inspects `git diff --cached`, writes
  Conventional Commits message, commits the index w/o staging. Phrasings: "commit
  the staged changes", "commit what's staged", "commit the index", "commit this".
  Do NOT use to stage files (`git add`), amend, push, or open a PR.
license: MIT
compatibility: opencode
---

# commit — staged-commit delegation

Commit the staged changes — and nothing else — by delegating the whole job to a
**subagent**.

## Why delegate

Reading a diff, weighing what changed, and drafting a message can pull hundreds
of lines into context. None of it is useful to the main session afterward — only
the resulting commit is. So the heavy lifting happens inside a subagent, whose
context is discarded when it finishes; only a one-line confirmation comes back.
That keeps the main session lean, which is the entire point of this skill.

The catch: **you must not read the diff yourself.** If you run `git diff`,
`git status -v`, or open the changed files, you defeat the purpose. Your only job
is to spawn the subagent and relay its answer.

## Steps

1. Note any guidance the user typed alongside the request (e.g.
   "commit the staged changes — tighten the retry logic"). It shapes the
   message; with no hint, the subagent infers everything from the diff.

2. Spawn exactly one subagent with the **Task** tool:
   - `subagent_type`: `general`
   - `description`: `commit staged changes`
   - `prompt`: the block below, with the user's hint substituted (or "none").

3. Relay the subagent's confirmation line verbatim. Do not re-read the diff,
   restate the change, or add commentary.

## Subagent prompt

```
Commit ONLY the currently staged changes in this repository. Do all of the
analysis in your own context — the point is to keep it out of the parent session.

User guidance for the message (may be "none"): <HINT>

Rules:
- Run `git diff --cached --stat` first. If nothing is staged, stop and report
  exactly: "Nothing staged — no commit made." Never run `git add` to manufacture
  something to commit.
- Read the staged change with `git diff --cached`. Commit the index exactly as it
  stands: no `git add`, no `git commit -a`, no `git commit -A`. A file that is
  only partially staged must keep its unstaged hunks out of the commit.
- Write a Conventional Commits message — `type(scope): subject`:
  - type is one of: feat | fix | chore | refactor | docs | test | style | perf | build | ci
  - scope: the tool or directory the change touches
  - subject: imperative mood, lowercase, no trailing period, ~50 chars or fewer
  - Add a body (wrapped at 72 cols) only when the change isn't self-evident.
  - Match the house style — read `git log --oneline -10` first.
  - If the user gave guidance, let it drive the wording, but keep the format.
- Commit with `git commit -m "<subject>"` (add another `-m "<body>"` if you wrote
  a body). Commits are GPG-signed automatically; a pinentry dialog is expected.
  If the commit fails (e.g. a pre-commit hook rejects it), report the error
  output verbatim and stop — do not retry blindly.

Return ONLY a terse confirmation: the short hash and the subject, e.g.
`abc1234 fix(auth): handle expired refresh tokens`. No diff, no preamble, no
explanation.
```

## MECHANIZE — script-candidate scan

Recipe end → before the `## Next` block, scan this run for a mechanization candidate. Candidate = any of:

- ≥ 2 same-shape deterministic calls this run (identical command modulo args)
- LLM-side join / sort / count / dedup over script-emittable data
- multi-step parse collapsible to one script emit mode
- fresh regex paraphrase of an existing mechanical rule (mechanical-realization invariant class)

Hit → emit exactly one `## Next` item naming the observed pattern + proposed script mode; none → no item. Never self-implement the mechanization mid-run (recipe-step-no-dispatch + write-ownership invariants). Route by cwd:

- dev repo (this skill pack) → invoke the spec skill → new §T row
- consumer repo → invoke the spec skill → `.opencode/check-extras` row

## OUTPUT — "Next" block

Heading `## Next`; 1–5 atomic items (one sentence each, no `Reply` prefix); positional dispatch (`run <int>` or `invoke the <skill-name> skill [args]`). Optional `## Hint` (≤ 3 lines) precedes when item selection needs hidden state (subagent error vs clean success, push needed, post-commit drift verify). Read-only post-commit — items are follow-up actions, never re-invoke the commit skill (would re-run subagent on no staged changes; "Nothing staged — no commit made" per subagent prompt rule).

Example after clean commit (confirmation relayed):

```
## Next

1. run `git push` — sync to remote
2. invoke the check skill — drift verify on just-committed change
```

Variants: subagent error reported (commit failed, e.g. pre-commit hook reject) → swap item 1 for: fix the failing hook/issue + re-stage + re-invoke the commit skill, drop item 2. Nothing-staged reported → swap item 1 for: stage specific files + re-invoke, drop item 2.
