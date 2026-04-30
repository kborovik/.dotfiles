---
name: github-issue-create
description: Create, file, open, log, or track a GitHub issue. Use when the user mentions GitHub issues, bug reports, feature requests, or wants to track work on GitHub.
argument-hint: <issue description>
model: opus
allowed-tools: Bash(gh *), Read, Grep, Glob
---

> Notation: terse. See [legend](../legend/SKILL.md) for symbols (`!`, `⊥`, `→`, `∀`, `>`).

Create GitHub issue. Investigate codebase first for context.

## Process

1. **Parse $ARGUMENTS**
   - No description → ask user

2. **Investigate codebase:**
   - Search relevant files via Grep / Glob
   - Read related code → understand current implementation
   - Check git log for recent changes in affected areas
   - Identify affected components / modules

3. **Gather details:**
   - Type: bug, feature, enhancement, refactor
   - Affected files & code paths
   - Bugs → look for error patterns, failing conditions
   - Features → identify where changes needed

4. **Ask clarifying questions if needed:**
   - AskUserQuestion for ambiguous requirements
   - Confirm scope if investigation reveals multiple approaches
   - Bug → ask for repro steps

5. **Generate content:**
   - Title: Conventional Commits — `type(area): concise imperative description`
     - **type**: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`
     - **area**: affected module (`gmail`, `missions`, `cli`, `e2e`, `server`, `contacts`, `calendar`, `schema`, `config`, `llm`)
     - Examples:
       - `fix(gmail): Thread ID divergence breaking outbound assignment routing`
       - `feat(schema): Data deletion policy across schema and delete commands`
       - `refactor(e2e): Redesign fixtures as capability specs`
       - `chore(cli): Remove deprecated debug_modules setting`
   - Body sections:
     - **Summary**: 2-3 sentence description
     - **Context**: Relevant code paths & files from investigation
     - **Proposed Solution** (if applicable): based on codebase analysis
     - **Acceptance Criteria**: clear, testable
     - **Affected Files**: list of files that may need changes

6. **Determine labels:**
   - `gh label list` → see existing labels. ⊥ invent new ones
   - Pick every label that genuinely applies. At minimum: one type label (e.g. `bug`, `enhancement`, `refactor`, `documentation`)
   - Apply area / scope labels when defined (e.g. `gmail`, `cli`, `schema`)
   - No matching type label → ask user before `gh label create`

7. **Create issue:**
   - `gh issue create --title "..." --label "label1" --label "label2" --body "$(cat <<'EOF'...EOF)"`
   - Each label as separate `--label` flag (or comma-separated in single value)
   - Output URL & number

8. **Post insights as comment:**
   - After creating → add comment with notable insights
   - `gh issue comment <number> --body "$(cat <<'EOF'...EOF)"`
   - Include any of:
     - Architectural context discovered
     - Related code patterns / dependencies not obvious
     - Risks or complexity affecting implementation
     - Alternative approaches worth noting
   - Concise & actionable. Skip if no meaningful insights.

## Requirements

- Investigate before asking — gather context first
- Keep investigation focused on description
- ⊥ overly long issues — be concise
- Markdown formatting in body
- Reference specific files / line numbers when relevant
