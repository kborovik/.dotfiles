---
name: code-review
description: >-
  Review code for bugs, logic errors, security vulnerabilities, and adherence to
  project conventions. Uses confidence-based filtering to report only issues that
  truly matter. Use this skill when the user asks to review code, check for bugs,
  audit quality, or says "review", "check this", "look over", "audit", or "find bugs".
  Also use before merging PRs or after completing implementation work.
argument-hint: [scope: branch, files, or PR number]
model: opus
allowed-tools: Read, Grep, Glob, Bash(git diff *), Bash(git log *), Bash(git show *), Bash(gh pr diff *)
---

# Code Review

Review with precision. Report issues that matter — bugs that break things, security holes, logic errors, convention violations. No noise.

## Review Scope

Determine from $ARGUMENTS:

- **No argument:** unstaged changes (`git diff`)
- **Branch name:** branch diff vs main (`git diff main...<branch>`)
- **PR number:** PR diff (`gh pr diff <number>`)
- **File paths:** specific files
- **"staged":** staged changes (`git diff --cached`)

If scope empty (no changes) → inform user and exit.

## What to Check

**Bugs and Logic Errors**

- Null/undefined handling, off-by-one, race conditions
- Incorrect boolean logic, missing edge cases
- Resource leaks (unclosed files, connections, locks)
- Type mismatches, wrong assumptions about data shapes

**Security**

- Injection (SQL, command, XSS)
- Hardcoded secrets / credentials
- Unsafe deserialization, path traversal
- Missing input validation at system boundaries

**Project Conventions**

- Check CLAUDE.md if exists — violations of explicit rules = high-confidence issues
- Import ordering and module structure
- Naming (variables, functions, classes)
- Project error-handling patterns
- Testing patterns and coverage expectations

**Python-Specific**

- Missing / incorrect type hints
- Bare `except`
- Mutable default args
- Import sort order (stdlib, third-party, local)
- f-string vs .format() consistency

## Confidence Scoring

Rate 0-100:

| Score | Meaning                                                                 |
| ----- | ----------------------------------------------------------------------- |
| 0     | False positive or pre-existing                                          |
| 25    | Maybe real, maybe false. Stylistic without explicit project guideline.  |
| 50    | Real but minor — nitpick or unlikely to cause problems                  |
| 75    | Verified real, affects functionality or called out in project guideline |
| 100   | Confirmed critical, will definitely cause failure                       |

Only report ≥80. Quality over quantity.

## Output Format

State scope first.

Each issue:

- Confidence score
- Severity: **Critical** | **Important**
- File path and line number
- Clear problem description
- Why it matters (project guideline ref or bug explanation)
- Concrete fix

Group by severity (Critical first).

If no high-confidence issues → confirm code meets standards with brief summary of what was checked.
