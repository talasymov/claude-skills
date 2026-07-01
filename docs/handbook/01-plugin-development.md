# Plugin development guide

How the `claude-skills` marketplace + `project-docs` plugin are built, released, and tested.
This is the durable "how it works" reference. Day-to-day state lives in the `docs/` trackers.

## Mental model

- **Marketplace** = this git repo. `.claude-plugin/marketplace.json` catalogs plugins.
- **Plugin** = `plugins/project-docs/`, declared by `.claude-plugin/plugin.json`.
- A plugin bundles **skills** (`skills/`), **commands** (`commands/`), and **hooks** (`hooks/`).
- Users add the marketplace once and install the plugin at **user scope**, so it works in
  every project; `/plugin marketplace update` pulls new versions.

## File formats (verified against Claude Code docs, 2026-07)

### marketplace.json (`.claude-plugin/marketplace.json`)
```json
{
  "name": "claude-skills",
  "owner": { "name": "talasymov" },
  "plugins": [
    { "name": "project-docs", "source": "./plugins/project-docs", "description": "…" }
  ]
}
```
- `source` for a plugin **in this same repo** is a relative-path STRING. The object form
  (`{"source":"git-subdir",…}`) is only for plugins in *external* repos.
- Relative `source` resolves only when the marketplace is added via git (GitHub/GitLab/git URL),
  not via a raw `marketplace.json` URL.

### plugin.json (`plugins/project-docs/.claude-plugin/plugin.json`)
```json
{ "name": "project-docs", "description": "…", "version": "0.2.0", "author": { "name": "talasymov" } }
```
- `version` (semver) is how `/plugin marketplace update` decides an update exists. Bump it on
  every meaningful change. (Omit it and updates trigger on every commit SHA — noisier.)

### Skill (`plugins/project-docs/skills/structure/SKILL.md`)
- Frontmatter: `description` required; `name` optional (defaults to the folder → `structure`).
- Invoked `/project-docs:structure`; mostly auto-invoked when the `description` matches intent.
- References its bundled `templates/` by relative path from the skill dir.

### Commands (`plugins/project-docs/commands/<name>.md`)
- Live at plugin root under `commands/` — **not** under `.claude-plugin/`.
- Invoked `/project-docs:<name>`. Frontmatter: `description` (+ optional `argument-hint`).
- Body is a prompt. `$ARGUMENTS` = everything after the command name. The body tells Claude
  what to do; Claude uses its normal tools (Bash/Read/Edit). Don't rely on `!bash`/`@file`
  preprocessing — call the Bash/Read tools explicitly (e.g. `date +%F` for dates).
- The five commands: `work` (pick+confirm task → superpowers chain → update docs),
  `sync` (update trackers from git changes), `status` (read-only dashboard),
  `capture <note>` (file into the right tracker), `decide <text>` (ADR into DECISIONS.md).

### Hooks (`plugins/project-docs/hooks/`)
- `hooks/hooks.json` registers hooks; auto-active when the plugin is enabled (user scope → all
  projects). Reference the script with `${CLAUDE_PLUGIN_ROOT}`:
```json
{ "hooks": { "Stop": [ { "type": "command", "command": "\"${CLAUDE_PLUGIN_ROOT}\"/hooks/remind-sync.sh" } ] } }
```
- **Stop hook contract** — non-blocking reminder: `exit 0` and print
  `{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"…"}}`.
  NEVER print `decision:"block"` — that forces the turn to continue and can loop.
- `remind-sync.sh` is deliberately **fail-safe**: drains stdin, and is a silent no-op (exit 0,
  no output) unless ALL hold: `docs/TASKS.md` exists, inside a git repo, and there are
  uncommitted changes **outside** `docs/`. It never edits files and never blocks.

## Release process

1. Edit plugin files. 2. Bump `plugin.json` `version`. 3. Update `docs/` trackers.
4. `git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "…"` and
   `git push origin main`. 5. Users run `/plugin marketplace update claude-skills`.

## Testing

- **JSON**: `python3 -m json.tool <file>` on marketplace.json / plugin.json / hooks.json.
- **Hook fixture test** (no Claude needed) — the canonical 4-case check:
```bash
H="$PWD/plugins/project-docs/hooks/remind-sync.sh"
T=$(mktemp -d); ( cd "$T" && git init -q && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init )
CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null                 # A: no docs/TASKS.md → empty
mkdir -p "$T/docs"; echo x > "$T/docs/TASKS.md"
CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null                 # B: docs-only change → empty
echo code > "$T/main.py"
CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null                 # C: non-doc change → reminder JSON
( cd "$T" && git add -A && git -c user.name=t -c user.email=t@t commit -q -m all )
CLAUDE_PROJECT_DIR="$T" bash "$H" </dev/null                 # D: clean → empty
rm -rf "$T"
```
- **Commands**: prompt files — validated by frontmatter presence + a manual smoke test
  (`/project-docs:status`, `/project-docs:work`) after installing. There is no automated
  behavioral test harness for commands (see `docs/TECH_DEBT.md`).

## User-run commands (Claude can't run these)

```
/plugin marketplace add talasymov/claude-skills
/plugin install project-docs@claude-skills
/plugin marketplace update claude-skills
```

## Gotchas

- Put `commands/`, `skills/`, `hooks/` at the plugin ROOT, never inside `.claude-plugin/`
  (only `plugin.json` goes there).
- The Stop hook fires on every stop; the reminder re-appears until you commit non-doc work.
  That's intended (gentle nudge) and non-blocking. A future opt-out toggle is a tracked idea.
- Forgetting to bump `version` means users won't be offered the update.
