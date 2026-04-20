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

Review code with precision. Focus on issues that genuinely matter — bugs that will break things, security holes, logic errors, convention violations. Avoid noise.

## Review Scope

Determine what to review based on $ARGUMENTS:

- **No argument:** Review unstaged changes (`git diff`)
- **Branch name:** Review branch diff against main (`git diff main...<branch>`)
- **PR number:** Review PR diff (`gh pr diff <number>`)
- **File paths:** Review specific files
- **"staged":** Review staged changes (`git diff --cached`)

If the scope is empty (no changes), inform the user and exit.

## What to Check

**Bugs and Logic Errors**

- Null/undefined handling, off-by-one errors, race conditions
- Incorrect boolean logic, missing edge cases
- Resource leaks (unclosed files, connections, locks)
- Type mismatches and incorrect assumptions about data shapes

**Security**

- Injection vulnerabilities (SQL, command, XSS)
- Hardcoded secrets or credentials
- Unsafe deserialization, path traversal
- Missing input validation at system boundaries

**Project Conventions**

- Check CLAUDE.md if it exists — violations of explicit project rules are high-confidence issues
- Import ordering and module structure
- Naming conventions (variables, functions, classes)
- Error handling patterns used in the project
- Testing patterns and coverage expectations

**Python-Specific** (when reviewing Python code)

- Missing or incorrect type hints
- Bare `except` clauses
- Mutable default arguments
- Import sorting (stdlib, third-party, local)
- f-string vs .format() consistency

## Confidence Scoring

Rate each potential issue 0-100:

| Score | Meaning                                                                                   |
| ----- | ----------------------------------------------------------------------------------------- |
| 0     | False positive or pre-existing issue                                                      |
| 25    | Might be real, might be a false positive. Stylistic without explicit project guideline.   |
| 50    | Real issue but minor — nitpick or unlikely to cause problems in practice                  |
| 75    | Verified real issue that will affect functionality or is called out in project guidelines |
| 100   | Confirmed critical issue that will definitely cause failures                              |

**Only report issues with confidence >= 80.** Quality over quantity.

## Output Format

Start by stating what you're reviewing and the scope.

For each issue, provide:

- Confidence score
- Severity: **Critical** or **Important**
- File path and line number
- Clear description of the problem
- Why it matters (project guideline reference or bug explanation)
- Concrete fix suggestion

Group issues by severity (Critical first, then Important).

If no high-confidence issues exist, confirm the code meets standards with a brief summary of what you checked.
