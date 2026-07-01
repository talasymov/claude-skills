---
description: Update the docs trackers to reflect recent work (review git changes and route them to the right files).
---
Bring the documentation trackers up to date after work.

1. If `docs/TASKS.md` is absent, suggest the `project-docs:structure` skill and stop.
2. Inspect recent changes with the Bash tool: `git log --oneline -15`, `git diff --stat HEAD~5..HEAD` (shrink the range if history is short), and `git status` for uncommitted work.
3. For what ACTUALLY changed, update the trackers per the routing rules:
   - shipped work / lessons → append to `docs/PROGRESS.md` (dated; `date +%F`)
   - completed items → check off in `docs/TASKS.md`; a resolved bug moves from `docs/BUGS.md` to `docs/PROGRESS.md`
   - new open work → `docs/TASKS.md`; new defects → `docs/BUGS.md`; shortcuts/debt → `docs/TECH_DEBT.md`
   - decisions made → `docs/DECISIONS.md` (ADR format)
   - direction changes → `docs/ROADMAP.md`
   - if tracker files were added/renamed, refresh links in `README.md` and `docs/README.md`
4. Make NO change where none is warranted. Summarize exactly what you updated (file + one line each).

Safety: only record what the diff/log/status supports; never fabricate; never delete without `git mv` + provenance.
