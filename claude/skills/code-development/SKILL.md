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

Systematic approach to feature implementation: understand the codebase deeply, surface all ambiguities, design an architecture, then implement with user approval at key checkpoints.

## Core Principles

- **Ask clarifying questions** before making assumptions. Surface ambiguities early, before designing architecture.
- **Understand before acting.** Read existing code patterns and conventions before writing anything.
- **Read files identified by agents.** When spawning Explore agents, ask them to return lists of key files. Read those files yourself to build detailed context.
- **Simple and elegant.** Prioritize readable, maintainable code over clever solutions.
- **Track progress** with TodoWrite throughout.

Default language conventions: Python (type hints, sorted imports, docstrings for public APIs). Adapt to whatever the project actually uses — check CLAUDE.md and existing code first.

---

## Phase 1: Discovery

**Goal:** Understand what needs to be built.

Initial request: $ARGUMENTS

1. Create a todo list covering all phases.
2. If the feature is unclear, ask the user:
   - What problem are they solving?
   - What should the feature do?
   - Any constraints or requirements?
3. Summarize your understanding and confirm with the user.

---

## Phase 2: Codebase Exploration

**Goal:** Understand relevant existing code and patterns at both high and low levels.

1. Launch 3 `Explore` agents in parallel. Each agent should target a different aspect of the codebase and return a list of 5-10 key files to read. Example prompts:
   - "Find features similar to [feature] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [feature area], tracing through the code comprehensively"
   - "Analyze the current implementation of [existing feature/area], tracing through the code comprehensively"
   - "Identify testing approaches, extension points, or UI patterns relevant to [feature]"

2. Once agents return, read all key files they identified to build deep understanding.
3. Present a comprehensive summary of findings and patterns discovered.

---

## Phase 3: Clarifying Questions

**Goal:** Fill in all gaps and resolve every ambiguity before designing.

This phase is critical. Do not skip it.

1. Review the codebase findings and original feature request.
2. Identify underspecified aspects:
   - Edge cases and error handling
   - Integration points with existing code
   - Scope boundaries (what's in, what's out)
   - Design preferences and backward compatibility
   - Performance needs
3. For each question, provide your recommended answer with rationale. This educates the user on trade-offs and helps them make informed decisions rather than guessing blindly.
4. Present all questions to the user in a clear, organized list.
5. Wait for answers before proceeding to architecture.

---

## Phase 4: Architecture Design

**Goal:** Design an implementation approach with clear trade-offs.

1. Launch a `Plan` agent with full context from exploration and user answers. Ask it to design 2-3 approaches with different trade-offs:
   - Minimal changes (smallest diff, maximum reuse)
   - Clean architecture (maintainability, elegant abstractions)
   - Pragmatic balance (speed + quality)

2. Review all approaches and form your own opinion on which fits best for this specific task. Consider: small fix vs large feature, urgency, complexity, team context.

3. Present to the user:
   - Brief summary of each approach
   - Trade-offs comparison
   - Your recommendation with reasoning
   - Concrete implementation differences

4. Ask the user which approach they prefer.

---

## Phase 5: Implementation

**Goal:** Build the feature.

Do not start without explicit user approval of the chosen approach.

1. Read all relevant files identified in previous phases.
2. Implement following the chosen architecture.
3. Follow codebase conventions strictly (check CLAUDE.md if it exists).
4. Write clean code — prefer clarity over brevity.
5. Update todos as you progress.

---

## Phase 6: Summary

**Goal:** Document what was accomplished.

1. Mark all todos complete.
2. Summarize:
   - What was built
   - Key decisions made
   - Files modified/created
   - Suggested next steps or follow-up work
