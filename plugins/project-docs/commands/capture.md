---
description: Capture a quick note into the right tracker (task / bug / tech debt / decision).
argument-hint: <the note to capture>
---
Capture "$ARGUMENTS" into exactly one documentation tracker.

1. If `docs/TASKS.md` is absent, suggest the `project-docs:structure` skill and stop.
2. Classify "$ARGUMENTS":
   - actionable work → `docs/TASKS.md` (append `- [ ] <note>`)
   - broken behavior / defect → `docs/BUGS.md` (append a `### <title>` entry, Status: open, the note as Symptom)
   - structural weakness / shortcut → `docs/TECH_DEBT.md` (append a bullet)
   - a decision + rationale → `docs/DECISIONS.md` (ADR entry; date via `date +%F`)
   If ambiguous, ask one short clarifying question; otherwise pick the best fit.
3. Append in that file's existing format (do not rewrite the file). Confirm where it went in one line.
