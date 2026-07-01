# `project-docs` Commands + Doc-Update Hook — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add five slash commands (`work`, `sync`, `status`, `capture`, `decide`) and a non-blocking Stop-hook reminder to the `project-docs` plugin, then release v0.2.0 via the marketplace.

**Architecture:** Commands are Markdown prompt files under `plugins/project-docs/commands/` (invoked `/project-docs:<name>`). The hook is a `hooks/hooks.json` registration plus a fail-safe shell script that nudges the user to sync docs when there is uncommitted non-doc work in a structured project. The `structure` skill and repo README are updated to document the new surface; `plugin.json` version is bumped.

**Tech Stack:** Markdown, JSON, POSIX shell, git. Verification = JSON validity + a shell fixture test for the hook. No compiled code, no pytest.

## Global Constraints

- Repo `~/projects/claude-skills`, branch `main`. Commit with `-c user.name=talasymov -c user.email=tmsweane@gmail.com`. `cd ~/projects/claude-skills` at the start of each shell command (cwd resets).
- Plugin dir root is `plugins/project-docs/`. Commands go in `plugins/project-docs/commands/` (NOT under `.claude-plugin/`). Hook files go in `plugins/project-docs/hooks/`.
- Command file frontmatter: `description` (required); `argument-hint` allowed for commands taking input. Command bodies are PROMPTS — they instruct Claude to use its Bash/Read/Edit tools; do not rely on `!`/`@` preprocessing. Get dates via the Bash tool `date +%F`, never hard-coded.
- Invocation names: `/project-docs:work|sync|status|capture|decide`.
- Stop-hook non-blocking reminder contract: exit 0 with `{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"…"}}`; NEVER emit `decision:"block"` (no loop). On any unexpected condition the script is a silent no-op (exit 0, no stdout).
- All JSON must pass `python3 -m json.tool`.
- Routing rules (single source = the `structure` skill): task→TASKS, bug→BUGS, debt→TECH_DEBT, decision→DECISIONS, shipped/lesson→PROGRESS, direction→ROADMAP. Never overwrite unrelated content; never delete without `git mv` + provenance; never fabricate progress.
- `plugin.json` version bump `0.1.0` → `0.2.0`.

---

### Task 1: Five slash commands

**Files:**
- Create: `plugins/project-docs/commands/work.md`
- Create: `plugins/project-docs/commands/sync.md`
- Create: `plugins/project-docs/commands/status.md`
- Create: `plugins/project-docs/commands/capture.md`
- Create: `plugins/project-docs/commands/decide.md`

**Interfaces:**
- Produces: the `/project-docs:*` command surface. Each references the routing rules and the `structure` skill; none redefines the doc layout.

- [ ] **Step 1: Write `commands/work.md`**
```markdown
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
```

- [ ] **Step 2: Write `commands/sync.md`**
```markdown
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
```

- [ ] **Step 3: Write `commands/status.md`**
```markdown
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
```

- [ ] **Step 4: Write `commands/capture.md`**
```markdown
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
```

- [ ] **Step 5: Write `commands/decide.md`**
```markdown
---
description: Record a decision as an ADR entry in docs/DECISIONS.md.
argument-hint: <the decision, ideally with the why>
---
Record "$ARGUMENTS" as an ADR in `docs/DECISIONS.md`.

1. If `docs/DECISIONS.md` is absent, suggest the `project-docs:structure` skill and stop.
2. Get today's date via the Bash tool: `date +%F`.
3. Draft an entry and add it under the header (newest first):
   ```
   ## <YYYY-MM-DD> — <short title>
   **Context:** <situation>
   **Decision:** <what was decided>
   **Why:** <rationale>
   **Consequences:** <trade-offs / follow-ups>
   ```
   Base it on "$ARGUMENTS". If the "Why" is missing, ask one short question before writing.
4. Confirm the title and date you recorded.
```

- [ ] **Step 6: Verify command files**
Run:
```bash
cd ~/projects/claude-skills
ls commands 2>/dev/null; ls plugins/project-docs/commands
for f in work sync status capture decide; do
  p="plugins/project-docs/commands/$f.md"
  head -1 "$p" | grep -qx -- '---' && grep -q '^description:' "$p" && echo "$f OK" || echo "$f BAD"
done
```
Expected: five `OK` lines; each file starts with `---` and has a `description:`.

- [ ] **Step 7: Commit**
```bash
cd ~/projects/claude-skills
git add plugins/project-docs/commands
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "feat(project-docs): work/sync/status/capture/decide commands"
```

---

### Task 2: Stop-hook reminder + fixture test

**Files:**
- Create: `plugins/project-docs/hooks/hooks.json`
- Create: `plugins/project-docs/hooks/remind-sync.sh` (executable)

**Interfaces:**
- Produces: an auto-active Stop hook that emits a non-blocking `additionalContext` reminder only when `docs/TASKS.md` exists AND the repo has uncommitted changes outside `docs/`.

- [ ] **Step 1: Write `plugins/project-docs/hooks/hooks.json`**
```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "\"${CLAUDE_PLUGIN_ROOT}\"/hooks/remind-sync.sh"
      }
    ]
  }
}
```

- [ ] **Step 2: Write `plugins/project-docs/hooks/remind-sync.sh`**
```bash
#!/usr/bin/env bash
# project-docs Stop hook: non-blocking reminder to sync docs after work.
# Fires ONLY when the project uses this structure (docs/TASKS.md exists),
# is a git repo, and has uncommitted changes OUTSIDE docs/.
# Fail-safe: any unexpected condition => silent no-op (exit 0, no output).
# NEVER blocks the stop (no decision:block) => no loop risk.
set -u
cat >/dev/null 2>&1 || true   # drain the hook payload on stdin; unused

dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$dir" 2>/dev/null || exit 0

[ -f docs/TASKS.md ] || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Any changed path outside docs/ ?  (strip the 2-char status + space, then filter)
if git status --porcelain 2>/dev/null | sed 's/^...//' | grep -q -v '^docs/'; then
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes outside docs/. If you finished a piece of work, update the trackers — run /project-docs:sync (or edit docs/PROGRESS.md, TASKS.md, etc.)."}}'
fi
exit 0
```

- [ ] **Step 3: Make the script executable + validate hooks.json**
Run:
```bash
cd ~/projects/claude-skills
chmod +x plugins/project-docs/hooks/remind-sync.sh
python3 -m json.tool plugins/project-docs/hooks/hooks.json >/dev/null && echo "hooks.json OK"
```
Expected: `hooks.json OK`.

- [ ] **Step 4: Fixture test — the four cases**
Run:
```bash
cd ~/projects/claude-skills
H="$PWD/plugins/project-docs/hooks/remind-sync.sh"
T=$(mktemp -d); ( cd "$T" && git init -q && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init )
# Case A: no docs/TASKS.md -> no output
A=$(CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null); echo "A empty? [${A}]"
# Case B: structure + only docs change -> no output
mkdir -p "$T/docs"; echo x > "$T/docs/TASKS.md"; echo y > "$T/docs/PROGRESS.md"
B=$(CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null); echo "B empty? [${B}]"
# Case C: structure + non-doc change -> reminder JSON
echo "code" > "$T/main.py"
C=$(CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null); echo "C: $C"
# Case D: clean tree (commit all) -> no output
( cd "$T" && git add -A && git -c user.name=t -c user.email=t@t commit -q -m all )
D=$(CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null); echo "D empty? [${D}]"
rm -rf "$T"
```
Expected: A empty; B empty; C prints JSON containing `additionalContext` and `/project-docs:sync`; D empty.

- [ ] **Step 5: Confirm C is valid JSON**
Run:
```bash
cd ~/projects/claude-skills
T=$(mktemp -d); ( cd "$T" && git init -q ); mkdir -p "$T/docs"; echo x > "$T/docs/TASKS.md"; echo c > "$T/main.py"
CLAUDE_PROJECT_DIR="$T" bash "$PWD/plugins/project-docs/hooks/remind-sync.sh" </dev/null | python3 -m json.tool >/dev/null && echo "reminder is valid JSON"
rm -rf "$T"
```
Expected: `reminder is valid JSON`.

- [ ] **Step 6: Commit**
```bash
cd ~/projects/claude-skills
git add plugins/project-docs/hooks
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "feat(project-docs): non-blocking Stop-hook reminder to sync docs"
```

---

### Task 3: Document the surface + bump version

**Files:**
- Modify: `plugins/project-docs/skills/structure/SKILL.md`
- Modify: `README.md`
- Modify: `plugins/project-docs/.claude-plugin/plugin.json`

**Interfaces:**
- Consumes: commands (Task 1) + hook (Task 2).
- Produces: the released, documented v0.2.0.

- [ ] **Step 1: Extend `SKILL.md`** — after the "Workflow B — Maintain (routing rules)" section's routing table and its "Also:" line, and before "## Safety rules", insert:
```markdown
### After finishing a piece of work

Update the trackers so they reflect reality: check off completed items in `TASKS.md`,
append to `PROGRESS.md`, record decisions in `DECISIONS.md`, file new bugs/debt. Or run
`/project-docs:sync` to do this from the git history.

## Commands (this plugin)

- `/project-docs:work [task]` — start the next open task, run the superpowers chain, update docs on success
- `/project-docs:sync` — update trackers from recent git changes
- `/project-docs:status` — read-only status dashboard
- `/project-docs:capture <note>` — file a note into the right tracker
- `/project-docs:decide <decision>` — record an ADR in `DECISIONS.md`
```

- [ ] **Step 2: Extend repo `README.md`** — after the `### project-docs` section, add:
```markdown
### Commands

| Command | What it does |
|---------|--------------|
| `/project-docs:work [task]` | Pick the next open task from `docs/TASKS.md`, confirm, run the superpowers chain, then update the docs on success |
| `/project-docs:sync` | Update the trackers to reflect recent git changes |
| `/project-docs:status` | Read-only status dashboard (open tasks/bugs/debt, roadmap focus, recent progress) |
| `/project-docs:capture <note>` | File a note into the right tracker (task/bug/debt/decision) |
| `/project-docs:decide <decision>` | Record an ADR entry in `docs/DECISIONS.md` |

### Doc-update reminder (hook)

The plugin ships a non-blocking **Stop** hook: when a project uses this structure
(`docs/TASKS.md` present) and has uncommitted changes outside `docs/`, it reminds you to
run `/project-docs:sync`. It never edits files and never blocks.
```

- [ ] **Step 3: Bump version in `plugin.json`** — change `"version": "0.1.0"` to `"version": "0.2.0"`.

- [ ] **Step 4: Verify**
Run:
```bash
cd ~/projects/claude-skills
python3 -c "import json;print('version',json.load(open('plugins/project-docs/.claude-plugin/plugin.json'))['version'])"
grep -q "project-docs:sync" plugins/project-docs/skills/structure/SKILL.md && echo "SKILL updated"
grep -q "### Commands" README.md && grep -q "Doc-update reminder" README.md && echo "README updated"
```
Expected: `version 0.2.0`, `SKILL updated`, `README updated`.

- [ ] **Step 5: Commit**
```bash
cd ~/projects/claude-skills
git add plugins/project-docs/skills/structure/SKILL.md README.md plugins/project-docs/.claude-plugin/plugin.json
git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "docs+chore(project-docs): document commands+hook, bump to v0.2.0"
```

---

### Task 4: Publish v0.2.0

**Files:** none (push + remote verify)

**Interfaces:**
- Consumes: all prior tasks committed on `main`.

- [ ] **Step 1: Confirm clean tree + history**
Run:
```bash
cd ~/projects/claude-skills
git status -s
git log --oneline -8
```
Expected: clean tree; commits for commands, hook, docs+version present.

- [ ] **Step 2: Push**
Run:
```bash
cd ~/projects/claude-skills
git push origin main
```
Expected: push succeeds.

- [ ] **Step 3: Verify remote has the new surface**
Run:
```bash
cd ~/projects/claude-skills
gh api repos/talasymov/claude-skills/contents/plugins/project-docs/commands -q '.[].name'
gh api repos/talasymov/claude-skills/contents/plugins/project-docs/hooks/hooks.json -q '.name' >/dev/null && echo "hooks.json on remote"
gh api repos/talasymov/claude-skills/contents/plugins/project-docs/.claude-plugin/plugin.json -q '.content' | base64 -d | python3 -c "import sys,json;print('remote version',json.load(sys.stdin)['version'])"
```
Expected: five command file names; `hooks.json on remote`; `remote version 0.2.0`.

- [ ] **Step 4: No commit.** Hand off to the user for the update smoke test:
`/plugin marketplace update claude-skills`, then `/project-docs:status` and `/project-docs:work` in a structured project.

---

## Self-Review (completed during authoring)

- **Spec coverage:** commands work/sync/status/capture/decide (Task 1); Stop-hook reminder with 3-part guard + fail-safe + non-blocking contract (Task 2); SKILL.md guidance + README commands/hook sections + version bump (Task 3); publish/verify (Task 4). All spec components mapped.
- **Placeholder scan:** command bodies contain `$ARGUMENTS` and `<...>` author-fill markers that are intentional prompt tokens, not plan gaps; every file's full content is given. No "TBD".
- **Consistency:** invocation names `/project-docs:{work,sync,status,capture,decide}` identical across command files, SKILL.md, README, and verification greps. Hook output uses exactly the verified `hookSpecificOutput.additionalContext` shape; version `0.2.0` in bump + remote check.
- **Verified contracts:** command dir `commands/` and `$ARGUMENTS`, hook `hooks/hooks.json` + `${CLAUDE_PLUGIN_ROOT}`, non-blocking `exit 0 + additionalContext` — all confirmed against current Claude Code docs before authoring.
