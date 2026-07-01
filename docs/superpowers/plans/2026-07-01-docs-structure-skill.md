# `project-docs` Plugin + `structure` Skill — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `talasymov/claude-skills` marketplace repo containing the `project-docs` plugin whose `structure` skill scaffolds and maintains a standard project documentation structure, installable/updatable via Claude Code's plugin system.

**Architecture:** A single self-contained git repo is both a Claude Code marketplace (`.claude-plugin/marketplace.json` at root) and the home of the co-located `project-docs` plugin (`plugins/project-docs/`). The plugin ships one skill (`structure`) plus a `templates/` tree the skill copies into target projects. Distribution/updates use the native `/plugin` commands (user-run).

**Tech Stack:** Markdown, JSON, git, `gh` CLI (authed as talasymov), shell for structural verification. No compiled code, no pytest — verification is JSON validity + a scaffold smoke test.

## Global Constraints

- Marketplace name: `claude-skills`. Plugin name: `project-docs`. Skill name: `structure`. Invocation `/project-docs:structure`. Install ref `project-docs@claude-skills`.
- `marketplace.json`: required top-level `name`, `owner{name}`, `plugins[]`; each plugin entry needs `name`, `source`, `description`. Co-located plugin `source` is the relative STRING `"./plugins/project-docs"` (never an object).
- `plugin.json`: required `name`; include `description`, `version` (semver, start `0.1.0`), `author{name}`.
- `SKILL.md` frontmatter: required `description`; include `name: structure`.
- Templates are GENERIC and language-agnostic — no `data/`, `diagnostics/`, or casino specifics. Placeholders use `{{PROJECT_NAME}}`, `{{ONE_LINER}}`, `{{DATE}}`.
- Skill behavior is idempotent and MUST NOT overwrite existing non-empty files or delete anything without `git mv` + provenance.
- Repo is public GitHub `talasymov/claude-skills`. Commits use `-c user.name=talasymov -c user.email=tmsweane@gmail.com` (repo has no configured identity).
- Work happens in `~/projects/claude-skills` on branch `main` (already `git init`'d, spec+plan committed there).
- All JSON must pass `python3 -m json.tool` (valid JSON, no comments/trailing commas).

---

### Task 1: Marketplace + plugin manifests + repo meta

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Create: `plugins/project-docs/.claude-plugin/plugin.json`
- Create: `LICENSE` (MIT, 2026 talasymov)
- Create: `.gitignore`

**Interfaces:**
- Produces: the marketplace catalog + plugin manifest that all later tasks and users depend on. Marketplace name `claude-skills`; plugin name `project-docs`; plugin `source` `./plugins/project-docs`.

- [ ] **Step 1: Write `.claude-plugin/marketplace.json`**
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

- [ ] **Step 2: Write `plugins/project-docs/.claude-plugin/plugin.json`**
```json
{
  "name": "project-docs",
  "description": "Scaffold and maintain a clear, consistent project documentation structure.",
  "version": "0.1.0",
  "author": { "name": "talasymov" }
}
```

- [ ] **Step 3: Write `LICENSE`** — standard MIT license text, `Copyright (c) 2026 talasymov`.

- [ ] **Step 4: Write `.gitignore`**
```
.DS_Store
*.log
.worktrees/
```

- [ ] **Step 5: Verify JSON validity**
Run:
```bash
cd ~/projects/claude-skills
python3 -m json.tool .claude-plugin/marketplace.json >/dev/null && echo "marketplace OK"
python3 -m json.tool plugins/project-docs/.claude-plugin/plugin.json >/dev/null && echo "plugin OK"
```
Expected: `marketplace OK` and `plugin OK`.

- [ ] **Step 6: Commit**
```bash
cd ~/projects/claude-skills
git add .claude-plugin plugins/project-docs/.claude-plugin LICENSE .gitignore
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "feat: marketplace + project-docs plugin manifests"
```

---

### Task 2: Doc templates (the structure the skill scaffolds)

**Files:**
- Create: `plugins/project-docs/skills/structure/templates/README.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/README.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/ROADMAP.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/TASKS.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/TECH_DEBT.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/BUGS.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/DECISIONS.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/PROGRESS.md`
- Create: `plugins/project-docs/skills/structure/templates/docs/handbook/README.md`

**Interfaces:**
- Produces: the `templates/` tree the `structure` skill copies. Root = `plugins/project-docs/skills/structure/templates/`. Placeholders: `{{PROJECT_NAME}}`, `{{ONE_LINER}}`, `{{DATE}}`.

- [ ] **Step 1: Write `templates/README.md`**
```markdown
# {{PROJECT_NAME}}

{{ONE_LINER}}

## Quickstart

<!-- How to install/run. Replace with real commands. -->

## Where to look

| I want to… | Go to |
|------------|-------|
| Understand the project | [docs/README.md](docs/README.md) |
| See the direction | [docs/ROADMAP.md](docs/ROADMAP.md) |
| Pick up open work | [docs/TASKS.md](docs/TASKS.md) |
| See known bugs | [docs/BUGS.md](docs/BUGS.md) |
| See tech debt | [docs/TECH_DEBT.md](docs/TECH_DEBT.md) |
| Understand a past decision | [docs/DECISIONS.md](docs/DECISIONS.md) |
| See what shipped | [docs/PROGRESS.md](docs/PROGRESS.md) |
```

- [ ] **Step 2: Write `templates/docs/README.md`**
```markdown
# Documentation

Map of everything under `docs/`. Repo entry point is the root [README](../README.md).

## Living trackers (change often)
- [ROADMAP.md](ROADMAP.md) — direction, milestones
- [TASKS.md](TASKS.md) — actionable open work
- [TECH_DEBT.md](TECH_DEBT.md) — structural debt
- [BUGS.md](BUGS.md) — known defects
- [DECISIONS.md](DECISIONS.md) — decisions + why
- [PROGRESS.md](PROGRESS.md) — done-log + lessons

## Reference (changes rarely)
- [handbook/](handbook/) — how the system works (the mental model)

## Task artifacts
- `superpowers/specs/` — design specs per task
- `superpowers/plans/` — implementation plans per task
```

- [ ] **Step 3: Write `templates/docs/ROADMAP.md`**
```markdown
# Roadmap

## Vision
{{ONE_LINER}}

## Current focus
<!-- What we're working toward right now. -->

## Milestones
- [ ] <milestone> — <success criteria>
```

- [ ] **Step 4: Write `templates/docs/TASKS.md`**
```markdown
# Tasks

Actionable open work. Check off when done and log the outcome in [PROGRESS.md](PROGRESS.md).
For direction/priorities see [ROADMAP.md](ROADMAP.md).

- [ ] <task> — <short description> (files: <path>)
```

- [ ] **Step 5: Write `templates/docs/TECH_DEBT.md`**
```markdown
# Tech debt

Structural weaknesses worth paying down. One bullet per item with a rationale and file pointer.

- <debt item> — <why it matters> (files: <path>)
```

- [ ] **Step 6: Write `templates/docs/BUGS.md`**
```markdown
# Known bugs

Open defects. Fixed items move to [PROGRESS.md](PROGRESS.md).
Format: one `###` per bug with Status / Symptom / Root cause / Files.

### <bug title>
- **Status**: open
- **Symptom**: <what goes wrong>
- **Root cause**: <if known>
- **Files**: <path>
```

- [ ] **Step 7: Write `templates/docs/DECISIONS.md`** (ships with one seed ADR as a format example)
```markdown
# Decisions log

Architecture/process decisions and the reasoning behind them. Newest first.
Add an entry whenever a choice would otherwise be re-litigated later.

## {{DATE}} — Adopt the project-docs structure
**Context:** The project needed a clear, consistent place for docs, tasks, debt, bugs, decisions, and progress.
**Decision:** Adopt the standard structure: root README front door → docs/ living trackers → docs/handbook reference → docs/superpowers task artifacts.
**Why:** One obvious home per kind of information; new contributors and agents know where to look and where to write.
**Consequences:** Maintain the trackers as living docs; record future decisions here.
```

- [ ] **Step 8: Write `templates/docs/PROGRESS.md`**
```markdown
# Progress

Done-log and lessons learned (backward-looking). For open work see [TASKS.md](TASKS.md).

## {{DATE}}
- Initialized the documentation structure.
```

- [ ] **Step 9: Write `templates/docs/handbook/README.md`**
```markdown
# Handbook

The stable reference for how this project works — the mental model, not the day-to-day trackers.
Changes rarely. Add numbered deep-dive docs (e.g. `01-overview.md`, `02-architecture.md`) as the
system grows, and list them here in reading order.

| # | Document | When to read |
|---|----------|--------------|
| — | (add docs here) | |
```

- [ ] **Step 10: Verify tree**
Run:
```bash
cd ~/projects/claude-skills
find plugins/project-docs/skills/structure/templates -type f | sort
```
Expected: 9 files — `README.md`, `docs/README.md`, `docs/{ROADMAP,TASKS,TECH_DEBT,BUGS,DECISIONS,PROGRESS}.md`, `docs/handbook/README.md`.

- [ ] **Step 11: Commit**
```bash
cd ~/projects/claude-skills
git add plugins/project-docs/skills/structure/templates
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "feat: generic doc-structure templates"
```

---

### Task 3: The `structure` skill (`SKILL.md`)

**Files:**
- Create: `plugins/project-docs/skills/structure/SKILL.md`

**Interfaces:**
- Consumes: `templates/` from Task 2 (referenced relatively as `templates/…` from the skill's own directory).
- Produces: the skill Claude loads. Frontmatter `name: structure` + `description`.

- [ ] **Step 1: Write `SKILL.md`** with this exact content:
````markdown
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
````

- [ ] **Step 2: Verify frontmatter parses**
Run:
```bash
cd ~/projects/claude-skills
head -4 plugins/project-docs/skills/structure/SKILL.md
awk 'NR==1&&$0=="---"{f=1} f&&/^description:/{d=1} END{exit !(d)}' plugins/project-docs/skills/structure/SKILL.md && echo "has description"
```
Expected: frontmatter block shown; `has description`.

- [ ] **Step 3: Commit**
```bash
cd ~/projects/claude-skills
git add plugins/project-docs/skills/structure/SKILL.md
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "feat: structure skill (scaffold + maintain)"
```

---

### Task 4: Repo README (marketplace front door)

**Files:**
- Create: `README.md` (repo root)

**Interfaces:**
- Produces: the human-facing entry point documenting install/update and contents.

- [ ] **Step 1: Write `README.md`**
```markdown
# claude-skills

A personal [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin **marketplace**.

## Plugins

### `project-docs`
Scaffold and maintain a clear project documentation structure — a root `README` front door,
`docs/` living trackers (ROADMAP, TASKS, TECH_DEBT, BUGS, DECISIONS, PROGRESS), a stable
`docs/handbook/` reference, and `docs/superpowers/` task artifacts.

Skill: `/project-docs:structure` (also auto-invoked when you ask to set up or actualize project docs).

## Install

```
/plugin marketplace add talasymov/claude-skills
/plugin install project-docs@claude-skills
```

Installs at user scope → available in every project on this machine.

## Update

```
/plugin marketplace update claude-skills
```

Picks up the latest published `version` of each plugin.

## For maintainers — releasing a change

1. Edit the plugin/skill/templates.
2. Bump `version` (semver) in `plugins/<plugin>/.claude-plugin/plugin.json`.
   - patch = wording/template fix · minor = new capability · major = structural change.
3. Commit and push. Users run `/plugin marketplace update claude-skills`.

## Layout

```
.claude-plugin/marketplace.json     # marketplace catalog
plugins/project-docs/               # the project-docs plugin
  .claude-plugin/plugin.json
  skills/structure/SKILL.md         # the skill
  skills/structure/templates/       # files scaffolded into target projects
docs/superpowers/                   # this repo's own spec + plan (dogfooding)
```
```

- [ ] **Step 2: Commit**
```bash
cd ~/projects/claude-skills
git add README.md
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "docs: repo README with install/update/release instructions"
```

---

### Task 5: Scaffold smoke test (templates render + idempotent + non-clobber)

**Files:** none (verification only; uses a temp dir)

**Interfaces:**
- Consumes: `templates/` (Task 2). Confirms the skill's core mechanic — copy templates, don't clobber — works on real files.

- [ ] **Step 1: Simulate a first-time scaffold into an empty dir**
Run:
```bash
T=$(mktemp -d)
SRC=~/projects/claude-skills/plugins/project-docs/skills/structure/templates
mkdir -p "$T/docs/handbook"
cp "$SRC/README.md" "$T/README.md"
cp -r "$SRC/docs/." "$T/docs/"
find "$T" -type f | sed "s#$T/##" | sort
```
Expected: `README.md`, `docs/README.md`, `docs/BUGS.md`, `docs/DECISIONS.md`, `docs/PROGRESS.md`, `docs/ROADMAP.md`, `docs/TASKS.md`, `docs/TECH_DEBT.md`, `docs/handbook/README.md`.

- [ ] **Step 2: Confirm placeholders are present (to be filled by the skill, not hard-coded values)**
Run:
```bash
grep -rl "{{PROJECT_NAME}}\|{{ONE_LINER}}\|{{DATE}}" "$T" | sed "s#$T/##" | sort
```
Expected: at least `README.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `docs/PROGRESS.md` appear (they contain placeholders).

- [ ] **Step 3: Confirm non-clobber logic is expressible — a pre-existing non-empty file is detectable**
Run:
```bash
printf 'existing content\n' > "$T/README.md"
# The skill's rule: skip copy if target exists and is non-empty.
test -s "$T/README.md" && echo "would KEEP existing README (non-empty) — correct"
rm -rf "$T"
```
Expected: `would KEEP existing README (non-empty) — correct`.

- [ ] **Step 4: No commit** (verification only; nothing changed in the repo).

---

### Task 6: Publish — create GitHub repo and push

**Files:** none (remote publish)

**Interfaces:**
- Consumes: all prior tasks committed on `main`.
- Produces: public `github.com/talasymov/claude-skills` with `main` pushed, enabling `/plugin marketplace add talasymov/claude-skills`.

- [ ] **Step 1: Confirm clean tree + full history**
Run:
```bash
cd ~/projects/claude-skills
git status -s || true
git log --oneline
```
Expected: clean working tree; commits for spec, plan, manifests, templates, skill, README present.

- [ ] **Step 2: Create the public repo and push**
Run:
```bash
cd ~/projects/claude-skills
gh repo create talasymov/claude-skills --public --source . --remote origin --push
```
Expected: repo created; `main` pushed; prints the repo URL.

- [ ] **Step 3: Verify remote contents**
Run:
```bash
cd ~/projects/claude-skills
gh repo view talasymov/claude-skills --json url,visibility,defaultBranchRef -q '.url, .visibility, .defaultBranchRef.name'
gh api repos/talasymov/claude-skills/contents/.claude-plugin/marketplace.json -q '.name' >/dev/null && echo "marketplace.json present on remote"
```
Expected: URL printed, `PUBLIC`, default branch `main`, and `marketplace.json present on remote`.

- [ ] **Step 4: No further commit.** Hand off to the user for the install smoke test (below).

---

## Post-implementation: user smoke test (manual, user-run)

These are interactive Claude Code commands the USER runs (Claude cannot run `/plugin`):
```
/plugin marketplace add talasymov/claude-skills
/plugin install project-docs@claude-skills
```
Then, in another project: ask "set up the project docs structure" (or run `/project-docs:structure`)
and confirm the tree is scaffolded. To test updates later: bump `version`, push, run
`/plugin marketplace update claude-skills`.

---

## Self-Review (completed during authoring)

- **Spec coverage:** distribution/marketplace (Task 1 + 6), plugin manifest (1), templates (2), skill scaffold+maintain (3), repo README with install/update/versioning (4), idempotent/non-clobber verification (5), publish (6), dogfooding (spec+plan already in `docs/superpowers/`). All spec sections mapped.
- **Placeholder scan:** template `{{…}}` tokens are intentional runtime placeholders, not plan placeholders; every file's exact content is given. No "TBD"/"implement later".
- **Consistency:** names are uniform everywhere — marketplace `claude-skills`, plugin `project-docs`, skill `structure`, paths `plugins/project-docs/skills/structure/…`, install `project-docs@claude-skills`, invocation `/project-docs:structure`. `source` is the relative string `./plugins/project-docs` in both spec and Task 1.
