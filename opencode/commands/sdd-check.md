---
description: Read-only drift detector. Diffs SPEC.md vs current code, reports violations grouped by severity. Writes nothing — suggests remedies via spec or build skills, never invokes them. Use when user asks to check drift, audit spec, or verify invariants ("check drift", "audit the spec", "check invariants", "spec vs code", "is the spec still accurate?", "did the code drift?").
agent: build
---

invoke the check skill $ARGUMENTS
