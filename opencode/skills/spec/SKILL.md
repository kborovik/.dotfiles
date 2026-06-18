---
name: spec
description: |
  Sole semantic author of SPEC.md at repo root — create, amend, fold designs,
  or backprop bugs (§T status-flip → build, archive → condense, §V renumber →
  reorganize; those carve-outs not authoring paths).
  Invoke when user asks to write spec, start new spec, distill spec from
  code, add invariants, amend a section, or record a bug. Common phrasings:
  "write the spec for...", "new spec", "distill spec from code",
  "spec this idea", "import existing repo", "pull invariants out of code",
  "this bug keeps biting", "post-mortem on Y".
license: MIT
compatibility: opencode
---

# spec — spec mutator

The telegraph register applies to all writes here.

## DISPATCH

**Step 0 (precondition):** `git status --porcelain SPEC.md` empty → continue; else bail w/ "SPEC.md has uncommitted changes; commit or stash first" (auto-commit assumes clean baseline; porcelain catches staged + untracked, which `git diff --quiet` misses).

**Step 1 (fold-in shortcut):** `$ARGUMENTS` matches `designs/*.md`, file exists, SPEC.md exists @ repo root → FOLD-IN (skip socratic gate — design skill Open-Questions-empty rule already enforced convergence pre-persist). Design path w/o SPEC.md → bail w/ "fold-in needs SPEC.md; init via NEW or DISTILL first" (design skill degrades gracefully sans SPEC.md so converged drafts can predate it). Else → gate.

Engage the socratic skill gate w/ `$ARGUMENTS` as intent. Single-question loop until convergence triple matches one mode:

- **NEW** — goal + first-principle-asked + (≥ 1 invariant or ≥ 1 task)
- **DISTILL** — explicit "build from code" intent (gate exits ≤ 1 turn — walks repo, no interrogation)
- **BACKPROP** — symptom + surface + recurrence-class
- **AMEND** — §-target + delta

SPEC.md presence is the only branch (mode is gate byproduct, not user-typed prefix):

1. no SPEC.md @ repo root → gate restricted to {NEW, DISTILL}.
2. SPEC.md exists → gate ranges over {BACKPROP, AMEND, NEW}; NEW rare → require explicit re-init confirmation before overwrite.

Post-convergence → run mode procedure below. Escape hatch triggered with unmet-criteria → run mode procedure on partial-facts, append unmet facts as inline callouts or bullet points within §G GOAL or §C CONSTRAINTS to preserve gap visibility. Concrete first-turn input → gate passes ≤ 1 turn (zero-friction); vague → dialogue until convergence. No skip flag, no prefix back-doors.

## NEW — idea → spec

Input: user idea.

1. Goal (1 line, telegraph) → §G.
2. Constraints stated or implied → §C.
3. External surfaces named → §I.
4. Initial invariants → §V (numbered V<n>). Gate probes first-principle (foundational claim); user may decline → converge on derived invariants only. Late first-principle → AMEND §V (only late-entry path, not second authoring path).
5. Goal → ordered tasks → §T pipe table, all status `.`, ids T<n>.
6. §B header row only (`id|date|cause|fix`).

→ APPLY.

## DISTILL — code → spec

Walk repo. Produce §G (infer from README/package.json/main entry), §C (infer from stack), §I (enumerate public APIs/CLIs/configs), §V (derive from tests + assertions), §T (one task per known TODO or missing test), §B (empty). Flag uncertain items w/ `?` so user can confirm.

→ APPLY.

## BACKPROP — bug → §B + §V

Input: gate triple (symptom + surface + recurrence-class).

1. Parse bug.
2. Find root cause (read code).
3. New invariant would catch recurrence? yes → draft `V<next>`.
4. Append §B row `B<next>|<date>|<cause>|<fix>` — fix cell `V<N>` when step 3 drafted, else `-` (per SPEC-FORMAT.md §B fix grammar — `skills/spec/SPEC-FORMAT.md`).
5. Drafted → append invariant to §V.
6. Fix changes behavior → add/patch §T rows.

→ APPLY.

Rule: every bug → §B entry. Invariant optional but preferred.

## AMEND — targeted edit

Input: gate §-target + delta.

Read target §. Show current in steno per the steno register if target in {§V, §B} (audience: user reviewing proposal); telegraph otherwise. Ask user what changes.

→ APPLY.

Never silently rewrite §s user did not name.

## FOLD-IN — design draft → §V or §T amend

Input: `designs/<slug>.md` (converged per design skill Open-Questions-empty rule).

No socratic gate — design skill enforced convergence pre-persist so invoking the spec skill trusts content. Multi-target: one design may propose new §V row(s), §T row(s), §I edit(s), §B row(s) in one apply.

1. Read draft; parse proposed amendments.
2. Draft each in telegraph (target §s + delta text).

→ APPLY.

Rule: fold-in mutates SPEC.md only; design file persists in working tree post-apply (no `git rm`, `git add`, or `rm`) per design-file lifecycle invariant — APPLY write step SPEC.md-only so structurally enforced. User removes or preserves manually. Provenance: slug in SPEC.md commit msg + git history.

## APPLY (all modes, post-delta)

Five steps in order; audits fire on condition, not mode authorship. All audits run pre-show-user, mechanical pattern-match not LLM-judgment per mechanical-not-LLM-judgment invariant.

**Step 0 — write-time prune** (delta-rewrite stage, ordered ahead of audit table so every audit sees final-form delta):

- delta patches pre-existing §V row → §V-row residue prune per WRITE-TIME PRUNE §.
- delta adds or rewrites §B `cause` cell → one-line trim per WRITE-TIME PRUNE §.
- pruned content → commit-msg body (step 4); step 3 shows post-prune form.

**Step 0.5 — empty-delta check**: pruned delta matches live SPEC.md exactly → print "Spec already matches current state; no changes needed." and exit gracefully (skip audits, show-user, and commit).

**Step 1 — audit table** (on-fail column names owning § — bail strings + sub-recipe detail live there only):

```
audit | fires when delta is | on fail
sweep-scope | contains sweep-§T row (§V-violation remediation) | bail → SWEEP-§T SCOPE AUDIT
pinned-cite | touches PUBLISHED (a) or SPEC.md narrative (b) | bail → PINNED-CITE AUDIT, matching sub-recipe
next-block  | touches user-typeable SKILL.md | bail → NEXT-BLOCK-SECTION AUDIT
fold-first  | adds §V row to pre-existing §V section, mode not FOLD-IN | AskUserQuestion gate → FOLD-FIRST AUDIT
```

pinned-cite (a) + next-block rows structurally no-op while step 4 writes SPEC.md only — retained defensive (fire only if future mode widens write set).

Table uses named-invariant + placeholder cite form only (`per <named> invariant`, `§V.<n>`) — `skills/` in PUBLISHED where pinned §-digit cites banned per sub-recipe (a); body pinned-cite count is 0, stays 0.

**Step 2 — render-split**: §V + §B content rows → steno per the steno register (audience: user reviewing proposal); all else → telegraph (§T/§I pipe forms already legible, §G/§C targets, header-only §B row).

**Step 3 — show-user**: render diff preview; await user OK.

**Step 4 — write + commit**: on OK → write SPEC.md (telegraph) + auto-commit path-scoped `git commit -m "<subject>" [-m "<body>"] -- SPEC.md` (double-quote message parameters to prevent zsh and other shell expansion errors; write-ownership invariant — scopes to SPEC.md, pre-staged files never leak); `-m` flags ! precede `--` — message tokens after `--` parse as pathspecs, commit fails; no commit prompt (uniform every mode). Msg per mode:

```
NEW      → init SPEC.md (V<1>..V<n>, T<1>..T<m>)
DISTILL  → init SPEC.md from code
BACKPROP → backprop §B.<n>(+) + §V.<N>(+): <one-line cause>   (trimmed forensics → msg body, from step 0)
AMEND    → amend §<S>.<n>(+): <one-line>                       (pruned history → msg body, from step 0)
FOLD-IN  → fold-in §V.<n>(+) and §T.<n>(+): <slug>            (omit absent §s)
```

**Re-entry**: any stage rewriting delta after step 0 — concretely fold-first's fold-into reroute (new §V row → existing-row amend) — re-enters APPLY @ step 0; rewritten delta newly satisfies §V-row prune and prior audits saw a delta that no longer exists.

APPLY ends @ commit. `## POST-APPLY` fires after, unchanged.

## SWEEP-§T SCOPE AUDIT

Every sweep-§T row (remediating §V-class violation) in delta ! task line declares scope as grep pattern or vocab table per sweep-§T-scope invariant; named-procedure or named-site list not accepted. No pattern → bail w/ `sweep §T row scope ! grep pattern per sweep-§T scope rule`; user supplies pattern, retry.

## PINNED-CITE AUDIT

**Sub-recipe (a) — PUBLISHED-scope ban**: grep `§[VTB]\.[0-9]+` in delta touching PUBLISHED scope (per scope-set invariant). Match → bail `pinned §-cite not allowed in PUBLISHED — use placeholder form (§V.<n>) or inline rule embedding` until rewrite. No PUBLISHED delta → no-op.

**Sub-recipe (b) — SPEC.md-narrative §V resolution**: grep `§V\.[0-9]+` in delta touching SPEC.md narrative (§G/§C/§I/§V/§T/§B body). Pre-filter backtick-wrapped tokens `grep -v -E '`[^`]*§V\.[0-9]+[^`]*`'` (invert scan, grep -v -E per tooling-preference invariant) — historical-quote form per verbatim invariant exempt. Each surviving match resolves against current SPEC.md §V row set (parse `^V[0-9]+:` openers). Unresolved → bail `stale §V.<n> cite in delta — row absent (likely folded); backtick-wrap historical or substitute live row` until rewrite. No narrative delta → no-op.

(a) defends against PUBLISHED-touching deltas via spec-cmd flow — invoking the spec skill normally writes SPEC.md only so typically no-op. (b) closes post-fold authoring gap — fold-time sweep (condense prong-1) substitutes existing cites @ fold-commit; new bare cites to folded id authored post-fold bypass until next check skill invocation. Pattern-match catches what LLM prose-review missed (see §B history).

## NEXT-BLOCK-SECTION AUDIT

Audits touched user-typeable SKILL.md (description does not start with "Internal — not for direct invocation") per skills-only architecture invariant.

Each touched file in post-amend tree:
1. Grep `^(disable-model-invocation|user-invocable):\s*` over frontmatter block. Opencode frontmatter has no such fields → this check is a no-op (preserved for cross-format compatibility).
2. Opt-out match → no-op for this file (auto-fire or programmatic-only, no slash-cmd surface).
3. Else grep `## OUTPUT — "Next" block` heading in post-amend file. Match → no-op; else bail `<skill> SKILL.md lacks Next-block section per response-shape contract` until author adds §.

Defends against new user-typeable skill bodies (or cross-skill-pack migrations) omitting Next-block contract sister skills carry — V20-class runtime rule governs response shape, not authoring-time presence (see §B history). Structurally no-op while APPLY step 4 writes SPEC.md only (mirrors pinned-cite (a) posture).

## FOLD-FIRST AUDIT

Per fold-first authoring invariant (§V.<n>). Mechanical decision-gate.

Each proposed new §V row in delta (provisional ID `V<next>`):

1. Closest existing §V row by topic — heuristic: shared scope tokens (e.g. `PUBLISHED`, `GITHUB-FACING`, `SPEC-ADJACENT`), shared procedure ref (e.g. invoking the spec skill, invoking the check skill), shared verb pattern (e.g. `audit`, `auto-fire`, `gate`). None identifiable → skip AskUserQuestion, auto-route as orthogonal-concept new row.
2. AskUserQuestion per decision-gate invariant (§V.<n>):
   - **question**: `New §V row proposed: <delta one-line>. Closest existing row §V.<m>: <m-summary>. Fold into existing or split as new row?`
   - **header**: `Fold-first`
   - **options** (3, mutually exclusive, label = action):
     - `Fold into §V.<m>` → reroute delta as §V.<m> amend (inline addition to existing row), rewriting any co-occurring references to provisional `V<next>` (e.g., in §B.fix or §T.cites in the same delta) to point to `V<m>`.
     - `New row (cite §B recurrence-class)` → proceed; requires §B.<k> cite in delta justifying split (audit greps `§B\.[0-9]+` post-selection).
     - `New row (orthogonal concept)` → proceed; user-typed orthogonal-concept declaration recorded in commit msg post-selection.
3. Fold-into → re-render delta as §V.<m> amend (including rewritten co-proposed references), re-enter APPLY @ step 0 per Re-entry rule (re-prune + re-audit — not jump to show-user); new-row branches → record justification, proceed to show-user.

Defends against premature-split class — small audit or enforcement-meta additions creating new §V row when inline amend sufficed. "mirrors §V.<n>" alone insufficient justification per fold-first authoring invariant.

## WRITE-TIME PRUNE

Per freshness-contract invariant (SPEC.md is clean current design; history in commit log + archive, not inlined). Auto-rewrites delta → clean current state; pruned history → auto-commit msg body (recoverable via code + `git log`). Show-user diff displays post-prune row — prune reviewed, not blind.

**§V-row delta prune** (delta patches pre-existing §V row): strip inlined-history residue. Pattern set (single source per freshness-contract invariant — shared w/ invoking the check skill for history-residue audit + token-budget condense body-trim prong):

- amendment-counter `(∆)` markers → drop (clean current state carries no edit tally).
- dated-retirement `retired YYYY-MM-DD` clause in live row → drop (wholesale-retired row is reorganize archival job, not amend residue).
- supersession-narration (`pre-amend …`, `prior … retired/dropped/superseded`) → drop.
- `Closes §B.<x>` standalone narration → fold to `(closes §B.<x>)` suffix.

Pre-filters (exempt, not pruned): backtick-wrapped tokens per verbatim-preservation invariant (code-context pattern-defs + quoted historical refs — §V row whose subject is a retirement rule not self-flag); cite-modifier `§V.<n>(∆)` (∆-on-citation marks amended cross-ref, differs ∆-on-retired-value). Stripped content → commit-msg body per APPLY step 4.

**§B cause trim** (delta adds/rewrites §B `cause` cell): auto-trim → one-line bug-class description; multi-line forensics (repro transcript, root-cause walk, sha lineage) → commit-msg body per APPLY step 4. Preview shows trimmed form, not raw forensics.

§T body not pruned here — invoking the build skill flips status cell only per status-flip invariant so §T rows authored one-line @ creation (NEW + BACKPROP drafts); pre-existing §T residue owned by token-budget condense body-trim prong + invoking the check skill for oversized-cell advisory backstop.

## POST-APPLY

Every mode post-commit ! surface invoking the check skill as Next-block item #1 per §V.<n>; operator dispatches next turn → cascade scan over just-applied delta. Not silent commit-then-done. Recipe ends @ commit — skill dispatch is operator turn only.

Catches class where SPEC.md amend invalidates derivative content in `skills/**` (skills, READMEs) w/o manual audit. Next-block surfacing is baseline — operator dispatch is only path to invoking the check skill.

## OUTPUT RULES

Read `skills/spec/SPEC-FORMAT.md` (deployed to `~/.opencode/skills/spec/SPEC-FORMAT.md`) — single source of truth for row shape, section catalog + order, citation forms, header conventions, archive-marker + archive-sibling shape. Direct read, not memorized — re-read every mode (NEW/DISTILL/BACKPROP/AMEND/FOLD-IN) before drafting delta.

Monotonic ID Generation: Compute any new `V<next>`, `T<next>`, or `B<next>` IDs by finding the absolute maximum ID across both `SPEC.md` and `SPEC.archive.md` (if present) and incrementing it, guaranteeing no ID reuse or collision with archived rows.

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

Heading `## Next`; 1–5 atomic items (one sentence each, no `Reply` prefix); positional dispatch (`run <int>` or `invoke the <skill-name> skill [args]`). Optional `## Hint` (≤ 3 lines) precedes when item selection needs hidden state. Two output moments, distinct item leads: show-user turn (diff pending) → apply + revise lead; post-commit turn → invoking the check skill item #1 every mode per POST-APPLY, then invoke the build skill for §T.n when pending §T row exists.

Example @ show-user, diff pending (Hint skipped — items self-explanatory):

```
## Next

1. apply the diff to `SPEC.md`
2. invoke the spec skill to rework the V<N> invariant before building
```

Example post-commit, any mode (invoking the check skill leads per POST-APPLY):

```
## Next

1. invoke the check skill — cascade scan over the just-applied delta
2. invoke the build skill for T<n> — start the next pending task
```

## NON-GOALS

- Writes serialize on main thread; reads delegable to sub-agents — SPEC.md draft + apply + commit stays main-thread; BACKPROP root-cause + NEW/DISTILL code-walk reads delegable.
- No dashboards, no logs, no state files beyond SPEC.md itself.
- No auto-build after spec. User invokes build explicitly.