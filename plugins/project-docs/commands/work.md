---
description: Start work on the next open task — pick from docs/TASKS.md, confirm, run the superpowers chain, then update the docs.
argument-hint: [optional task name or number]
---
Start a task-driven work cycle using the project's documentation structure.

1. Confirm the project uses this structure: check that `docs/TASKS.md` exists. If not, tell the user to run the `project-docs:structure` skill to scaffold docs first, then stop.
2. Read `docs/TASKS.md` (and `docs/ROADMAP.md` for priority). If "$ARGUMENTS" is non-empty, select the task it names/describes; otherwise pick the top open (`- [ ]`) task, respecting roadmap priority.
3. Present the chosen task in one line and ask the user to confirm (or pick another). Do NOT start until they confirm.
4. On confirmation, run the superpowers workflow scaled to the task:
   - `superpowers:brainstorming` if the task is unclear or design-heavy (spec → `docs/superpowers/specs/`).
   - `superpowers:writing-plans` for non-trivial work (plan → `docs/superpowers/plans/`).
   - Execute with `superpowers:subagent-driven-development` (or `superpowers:executing-plans`), including its reviews and verification.
   - For a trivial, well-defined task, implement directly with `superpowers:test-driven-development` — but still verify.
5. Only after the work is verified complete, update the docs:
   - Check the task off in `docs/TASKS.md` (`- [x]`).
   - Append a dated entry to `docs/PROGRESS.md` (get the date via the Bash tool `date +%F`) describing what shipped + any lessons.
   - If a real decision was made, add an ADR to `docs/DECISIONS.md` (`## <date> — title`, Context/Decision/Why/Consequences).
   - File new defects in `docs/BUGS.md` and shortcuts/debt in `docs/TECH_DEBT.md`; if a bug was fixed, move it from `docs/BUGS.md` to `docs/PROGRESS.md`.
6. Summarize what was done and which docs were updated.

Safety: never overwrite unrelated content; never delete without `git mv` + provenance; never fabricate progress.
