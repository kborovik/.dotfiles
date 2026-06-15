---
name: rephrase
description: >
  Rephrase a short piece of text (email, message, post) into 3 concise variants
  in different registers: Direct, Warm, and Professional, by handing the work to
  a Sonnet subagent so the drafting never enters the current session's context.
  Preserves meaning, strips filler, keeps each variant easy to skim and
  unambiguous. Triggers on `/rephrase <text>` or explicit asks like "rephrase
  this", "reword this", "give me 3 versions of this message". Do NOT use for
  long-form writing, translation, summarization of unrelated content, or code.
---

# Rephrase

Return 3 rewrites of the user's text in distinct registers — same meaning,
different voice — by delegating the whole job to a **Sonnet subagent**.

## Why delegate

Producing three good rewrites means trying phrasings, weighing registers, and
discarding drafts. That working text clutters the main session but has no value
once the final variants exist. So the rewriting happens inside a subagent, whose
context is discarded when it finishes; only the three finished variants come
back. That keeps the main session lean, which is the point of this skill.

The catch: **you must not rephrase the text yourself.** Drafting variants inline
defeats the purpose. Your only job is to spawn the subagent and relay its output.

## Steps

1. The source is everything after `/rephrase` (or the text the user provided
   alongside the request). If the user gave no text, ask for it in one line and
   stop — do not spawn a subagent.

2. Spawn exactly one subagent with the **Agent** tool:
   - `subagent_type`: `general-purpose`
   - `model`: `sonnet`
   - `prompt`: the block below, with the source text substituted for `<TEXT>`.

3. Relay the subagent's output verbatim — the three labeled code blocks, nothing
   added before or after. Do not re-rephrase or comment on the result.

## Subagent prompt

````
Rephrase the text below into 3 rewrites in distinct registers. Same meaning,
different voice. Each variant must stand alone as a finished message the user can
copy and send. Do all the drafting in your own context — the point is to keep it
out of the parent session.

Source text:
<TEXT>

Output rules:
1. Three variants, always in this order: Direct, Warm, Professional.
2. Each variant goes in its own fenced code block so it is one-click copyable.
   No language tag on the fence.
3. Above each block, a single bold label line: **Direct**, **Warm**,
   **Professional**. Nothing else — no descriptions, no commentary.
4. No preamble, no trailing summary, no "here are your variants", no notes on
   what changed. Just the three labeled blocks.
5. Match the input's length envelope. A one-line text in, one-line variants out.
   A three-paragraph email in, three-paragraph variants out. Do not pad or
   truncate.
6. Preserve all concrete facts: names, dates, numbers, links, asks. If the source
   is ambiguous, keep the ambiguity — do not invent specifics.
7. Match the input's language (English in → English out, etc.).

Style definitions:
- Direct. Lead with the point. Cut hedges ("just", "maybe", "I was wondering
  if"), filler ("I hope this finds you well"), and throat-clearing. Declarative
  sentences. No exclamation marks unless the source had stakes that warrant one.
  Polite by brevity, not by adornment.
- Warm. Same content, friendlier register. One human touch is allowed (a brief
  acknowledgment, a "thanks", a light sign-off) but no fluff and no emoji unless
  the source used them. Still skimmable.
- Professional. Neutral, courteous, no slang or contractions where they'd read as
  casual. Suitable for work email or an external recipient who may forward the
  message. Tight — professional does not mean verbose.

Example
Input: running 10 min late, sorry
Output:

**Direct**
```
Running 10 min late.
```

**Warm**
```
Running about 10 min late — sorry! See you shortly.
```

**Professional**
```
I'm running approximately 10 minutes behind schedule. Apologies for the delay.
```

Return ONLY the three labeled code blocks — nothing before or after.
````
