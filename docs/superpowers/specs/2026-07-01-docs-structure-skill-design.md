# `project-docs` Plugin + `structure` Skill + Marketplace — Design

**Date:** 2026-07-01
**Status:** Approved
**Repo:** new — `talasymov/claude-skills` (public GitHub), local at `~/projects/claude-skills`

## Naming (reads like `superpowers:brainstorming`)
- **Marketplace:** `claude-skills` (a collection that can host several plugins over time)
- **Plugin (namespace):** `project-docs`
- **Skill (action):** `structure`
- **Invocation:** `/project-docs:structure` · **Install:** `project-docs@claude-skills`

## Problem

We built a clean documentation structure for the `gathering_info` project (root
`README` front door → `docs/` living trackers → `docs/handbook/` stable reference →
`docs/superpowers/` per-task artifacts). We want **other projects to adopt and maintain
the same structure**, and we want the recipe to be a **single updatable source** so every
project always uses the latest version — not copy-pasted per repo.

## Goal

A Claude Code **skill** (`structure`, in the `project-docs` plugin) that (1) scaffolds this
documentation structure into any project and (2) guides ongoing maintenance ("what goes
where"), distributed as a **plugin in a git-based marketplace** so it installs once at user
scope, works in every project, and updates via `/plugin marketplace update`.

## Non-Goals

- No project-specific dirs (`data/`, `diagnostics/`, casino specifics). Scaffolds the
  **generic** doc structure only.
- The skill does not manage `docs/superpowers/` contents — those are created by the
  superpowers workflow itself; the skill only references them in the map.
- No CI, no tests-as-code (this is a docs/skill repo). Verification is structural.

## Distribution Architecture

A single self-contained GitHub repo `talasymov/claude-skills` acts as a Claude Code
**marketplace** (has `.claude-plugin/marketplace.json` at root) AND contains the plugin
co-located under `plugins/`.

**User flow (any machine, any project):**
```
/plugin marketplace add talasymov/claude-skills
/plugin install project-docs@claude-skills
```
Installed at **user scope** → the skill is available in every project on that machine.

**Update flow:**
```
/plugin marketplace update claude-skills
```
This pulls the latest marketplace repo commit; Claude Code compares the plugin's
`version` (semver in `plugin.json`) against the installed one and offers the update.

> Note: `/plugin …` are interactive Claude Code commands the USER runs. This project
> only builds and pushes the repo; installation/update is a user action documented in
> the repo README.

## Repo Layout

```
claude-skills/
├── .claude-plugin/
│   └── marketplace.json         # marketplace catalog (lists the project-docs plugin)
├── README.md                    # what this is, install/update commands, contents
├── LICENSE                      # MIT
└── plugins/
    └── project-docs/
        ├── .claude-plugin/
        │   └── plugin.json      # name: project-docs, description, version
        └── skills/
            └── structure/
                ├── SKILL.md     # the skill (scaffold + maintain)
                └── templates/   # files copied during scaffold
                    ├── README.md
                    └── docs/
                        ├── README.md
                        ├── ROADMAP.md
                        ├── TASKS.md
                        ├── TECH_DEBT.md
                        ├── BUGS.md
                        ├── DECISIONS.md
                        ├── PROGRESS.md
                        └── handbook/
                            └── README.md
```

## File Contents (exact shapes)

### `.claude-plugin/marketplace.json`
```json
{
  "name": "claude-skills",
  "owner": { "name": "talasymov" },
  "plugins": [
    {
      "name": "project-docs",
      "source": "./plugins/project-docs",
      "description": "Scaffold and maintain a clear project documentation structure: a root README front door, docs/ living trackers (ROADMAP, TASKS, TECH_DEBT, BUGS, DECISIONS, PROGRESS), a stable handbook, and superpowers task artifacts."
    }
  ]
}
```
(`source` is a relative-path STRING for a co-located plugin — resolved from marketplace
root. Object form is only for external repos.)

### `plugins/project-docs/.claude-plugin/plugin.json`
```json
{
  "name": "project-docs",
  "description": "Scaffold and maintain a clear, consistent project documentation structure.",
  "version": "0.1.0",
  "author": { "name": "talasymov" }
}
```
`version` is semver and is bumped on every meaningful change so `/plugin marketplace
update` detects new releases with a controlled cadence.

### `SKILL.md` frontmatter (`plugins/project-docs/skills/structure/SKILL.md`)
```markdown
---
name: structure
description: Use when setting up or maintaining a project's documentation structure — a root README front door, docs/ living trackers (ROADMAP, TASKS, TECH_DEBT, BUGS, DECISIONS, PROGRESS), a stable docs/handbook reference, and docs/superpowers task artifacts. Triggers: "set up project docs", "documentation structure", "where do I track tasks/tech debt/decisions", "actualize the docs".
---
```
Invocation: `/project-docs:structure` (plugin namespace + skill name); primary trigger is
the `description` (model-invoked).

## The Skill (`SKILL.md` body)

Announce at start: "Using project-docs:structure to <scaffold|maintain> the project docs."

### The structure it establishes (the mental model)
| Layer | Path | Role | Changes |
|-------|------|------|---------|
| Front door | `README.md` | What/why/how, quickstart, map into docs/ | rarely |
| Doc map | `docs/README.md` | Index of all docs | rarely |
| Stable reference | `docs/handbook/` | How the system works (mental model) | rarely |
| Living trackers | `docs/ROADMAP.md` | Direction, milestones | often |
| | `docs/TASKS.md` | Actionable open work | often |
| | `docs/TECH_DEBT.md` | Structural debt | often |
| | `docs/BUGS.md` | Known defects | often |
| | `docs/DECISIONS.md` | ADR log — what & why | on decisions |
| | `docs/PROGRESS.md` | Done-log + lessons | on ship |
| Task artifacts | `docs/superpowers/{specs,plans}/` | Per-task spec+plan | per task |

### Workflow A — Scaffold
1. Detect what already exists (root README, docs/, each tracker).
2. For each missing file, create it from the matching template under `templates/`.
3. **Never overwrite** a file that exists and is non-empty — report it as "kept" and, if
   its content overlaps a tracker, offer to migrate/merge instead.
4. Fill template placeholders (`{{PROJECT_NAME}}`, `{{ONE_LINER}}`, `{{DATE}}`) from the
   repo (dir name, git, or ask the user succinctly).
5. If the project has scattered docs (loose TODO.md, CHANGELOG, ISSUES, planning dirs),
   offer to consolidate them into the right trackers — never silently delete; move via
   `git mv` and cite provenance.
6. Summarize what was created/kept and point the user to `docs/README.md`.

### Workflow B — Maintain (routing rules)
Given a piece of information, put it in exactly one home:
- new work to do → `docs/TASKS.md`
- structural weakness / shortcut taken → `docs/TECH_DEBT.md`
- broken behavior / wrong output → `docs/BUGS.md`
- a choice made + why → `docs/DECISIONS.md` (ADR: `## YYYY-MM-DD — title` + Context/Decision/Why/Consequences)
- something shipped / lesson learned → `docs/PROGRESS.md`
- direction / milestone / requirement → `docs/ROADMAP.md`
- how a subsystem works (durable) → `docs/handbook/`
Also: keep `README.md` and `docs/README.md` links fresh; when a tracker file is renamed
or added, update the map; resolved BUGS move to PROGRESS.

### Safety rules
- Idempotent: re-running scaffold only adds missing pieces.
- Never clobber non-empty files; never delete without moving + citing.
- Templates are generic and language-agnostic; no project-specific dirs.

## Templates (generic, placeholder-driven)
Each template is a minimal, self-explaining stub with a short "how to use this file"
header and `{{PLACEHOLDER}}` tokens. `DECISIONS.md` ships with one seed ADR (the decision
to adopt this structure) as a format example. `docs/handbook/README.md` explains the
reading-order convention and that handbook = stable reference.

## Dogfooding
The `claude-skills` repo itself carries a root `README.md` and this `docs/superpowers/`
spec+plan, demonstrating the structure it distributes.

## Versioning Policy
- semver in `plugin.json`; start `0.1.0`.
- Patch: template/wording fixes. Minor: new template or workflow capability. Major:
  structural change to the doc layout the skill enforces.
- Every change: edit files → bump `version` → commit → push. Users pick it up with
  `/plugin marketplace update claude-skills`.

## Verification
1. `.claude-plugin/marketplace.json` and `plugins/project-docs/.claude-plugin/plugin.json`
   are valid JSON with all required fields.
2. `SKILL.md` has valid frontmatter with `name` and `description`.
3. Templates render: scaffolding into an empty temp dir produces the full tree; re-running
   is a no-op (idempotent); a pre-existing non-empty file is kept, not overwritten.
4. Repo pushed to `github.com/talasymov/claude-skills` (public); README documents the
   three user commands (add / install / update).
5. Manual smoke test by the user: add marketplace, install, invoke `/project-docs:structure`
   in another project.

## Risks
- **Marketplace `source` path format** could change across Claude Code versions — verified
  current form is a relative string for co-located plugins (checked against current docs).
- **Update detection** relies on bumping `version`; forgetting to bump means users don't
  see changes. Mitigation: versioning policy above + a release checklist in the repo README.
- **Installation is user-run** (`/plugin …`); we cannot fully E2E it from here. Mitigation:
  document exact commands; user does the final smoke test.
