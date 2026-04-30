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

Refine for clarity, consistency, maintainability. Don't change behavior — only how it's expressed. Goal: easier to read, understand, extend.

## Scope

Determine from $ARGUMENTS:

- **No argument:** recently modified files (`git diff --name-only` unstaged + `git diff --cached --name-only` staged)
- **File paths:** those files
- **"all":** broader scope — confirm intent before touching many files

If no recent modifications and no argument → inform user and exit.

## What to Simplify

**Reduce Complexity**

- Flatten nested conditionals (early returns, guard clauses)
- Replace complex booleans with named variables
- Break long functions only at natural boundaries — not as reflex
- Simplify control flow (switch over chained if/else when clearer)

**Eliminate Redundancy**

- Remove dead code and unused variables
- Consolidate duplicates only at 3+ repetitions — two similar lines are fine
- Drop intermediate variables that don't add clarity
- Strip comments describing obvious code

**Improve Naming**

- Rename unclear variables / functions to express intent
- Use domain terms consistently
- Booleans read as questions (`is_valid`, `has_permission`)

**Apply Conventions**

- Follow CLAUDE.md if exists
- Default Python:
  - Sorted imports (stdlib, third-party, local)
  - Type hints on signatures
  - Explicit over implicit
  - No nested ternaries — use if/else or match/case
  - `pathlib.Path` over `os.path`

## What NOT to Do

- Don't change behavior or outputs
- No premature abstractions — three similar lines beat a forced helper
- Don't over-compress — clarity beats brevity
- Don't add features, error handling, validation beyond what exists
- Don't touch code outside scope
- Don't add docstrings or type hints to code you didn't otherwise change

## Process

1. Identify in-scope files.
2. Read each, identify simplifications.
3. Apply via Edit. Small, focused edits.
4. After all edits → brief summary: what changed and why, grouped by file.
