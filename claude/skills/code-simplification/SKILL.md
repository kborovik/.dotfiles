---
name: code-simplification
description: >-
  Simplify and refine code for clarity, consistency, and maintainability while
  preserving all functionality. Focuses on recently modified code unless instructed
  otherwise. Use this skill when the user asks to simplify, clean up, refine, or
  improve code quality. Also use after implementing features to polish the result,
  or when the user says "make this cleaner", "reduce complexity", or "tidy up".
argument-hint: [file paths or scope]
model: opus
allowed-tools: Read, Grep, Glob, Edit, Bash(git diff *)
---

# Code Simplification

Refine code for clarity, consistency, and maintainability. Never change what the code does — only how it expresses it. The goal is code that is easier to read, understand, and extend.

## Scope

Determine what to simplify based on $ARGUMENTS:

- **No argument:** Simplify recently modified files (`git diff --name-only` for unstaged, plus `git diff --cached --name-only` for staged)
- **File paths:** Simplify the specified files
- **"all":** Broader scope — check the user's intent before touching many files

If no files have recent modifications and no argument was given, inform the user and exit.

## What to Simplify

**Reduce Complexity**

- Flatten deeply nested conditionals (early returns, guard clauses)
- Replace complex boolean expressions with named variables
- Break long functions into smaller ones only when a natural boundary exists — not as a reflex
- Simplify control flow (switch over chained if/else when clearer)

**Eliminate Redundancy**

- Remove dead code and unused variables
- Consolidate duplicate logic (but only when 3+ repetitions justify it — two similar lines are fine)
- Remove unnecessary intermediate variables that don't add clarity
- Strip comments that describe obvious code

**Improve Naming**

- Rename unclear variables and functions to express intent
- Use domain terminology consistently
- Make boolean names read as questions (`is_valid`, `has_permission`)

**Apply Conventions**

- Follow project standards from CLAUDE.md if it exists
- Default to Python conventions when no project standard is set:
  - Sorted imports (stdlib, third-party, local)
  - Type hints on function signatures
  - Prefer explicit over implicit
  - Avoid nested ternaries — use if/else or match/case
  - Prefer `pathlib.Path` over `os.path`

## What NOT to Do

- Never change behavior or outputs
- Don't create premature abstractions — three similar lines are better than a forced helper
- Don't over-compress code — clarity beats brevity
- Don't add features, error handling, or validation beyond what exists
- Don't touch code outside the specified scope
- Don't add docstrings or type hints to code you didn't otherwise change

## Process

1. Identify files in scope.
2. Read each file and identify simplification opportunities.
3. Apply changes directly using Edit. Make each edit small and focused.
4. After all edits, present a brief summary: what changed and why, grouped by file.
