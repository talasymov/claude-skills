# `project-docs` — Commands + Doc-Update Hook — Design

**Date:** 2026-07-01
**Status:** Approved
**Repo:** `talasymov/claude-skills` (existing), plugin `project-docs`

## Problem

The `project-docs` plugin (v0.1.0) scaffolds and describes the doc structure, but nothing
makes Claude Code (a) *drive* work from the trackers, or (b) reliably *update* the docs after
work is done. The user wants: after doing work on a project, the docs get updated; a
"start work" command that picks an open task, runs the superpowers chain, and updates docs on
success; plus other useful commands for this structure.

## Goal

Extend the `project-docs` plugin with slash commands and a gentle Stop-hook reminder so that,
in any project using this structure, Claude can start task-driven work and keep the trackers
current — distributed and updated through the same marketplace.

## Non-Goals

- The hook does NOT auto-edit docs (user chose a reminder, not automatic edits).
- No new tracker files or structural changes to the doc layout (that's v0.1.0's job).
- Commands do not replace the superpowers skills — `work` *invokes* them.

## Decisions (from brainstorming)

- Doc-update mechanism: **commands + Stop-hook reminder**.
- `work` command: **pick task + confirm** before running, then run the superpowers chain, then
  update docs on success.
- Extra commands: **`sync`, `status`, `capture`, `decide`** (plus `work`).

## Components

### 1. Slash commands — `plugins/project-docs/commands/*.md`
Each is a Markdown command file with YAML frontmatter (`description`, optional
`argument-hint`, `allowed-tools`) and a prompt body. Invoked as `/project-docs:<name>`.
`$ARGUMENTS` carries user input. All commands are safe: never overwrite unrelated content,
never delete without `git mv` + provenance, keep the routing rules from the `structure` skill.

| Command | Argument | What it does |
|---------|----------|--------------|
| `work` | optional task selector | Read `docs/TASKS.md`; propose the next open task (or the one named in `$ARGUMENTS`); **confirm with the user**; then run the superpowers chain (brainstorming → writing-plans → subagent-driven-development or executing-plans, scaled to the task); on success update docs: check the task off in `TASKS.md`, append a `PROGRESS.md` entry, add a `DECISIONS.md` ADR if a real decision was made, and file any newly-found bug/debt into `BUGS.md`/`TECH_DEBT.md`. |
| `sync` | none | The "after ad-hoc work, update docs" action. Inspect `git log`/`git diff` since the last docs-touching commit; update `PROGRESS/TASKS/BUGS/TECH_DEBT/DECISIONS/ROADMAP` per the routing rules; move resolved bugs to `PROGRESS`; refresh `README`/`docs/README` links if files changed. Summarize what was updated; make no change if nothing is warranted. |
| `status` | none | Read-only dashboard: counts of open items in `TASKS/BUGS/TECH_DEBT`, current `ROADMAP` focus, and the last 3–5 `PROGRESS` entries. Prints a compact summary; edits nothing. |
| `capture` | the note text | Classify `$ARGUMENTS` into exactly one tracker (task→TASKS, bug→BUGS, debt→TECH_DEBT, decision→DECISIONS) and append it in that file's format. State where it went. |
| `decide` | the decision text | Append an ADR entry to `docs/DECISIONS.md`: `## <today> — <title>` + **Context/Decision/Why/Consequences**, drafted from `$ARGUMENTS` (ask at most one clarifying question if the "why" is missing). |

Commands that need the current date derive it from the environment (e.g. `date +%F` via the
allowed Bash tool), never hard-coded.

Every command first checks the project actually has the structure (`docs/` with trackers). If
not, it suggests running the `structure` skill (scaffold) instead of failing.

### 2. Stop-hook reminder — `plugins/project-docs/hooks/`
- `hooks/hooks.json` registers a **Stop** hook running a bundled script
  `hooks/remind-sync.sh` via `${CLAUDE_PLUGIN_ROOT}`.
- The script is **non-blocking** and **quiet by default**. It emits a reminder ONLY when ALL:
  1. `docs/TASKS.md` exists (project uses this structure), AND
  2. `git rev-parse` succeeds (inside a git repo), AND
  3. `git status --porcelain` shows uncommitted changes to paths **outside `docs/`** (real
     work not yet reflected in docs).
- When those hold, it surfaces a short reminder: work was done — consider `/project-docs:sync`
  to update the trackers. It NEVER blocks the stop and NEVER edits files.
- Exact non-blocking output contract (JSON shape / exit code / field that shows a message
  without forcing continuation) is **verified against current Claude Code hook docs during
  planning**; the script degrades to a no-op (exit 0, no output) on anything unexpected.

### 3. Guidance + release
- `structure` skill (`SKILL.md`): add to Workflow B an explicit closing step — "after finishing
  a piece of work, update the trackers (or run `/project-docs:sync`)" — and a one-line list of
  the new commands so the skill stays the knowledge base.
- Repo `README.md`: add a "Commands" section (the table above) and a short "Doc-update reminder
  hook" note.
- `plugin.json`: bump `version` `0.1.0` → `0.2.0` (minor — new capability).
- Commit + push; users pick it up via `/plugin marketplace update claude-skills`.

## Architecture / boundaries
- Commands are independent prompt files — each does one thing, readable in isolation.
- The hook is one tiny shell script + registration JSON; its only job is the guarded reminder.
- The `structure` skill remains the single source of the routing rules; commands reference
  those rules rather than re-defining them, to stay DRY.

## Verification
1. Each command file has valid frontmatter (`description`) and a body; `/project-docs:<name>`
   resolves for `work`, `sync`, `status`, `capture`, `decide`.
2. `hooks/hooks.json` is valid JSON registering a Stop hook; `remind-sync.sh` is executable and:
   - prints nothing / exits 0 when `docs/TASKS.md` is absent;
   - prints nothing when the tree is clean or only `docs/` changed;
   - prints the reminder when there are non-doc uncommitted changes and `docs/TASKS.md` exists.
   Tested with a temp git repo fixture.
3. `plugin.json` version is `0.2.0`; all JSON valid (`python3 -m json.tool`).
4. `SKILL.md` and repo `README.md` document the commands + hook.
5. Pushed to `talasymov/claude-skills`; user smoke test: `/plugin marketplace update`, then
   `/project-docs:status` and `/project-docs:work` in a structured project.

## Risks
- **Hook output contract** varies by Claude Code version → verified in planning; script is
  fail-safe (no-op on the unexpected) so a wrong guess degrades to silence, never breakage.
- **Hook noise** across unrelated projects → mitigated by the three-part guard (structure
  present + git repo + non-doc changes).
- **`work` autonomy** → mitigated by the confirm-before-run gate; the chain still uses the
  superpowers review checkpoints.
- **Install/update is user-run** (`/plugin …`) → documented; final smoke test by the user.
