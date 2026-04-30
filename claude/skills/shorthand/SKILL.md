---
name: shorthand
description: |
  Compression rules for drafting terse human-facing docs (READMEs, design
  notes, internal pages, comments meant to be read). Cuts filler without
  alienating readers — math symbols stay out, arrows stay in. Triggers when
  user says "shorthand", "draft terser", "tighten this doc", "make this
  shorter", "compress this writing".
---

# shorthand — terse docs for humans

Style guide for drafting concise human-readable docs.
Sister to the `legend` skill, which targets SKILL.md authoring.
Difference: this skill assumes a human reader who has not memorized a math glossary.

Does NOT apply to: code, error strings, commit messages, PR descriptions, RFCs, anything for external review.

## GRAMMAR

- Drop articles (a, an, the) where the sentence still parses.
- Drop filler: just, really, basically, simply, actually, very, quite.
- Drop aux verbs where a fragment works: is, are, was, were, being.
- Drop hedging: might, perhaps, could be worth, I think, it seems.
- Drop pleasantries and meta ("in this section we will...").
- Fragments are fine. Lists beat paragraphs.
- Short synonyms: fix > implement, run > execute, big > extensive, use > utilize, help > facilitate.
- One idea per line in lists. Break long sentences.

## SYMBOLS

Safe for general readers:

```
→   leads to / becomes / produces
&   and
|   or (in lists, not prose)
≤   at most
≥   at least
≠   not equal
```

Avoid in human docs (use words instead):

```
∀ ∃ ∴ ⊥ ∈ ∉ §
```

These are precise but slow most readers down. Reserve them for SKILL.md (see `legend`).

## PRESERVE VERBATIM

Never compress:

- Code blocks, snippets, anything in backticks.
- Paths: `src/auth/mw.go`.
- URLs.
- Identifiers: function names, variable names, env vars, flags.
- Numbers, versions, dates.
- Error message strings.
- SQL, regex, JSON, YAML.
- Quoted user-facing copy.

## SHAPES

**Bullet over paragraph** when listing more than two items.

**Definition list** for term/explanation pairs:
```
- `--dry-run` — print actions, do not execute.
- `--force` — skip confirmation prompts.
```

**Table** for comparing options on the same axes:
```
| flag        | scope    | reversible |
|-------------|----------|------------|
| --soft      | local    | yes        |
| --hard      | working  | no         |
```

**Headers + fragments** beat full sentences in reference docs:
```
## Auth
Token in `Authorization: Bearer <jwt>`. Expires after 1h. Refresh via `/auth/refresh`.
```

## EXAMPLES

**Bad** (35 words):
> In order to get started, you will first need to make sure that you have installed all of the necessary dependencies, which can be done by simply running the install command shown below.

**Good** (8 words):
> Install dependencies first:
> ```
> make install
> ```

---

**Bad**:
> The function basically just takes a user object and returns whether or not the user is currently authenticated, which is determined by checking if their session token is still valid.

**Good**:
> `isAuthed(user)` → true if session token still valid.

---

**Bad**:
> It might be worth considering whether we should perhaps add some additional logging here, since it could potentially be helpful for debugging issues that may arise in production environments.

**Good**:
> Add logging here — useful for prod debugging.

---

**Bad**:
> The endpoint accepts POST requests at the path /users and will return a JSON response with a 201 status code containing the newly created user's id field.

**Good**:
> `POST /users` → 201 `{id}`.

## BOUNDARIES

- Reader needs prose (tutorial, onboarding, explainer) → use prose, just leaner.
- External-facing copy (marketing, docs site landing) → normal English, full sentences.
- Long-form decision docs (ADR, RFC) → normal English; tables and bullets where they help.
- Comments that explain WHY in code → normal English, one short line.

## WHEN UNSURE

Cut a word, re-read. If a fact disappeared, put it back. Compression, not amputation.
If the reader would have to slow down to parse a symbol, use the word.
