---
name: reorganize
description: |
  SPEC.md §V cluster + renumber + cite-DAG sweep. Operator-triggered
  clarity-shape pass — distinct from condense (token reduction).
  Phrasings: "reorganize the spec", "regroup §V by topic",
  "renumber invariants", "cluster §V rows", "tidy §V order", "taxonomy pass".
license: MIT
compatibility: opencode
---

# reorganize — §V cluster + renumber + cite-DAG sweep

Operator-triggered clarity-shape pass over SPEC.md §V. Cadence ≤ once per major epoch (months) — skill body documents intent; check skill does not enforce. Single atomic commit, rollback via `git revert`.

## PREAMBLE

State-mutator scoped to SPEC.md + `.opencode/spec-clusters.json` + `.opencode/spec-renumber-map.json` + cite-DAG sweep targets (PUBLISHED + REPO-LOCAL + SPEC.md internal + `SPEC.archive.md` when exists). Operator invokes only per recipe-step-no-dispatch rule. Owns §V renumber permission carved out of monotonic-id invariant.

Distinct from the condense skill: condense = token reduction (folds, archives, trims); reorganize = clarity shape (cluster + renumber) — not token drop, not row folds. Writes serialize main-thread per write-serialize invariant; classification reads delegable to sub-agents. Single commit per atomic-operation discipline, not partial application; cite-DAG sweep per cite-resolution invariant rides same commit.

## LOAD

1. Read `SPEC.md`. Missing → "no spec, nothing to reorganize." Stop.
2. Read `skills/spec/SPEC-FORMAT.md` (deployed to `~/.opencode/skills/spec/SPEC-FORMAT.md`) every row schema and section catalog.
3. Parse `$ARGUMENTS`: empty → full cluster + renumber + sweep propose; `--taxonomy-only` → PROPOSE report only, not mutation.
4. Discovery probe — repo-agnostic skill pack scope per published-scope invariant:
   - (a) `skills/*/SKILL.md` exists → parse frontmatter `name` field; PUBLISHED = all skill dirs found. `name` field absent → directory name as fallback. Internal sub-skills identified by description starting with "Internal — not for direct invocation".
   - (b) else → empty map; sweep targets REPO-LOCAL + SPEC.md internal only.
5. Load `.opencode/spec-clusters.json` if exists, else cold-start. Shape `[{cluster:<name>, rows:[{fingerprint:<hash>, current_id:V<n>}, ...]}, ...]`. Per-row key is §V body-text fingerprint (sha256 over row body w/o `V<n>:` prefix) — stable across renumber; id-as-key invalidates persist every run.
6. Load `.opencode/spec-renumber-map.json` if exists (chain-walk semantics on subsequent runs). Shape `[{run:<iso-date>, topic:<cluster>, old:V<n>, new:V<m>}, ...]` — append-only; `new` admits sentinel `archive` (archived-terminus per archive-sibling schema). Provenance via `git log` on file, not in-file `run_sha`.

## ARCHIVE-RETIRED

Pre-CLUSTER. §V rows w/ body opening `retired YYYY-MM-DD` → migrate to `SPEC.archive.md ## §V.retired` block per archive-sibling schema. Flagged rows skip cluster taxonomy, not consume new ids @ renumber.

1. Grep `^V[0-9]+:\s+retired\s+[0-9]{4}-[0-9]{2}-[0-9]{2}\b` in §V → flagged-set.
2. Citer-protection probe per flagged `V<n>` via cite-resolution cite-DAG: typed columns (§T.cites, §B.fix bare `V<n>`, incl. closed `x` rows) + free-text `§V.<n>` in §V/§C/§I bodies of active SPEC.md. Backtick pre-filter `` `[^`]*(§[VTB]\.[0-9]+|\b[VTB][0-9]+\b)[^`]*` `` (builtin Grep per tooling-preference invariant) excludes §B/§T narrative historical refs per verbatim-preservation invariant.
3. Live citer on any flagged row → bail `cannot archive §V.<n> — live citers: <list>`. Operator resolves pre-retry (fold cited content into surviving row, rewrite citer, or drop `retired` opener).
4. No live citers → flagged-set passes to PROPOSE (`## To archive` block) and EXECUTE (archive write + renumber-map sentinel per row).

## CLUSTER

LLM judgment over each non-archived §V row body → topic-coherent cluster. Two paths:

- **Cold-start** (no persist): propose full taxonomy from scratch. Default span 10 ids per cluster (`V<n>..V<n+9>`), operator-overridable @ PROPOSE.
- **Delta** (persist exists): fingerprint-match each current row; matched fingerprints retain cluster home, moved/new rows reassign. Emit delta-set (new, moved, dropped rows).

Cluster name = short topic-coherent noun phrase (e.g. `spec-mutator-contract`, `audit-mechanics`, `release-flow`, `cite-resolution`). Per-row assignment operator-overridable @ PROPOSE.

## PROPOSE

Render cluster diagram in steno register per github-facing-register invariant (operator-facing). Per cluster: `## <cluster-name> (V<a>..V<b>, <n> rows)` H2 w/ per-row line `- V<old> → V<new>: <one-line summary>`. Trailing summary `<m> clusters, <total> rows, renumber map writes <k> mappings`. Flagged-set not empty → sibling `## To archive` H2 w/ per-row `- V<old>: <one-line body summary>`, so subset-skip path informed @ CONFIRM.

Operator critiques boundaries, names, assignments; iterate until stable. Cold-start = full taxonomy under review; delta = changed rows + new clusters only.

`--taxonomy-only` → emit report, stop. Not CONFIRM, not EXECUTE.

## CONFIRM

AskUserQuestion per decision-gate invariant — single bulk-confirm covers renumber + sweep (mid-flow re-prompt not allowed per atomic-operation discipline):

- **question**: `Reorganize SPEC.md: <m> clusters, <k> id renumbers, <a> archive-retired rows, cite-DAG sweep over <s> sites. Apply?`
- **header**: `Reorganize gate`
- **options** (3, mutually exclusive):
  - `apply renumber + cite-DAG sweep + archive-retired` → EXECUTE w/ full map + flagged set.
  - `subset` → operator-typed cluster list or `skip archive-retired` keyword (retains flagged rows in active §V this run); re-render PROPOSE w/ filter, re-emit CONFIRM.
  - `cancel` → stop, no mutation.

## EXECUTE

Single atomic commit:

1. Archive-retired migration (flagged-set not empty, CONFIRM not `skip archive-retired`):
   - Append flagged rows verbatim to `SPEC.archive.md ## §V.retired` block; create if absent (sibling to `## §T TASKS` / `## §B BUGS` H2s). Preserve `V<orig-n>:` prefix + `retired YYYY-MM-DD — ...` body verbatim; sort ascending by orig id.
   - Drop archived rows from active §V.
   - Emit/update marker `## archived: §V.retired → SPEC.archive.md (<n> retired rows)` under §V heading — count form, not id-range (retired ids non-contiguous).
   - Per archived row append map entry `{run:<iso-date>, topic:'retired', old:V<n>, new:'archive'}`. No paired live-renumber entry (no new id consumed).
2. Append renumber entries to `.opencode/spec-renumber-map.json` per surviving renumbered row (`{run:<iso-date>, topic:<cluster>, old:V<n>, new:V<m>}`). Append-only — never rewrite prior runs.
3. Rewrite §V in cluster order: body verbatim per verbatim-preservation invariant, only `V<n>:` prefix renumbered. Archived ids skipped.
4. Overwrite `.opencode/spec-clusters.json` w/ post-run state; keyed by fingerprint, `current_id` = `V<new>`. Archived rows not persisted (terminus in archive sibling).
5. Cite-DAG sweep w/ renumber map: target set per PREAMBLE scope; backtick pre-filter as ARCHIVE-RETIRED step 2. Every surviving `§V.<old>` free-text or bare `V<old>` typed-column cite (§T.cites, §B.fix) → `§V.<new>` / `V<new>` per context. `new:'archive'` entries not substituted — citer-protection gate already excluded live citers.
6. Probe `.opencode/.gitignore`: both json files not gitignored (git-tracked per scope-set invariant); not guard add.
7. Stage owned paths `git add SPEC.md SPEC.archive.md .opencode/spec-clusters.json .opencode/spec-renumber-map.json` + touched sweep sites (add tracks new-file artifacts), then path-scoped commit `git commit -m <subject> -- <those same paths>` (write-ownership invariant — commit scopes to the owned set, pre-staged files never leak; `-m` flags ! precede `--`); auto-commit msg `reorganize SPEC.md §V: <m> clusters, <k> renumbers, <a> archive-retired`; not user prompt for commit step.

EXECUTE ends @ commit. Rollback `git revert <reorganize-sha>` per single-commit shape. Drift cascade surfaces as Next-block item per response-shape invariant — operator dispatches next turn.

## CHAIN-WALK SEMANTICS

Map is append-only history of all runs; stacked runs admit duplicate `old:` keys: run-1 `{old:V<a>, new:V<b>}`, run-2 `{old:V<b>, new:V<c>}` → `V<a>` resolves via newest-first walk `V<a> → V<b> → V<c>`, terminating when no further `old:` match. Walk landing on `archive` sentinel → emit `archived → SPEC.archive.md ## §V.retired V<n>`, not resolve to live row — distinct terminus from "no further mapping" (current live id). Consumers: reorganize re-runs + explain skill LOAD (historical-id resolution); both walk newest-first, read-only per cite-resolution invariant.

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

Heading `## Next`; 1–5 atomic items (one sentence each, no `Reply` prefix); positional dispatch (`run <int>` or `invoke the <skill-name> skill [args]`). Optional `## Hint` (≤ 3 lines) precedes when item selection needs hidden state. State-mutator → post-EXECUTE prefer: invoke the check skill (confirm cite-DAG + format-layer clean post-renumber).

Example after EXECUTE (commit auto-fired):

```
## Next

1. invoke the check skill — cascade scan over reorganized SPEC.md
2. invoke the build skill --next — start the next pending §T row
3. git revert <reorganize-sha> — rollback if renumber breaks downstream
```

Variants: `--taxonomy-only` exit (not commit) → swap item 1 for: invoke the reorganize skill (apply for real), drop item 3; CONFIRM cancel → swap item 1 for: invoke the reorganize skill --taxonomy-only (re-propose w/ filter), drop item 3.

## NON-GOALS

- not auto-fire — operator-triggered only per recipe-step-no-dispatch rule.
- not partial commit — single atomic commit per atomic-operation discipline.
- not token reduction — routes through the condense skill.
- not row folds — body content preserved (collapse belongs to the condense skill, prong 1); ARCHIVE-RETIRED drops row count via verbatim migration, not collapse.
- not cadence enforcement by the check skill — intent only.
- not hardcoded skill pack dir names — discovery probe drives PUBLISHED scope from `skills/*/SKILL.md` frontmatter.