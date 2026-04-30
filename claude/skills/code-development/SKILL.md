---
name: code-development
description: >-
  Guided feature development with codebase understanding and architecture focus.
  Use this skill whenever the user asks to implement a feature, build something new,
  add functionality, or develop a component. Also use when the user says "build",
  "implement", "create", "add support for", or describes work that requires
  understanding existing code before writing new code.
argument-hint: [feature description]
model: opus
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Bash(make *)
---

# Feature Development

Understand codebase → surface ambiguities → design architecture → implement. User approval at checkpoints.

## Core Principles

- **Ask before assuming.** Surface ambiguities before architecture.
- **Read before writing.** Existing patterns and conventions first.
- **Read agent-identified files yourself.** Explore agents return key file lists; you read them to build context.
- **Simple over clever.** Readable and maintainable wins.
- **Track via TodoWrite.**

Default lang: Python (type hints, sorted imports, docstrings on public APIs). Adapt to project — check CLAUDE.md and existing code first.

---

## Phase 1: Discovery

Goal: understand what to build.

Initial request: $ARGUMENTS

1. Todo list covering all phases.
2. If unclear, ask:
   - Problem being solved?
   - What should feature do?
   - Constraints / requirements?
3. Summarize understanding and confirm.

---

## Phase 2: Codebase Exploration

Goal: understand relevant code and patterns, high and low level.

1. Launch 3 `Explore` agents in parallel. Each targets a different aspect, returns 5-10 key files. Example prompts:
   - "Find features similar to [feature] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [feature area], tracing through the code comprehensively"
   - "Analyze the current implementation of [existing feature/area], tracing through the code comprehensively"
   - "Identify testing approaches, extension points, or UI patterns relevant to [feature]"

2. Read all key files agents identified.
3. Present summary of findings and patterns.

---

## Phase 3: Clarifying Questions

Goal: resolve every ambiguity before designing. Do not skip.

1. Review findings and original request.
2. Identify gaps:
   - Edge cases and error handling
   - Integration points
   - Scope boundaries (in / out)
   - Design preferences and backward compat
   - Performance needs
3. Each question → recommended answer + rationale. Educates user on trade-offs → informed decisions, not blind guesses.
4. Present all questions in clear list.
5. Wait for answers before architecture.

---

## Phase 4: Architecture Design

Goal: design with clear trade-offs.

1. Launch `Plan` agent with full context. Ask for 2-3 approaches:
   - Minimal changes (smallest diff, max reuse)
   - Clean architecture (maintainability, elegant abstractions)
   - Pragmatic balance (speed + quality)

2. Form your own opinion. Consider: small fix vs large feature, urgency, complexity, team context.

3. Present:
   - Each approach summary
   - Trade-offs comparison
   - Your recommendation + reasoning
   - Concrete implementation differences

4. Ask user which approach.

---

## Phase 5: Implementation

Goal: build feature.

Do not start without explicit approval of chosen approach.

1. Read all relevant files from prior phases.
2. Implement per chosen architecture.
3. Follow codebase conventions strictly (check CLAUDE.md if exists).
4. Clarity over brevity.
5. Update todos as you progress.

---

## Phase 6: Summary

Goal: document.

1. Mark all todos complete.
2. Summarize:
   - What was built
   - Key decisions
   - Files modified / created
   - Suggested next steps / follow-up
