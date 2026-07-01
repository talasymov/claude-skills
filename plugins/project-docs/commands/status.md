---
description: Show a compact status dashboard from the docs trackers (read-only).
---
Print a compact project status from the documentation trackers. Read-only — edit nothing.

1. If `docs/TASKS.md` is absent, say the project isn't set up for this structure (suggest the `project-docs:structure` skill) and stop.
2. Using the Read tool, gather:
   - open tasks: count of `- [ ]` lines in `docs/TASKS.md`
   - known bugs: count of open bug entries in `docs/BUGS.md`
   - tech debt: count of items in `docs/TECH_DEBT.md`
   - current focus: the "Current focus" section of `docs/ROADMAP.md`
   - recent progress: the last 3–5 entries of `docs/PROGRESS.md`
3. Print a short summary:
   - a line `Open tasks: N · Bugs: N · Tech debt: N`
   - a `Focus:` line
   - a `Recent:` bullet list
Do not modify any file.
