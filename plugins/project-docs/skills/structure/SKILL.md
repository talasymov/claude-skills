---
name: structure
description: Use when setting up or maintaining a project's documentation structure — a root README front door, docs/ living trackers (ROADMAP, TASKS, TECH_DEBT, BUGS, DECISIONS, PROGRESS), a stable docs/handbook reference, and docs/superpowers task artifacts. Triggers include "set up project docs", "documentation structure", "where do I track tasks / tech debt / decisions", "actualize the docs".
---

# Project Docs Structure

Scaffold and maintain a clear, consistent documentation structure in any project.

**Announce at start:** "Using project-docs:structure to <scaffold|maintain> the project docs."

## The structure (mental model)

| Layer | Path | Role | Changes |
|-------|------|------|---------|
| Front door | `README.md` | What/why/how, quickstart, map into docs/ | rarely |
| Doc map | `docs/README.md` | Index of all docs | rarely |
| Stable reference | `docs/handbook/` | How the system works (mental model) | rarely |
| Living tracker | `docs/ROADMAP.md` | Direction, milestones | often |
| Living tracker | `docs/TASKS.md` | Actionable open work | often |
| Living tracker | `docs/TECH_DEBT.md` | Structural debt | often |
| Living tracker | `docs/BUGS.md` | Known defects | often |
| Living tracker | `docs/DECISIONS.md` | ADR log — what & why | on decisions |
| Living tracker | `docs/PROGRESS.md` | Done-log + lessons | on ship |
| Task artifacts | `docs/superpowers/{specs,plans}/` | Per-task spec+plan | per task |

**Role separation:** `docs/handbook/` = stable "how it works" reference; `docs/*.md` = living trackers that change most sessions; `docs/superpowers/` = artifacts for a specific task.

## Workflow A — Scaffold

Use when a project lacks this structure (or is missing parts).

1. Detect what exists: check for root `README.md`, `docs/`, and each tracker file.
2. For each MISSING file, create it by copying the matching template from this skill's
   `templates/` directory (same relative layout: `templates/README.md` → `README.md`,
   `templates/docs/*` → `docs/*`).
3. **Never overwrite** a file that exists and is non-empty. Report it as "kept". If its
   content overlaps a tracker (e.g. an existing `TODO.md`), OFFER to migrate/merge — do not
   force it.
4. Fill placeholders in the copied files: `{{PROJECT_NAME}}` (from the git repo / directory
   name), `{{ONE_LINER}}` (ask the user one short question if unknown), `{{DATE}}` (today).
5. If the project has scattered docs (loose `TODO.md`, `CHANGELOG`, `ISSUES`, `.planning/`,
   ad-hoc notes), OFFER to consolidate them into the right trackers. Move with `git mv` and
   cite provenance; never silently delete.
6. Summarize what was created vs kept, and point the user to `docs/README.md`.

Idempotent: re-running only fills in missing pieces.

## Workflow B — Maintain (routing rules)

When new information appears, put it in exactly ONE home:

| Information | Home |
|-------------|------|
| New work to do | `docs/TASKS.md` |
| Structural weakness / shortcut taken | `docs/TECH_DEBT.md` |
| Broken behavior / wrong output | `docs/BUGS.md` |
| A choice made + why | `docs/DECISIONS.md` |
| Something shipped / lesson learned | `docs/PROGRESS.md` |
| Direction / milestone / requirement | `docs/ROADMAP.md` |
| How a subsystem works (durable) | `docs/handbook/` |

`DECISIONS.md` entries use ADR format:
```
## YYYY-MM-DD — <title>
**Context:** … **Decision:** … **Why:** … **Consequences:** …
```

Also: keep `README.md` and `docs/README.md` links fresh; when a tracker is added/renamed,
update the map; move resolved bugs from `BUGS.md` to `PROGRESS.md`.

## Safety rules

- Idempotent; never clobber non-empty files; never delete without `git mv` + provenance.
- Templates are generic — do not invent project-specific dirs. Adapt content, not the skeleton.
