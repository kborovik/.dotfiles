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

> Notation: terse. See [legend](../legend/SKILL.md) for symbols (`!`, `⊥`, `→`, `∀`, `>`).

Refine for clarity, consistency, maintainability. ⊥ change behavior — only how it's expressed. Goal: easier to read, understand, extend.

## Scope

Determine from $ARGUMENTS:

- **No argument:** recently modified files (`git diff --name-only` unstaged + `git diff --cached --name-only` staged)
- **File paths:** those files
- **"all":** broader scope — confirm intent before touching many files

If no recent modifications & no argument → inform user & exit.

## What to Simplify

**Reduce Complexity**

- Flatten nested conditionals (early returns, guard clauses)
- Replace complex booleans with named variables
- Break long functions only at natural boundaries — not as reflex
- Simplify control flow (switch over chained if/else when clearer)

**Eliminate Redundancy**

- Remove dead code & unused variables
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
  - Explicit > implicit
  - ⊥ nested ternaries — use if/else or match/case
  - `pathlib.Path` > `os.path`

## What NOT to Do

- ⊥ change behavior or outputs
- ⊥ premature abstractions — three similar lines > forced helper
- ⊥ over-compress — clarity > brevity
- ⊥ add features, error handling, validation beyond what exists
- ⊥ touch code outside scope
- ⊥ add docstrings or type hints to code you didn't otherwise change

## Process

1. Identify in-scope files.
2. Read each, identify simplifications.
3. Apply via Edit. Small, focused edits.
4. After all edits → brief summary: what changed & why, grouped by file.
