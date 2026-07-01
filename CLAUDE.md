# CLAUDE.md

Guidance for Claude Code working in this repo. Read this first, then `docs/README.md`.

## What this repo is

`talasymov/claude-skills` is a **Claude Code plugin marketplace** (a git repo with
`.claude-plugin/marketplace.json` at root). It currently ships one plugin, **`project-docs`**,
whose **`structure`** skill scaffolds and maintains a standard project-documentation layout,
plus five commands and a Stop-hook. Distributed and updated through Claude Code's native
`/plugin` system so every project on a machine uses the latest version.

Current release: **v0.2.0** (see `docs/PROGRESS.md`).

## Layout

```
.claude-plugin/marketplace.json          # marketplace catalog (lists project-docs)
plugins/project-docs/
  .claude-plugin/plugin.json             # name/description/version (semver)
  skills/structure/SKILL.md              # the scaffold+maintain skill
  skills/structure/templates/            # 9 generic doc files copied into target projects
  commands/                              # /project-docs:{work,sync,status,capture,decide}
  hooks/hooks.json + remind-sync.sh      # non-blocking Stop-hook reminder
docs/                                    # this repo's OWN docs (dogfooding the structure)
  README.md ROADMAP.md TASKS.md TECH_DEBT.md BUGS.md DECISIONS.md PROGRESS.md
  handbook/                              # how to develop this plugin
  superpowers/{specs,plans}/            # design specs + implementation plans per feature
```

## How to develop & release (the whole loop)

1. Edit the plugin (skill, templates, commands, hook).
2. **Bump `version`** in `plugins/project-docs/.claude-plugin/plugin.json` (semver):
   patch = wording/template fix · minor = new capability · major = layout change.
3. Update `docs/` trackers (this repo dogfoods its own structure): log in `PROGRESS.md`,
   check off `TASKS.md`, record choices in `DECISIONS.md`.
4. Commit and `git push origin main`. Users pick it up with `/plugin marketplace update claude-skills`.

Commit identity (repo has none configured):
`git -c user.name=talasymov -c user.email=tmsweane@gmail.com commit -m "…"`

## Verified technical facts (don't re-derive — confirmed against Claude Code docs 2026-07)

- **Marketplace entry**: co-located plugin `source` is the relative STRING `"./plugins/project-docs"` (NOT an object). Top-level needs `name`, `owner{name}`, `plugins[]`.
- **plugin.json**: `name` required; `version` (semver) drives `/plugin marketplace update` detection. Omitting version = update on every commit SHA.
- **Skill**: `skills/<name>/SKILL.md`, frontmatter needs `description` (`name` optional, defaults to dir). Invoked `/project-docs:<skill>`; primarily model-invoked by `description`.
- **Commands**: `commands/<name>.md` at plugin root (NOT under `.claude-plugin/`) → `/project-docs:<name>`. Frontmatter `description` (+ optional `argument-hint`). Body is a PROMPT; use `$ARGUMENTS` for input; instruct Claude to use its Bash/Read/Edit tools (don't rely on `!`/`@` preprocessing). Get dates via `date +%F`.
- **Hooks**: `hooks/hooks.json` at plugin root, auto-active when the plugin is enabled (user scope → all projects). Reference scripts via `${CLAUDE_PLUGIN_ROOT}`. Each event array holds *matcher-group* objects with a nested **`hooks` array**: `{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"…"}]}]}}`. Stop takes no `matcher`. (Putting `{type,command}` directly under `Stop[0]` fails to load — caught only by `/doctor`; fixed in v0.2.1.)
- **Non-blocking Stop reminder**: `exit 0` + stdout `{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"…"}}`. NEVER emit `decision:"block"` (that loops). `remind-sync.sh` is fail-safe: silent no-op (exit 0) on any unexpected condition; fires only when `docs/TASKS.md` exists AND git repo AND uncommitted changes outside `docs/`.

Full detail + how to test the hook: `docs/handbook/01-plugin-development.md`.

## Constraints

- `/plugin …` commands are user-run (interactive) — Claude cannot execute install/update; document them, ask the user to run them.
- Keep templates GENERIC (no project-specific dirs).
- Never overwrite non-empty files / never delete without `git mv` + provenance / never fabricate progress.

## Where to look

| Want | File |
|------|------|
| Doc map | `docs/README.md` |
| Direction + future ideas | `docs/ROADMAP.md` |
| Open work | `docs/TASKS.md` |
| Decisions + why | `docs/DECISIONS.md` |
| What shipped | `docs/PROGRESS.md` |
| How the plugin works / release / test | `docs/handbook/01-plugin-development.md` |
| Design specs + plans | `docs/superpowers/` |
