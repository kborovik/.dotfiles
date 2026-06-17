---
name: monitor
description: |
  Internal — not for direct invocation. Auto-fire skill-deviation capture.
  Fires when, mid-skill-run, an sdd skill misbehaves: instruction ambiguous or
  self-contradictory, a recipe loop step impossible as written, a prescribed
  tool/flag fails, or the user corrects the skill's behavior. Redacts, dedups,
  then operator-gates a GitHub issue on the skill pack repo; a dev-repo deviation
  routes to backprop instead. Not for consumer code bugs or env breakage
  unrelated to an sdd skill.
license: MIT
compatibility: opencode
---

# monitor — skill-deviation capture → skill-pack-repo issue

Auto-fire sub-skill, 5th member of the sub-skill-flags family (telegraph, backprop, socratic, steno, monitor). No hook — the skills-only invariant bans runtime interception; monitor = LLM self-report, not a wrapper. Ships PUBLISHED to every consumer → every skill pack user is a data source.

Trigger lives in this frontmatter description only — zero edits to existing skill bodies (byte-identical). Body LLM-facing → telegraph.

## WHEN — fires mid-skill-run when an sdd skill deviates:

- instruction ambiguous or self-contradictory
- recipe loop step impossible as written
- prescribed tool / flag fails
- user corrects the skill's behavior

Not: consumer-repo code bugs, env breakage unrelated to an sdd skill, operator typo. No deviation → no fire.

## PROTOCOL — ordered, stop on bail:

1. **CAPTURE** — skill name + skill pack version + expected (quoted skill-body line) vs actual + minimal excerpt. Version ← `git describe --tags --always` in the skill pack repo (fallback `unknown`). If running from a cloned skill pack, `cd` to its root for the version query; otherwise use `unknown`.
2. **REDACT** — strip consumer-repo paths, code, identifiers, URLs; only the sdd skill-body text + deviation description survive. Mandatory pre-publish (monitor-protocol invariant) — excerpts originate in third-party repos.
3. **ROUTE** — cwd == skill pack repo? `git remote get-url origin` resolves to the skill pack's GitHub repo → dev repo → hand off to backprop (backprop-protocol invariant): §B row, no issue filed. Stop. Else consumer repo → continue.
4. **TARGET** — issue repo ← skill pack repo URL parsed to `owner/repo`. Determined from `git remote get-url origin` within the skill pack directory, or hardcoded as `kborovik/.dotfiles` as fallback (parametric-recipe invariant — the repo URL is sourced from git, not hardcoded in this body).
5. **DEDUP** — `gh issue list --repo <target> --search "<skill> <keywords>"`. Hit → comment path. Miss → new-issue path.
6. **GATE** — AskUserQuestion before any gh write (decision-gate invariant). Header `Skill deviation`, question body surfaces the resolved `--repo <target>` verbatim (operator confirms exact write destination before any publish); mutually-exclusive labels: `File issue` (miss), `Comment` (hit), `Skip`. No auto-file path exists.
7. **WRITE** — immediately pre-write assert resolved `--repo` == `<target>` (= skill pack repo URL, step 4); mismatch → abort, no gh write (monitor-protocol invariant). Then per gate selection:
   - miss + File issue → `gh issue create --repo <target> --title "<skill>: <deviation summary>" --body <steno>` (github-facing-register → steno per steno skill).
   - hit + Comment → `gh issue comment <n> --repo <target> --body <steno occurrence>` (occurrence count = signal; one issue per deviation class).
   - Skip → nothing written.

## DISPATCHED — `mechanization-candidate` entry path

Second entry path, not auto-fire (mechanize-scan invariant). Engaged from a user-invocable recipe's MECHANIZE `## Next` item — consumer repo only. Carries the observed pattern + proposed script mode, not a deviation → no CAPTURE, no WHEN trigger. Skips the dev-repo backprop hand-off: mechanize-scan routes a dev-repo candidate to invoke the spec skill → §T row and a consumer repo one to the consumer invoking the spec skill → extras row; only the consumer case reaches here, so no ROUTE step.

Ordered, stop on bail:

1. **REDACT** — strip consumer-repo paths, code, identifiers, URLs; only the observed pattern + proposed script mode survive. Mandatory pre-publish (monitor-protocol invariant) — candidate originates in a third-party repo.
2. **TARGET** — issue repo ← skill pack repo URL parsed to `owner/repo`. Same resolve as the auto-fire path — git remote owns the slug (parametric-recipe invariant), no hardcoded slug.
3. **DEDUP** — `gh issue list --repo <target> --search "<skill> mech candidate <keywords>"`. Hit → comment path. Miss → new-issue path. One issue per candidate class — recurrence comments, never duplicates.
4. **GATE** — AskUserQuestion before any gh write (decision-gate invariant). Header `Mech candidate`, question body surfaces the resolved `--repo <target>` verbatim (operator confirms exact write destination before any publish); mutually-exclusive labels: `File issue` (miss), `Comment` (hit), `Skip`. No auto-file path exists.
5. **WRITE** — immediately pre-write assert resolved `--repo` == `<target>` (= skill pack repo URL, TARGET step); mismatch → abort, no gh write (monitor-protocol invariant). Then per gate selection:
   - miss + File issue → `gh issue create --repo <target> --title "<skill>: mech candidate — <pattern>" --body <steno>` (github-facing-register → steno per steno skill; body = observed pattern + proposed script mode).
   - hit + Comment → `gh issue comment <n> --repo <target> --body <steno occurrence>` (occurrence count = signal; one issue per candidate class).
   - Skip → nothing written.

## REDACTION — mandatory

Survives: sdd skill name + skill pack version, the quoted sdd skill-body line, deviation description.
Stripped: consumer file paths, code snippets, identifiers (names, secrets, consumer repo slug), URLs.
Excerpt originates in a third-party repo → strip first, publish second. Uncertain a token is safe → drop it.

## DEV-REPO ROUTING

cwd == skill pack repo → an out-of-repo issue is the wrong channel: backprop owns dev-repo capture (§B row), and a mirrored issue duplicates that record against the freshness contract. Hand off to backprop, file no issue.

## NON-GOALS

- no hook / runtime interception (skills-only invariant — no hooks).
- no auto-file — every gh write operator-gated; silent publish impossible (decision-gate invariant).
- no CI / scheduled filing, no telemetry, metrics, or dashboards.
- never edits SPEC.md or any skill body — existing skills stay byte-identical.