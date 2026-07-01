# Decisions log

Architecture/process decisions and the reasoning behind them. Newest first.

## 2026-07-01 — `decide` command guards on DECISIONS.md, others on TASKS.md
**Context:** Every command checks the project uses this structure before acting; the natural
guard is `docs/TASKS.md`. `decide` only ever writes `docs/DECISIONS.md`.
**Decision:** `decide` guards on `docs/DECISIONS.md`; the other four guard on `docs/TASKS.md`.
**Why:** A command should check the file it actually needs; both files coexist in a scaffolded
structure, so it's functionally equivalent and slightly more correct.
**Consequences:** Minor intentional inconsistency (noted in `docs/TECH_DEBT.md` and flagged by
the final review as acceptable).

## 2026-07-01 — Doc-update = commands + non-blocking Stop-hook reminder (not auto-edit)
**Context:** The user wants docs kept current after work, reliably.
**Decision:** Explicit commands (`work`, `sync`) do the updates; a Stop-hook only *reminds*
(non-blocking, `additionalContext`), never edits files.
**Why:** Auto-editing docs on every stop is risky and surprising; a nudge + explicit commands
keeps the human in control while still being reliable.
**Consequences:** The reminder re-appears each stop until non-doc work is committed (intended).
A future opt-out/throttle is a tracked idea.

## 2026-07-01 — `work` command: pick + confirm, then superpowers chain, then update docs
**Context:** A "start work" command could run fully autonomously or with a checkpoint.
**Decision:** Read `TASKS.md`, propose the next open task (or the one named in `$ARGUMENTS`),
**wait for user confirmation**, then run the superpowers chain (brainstorm→plan→execute→verify),
then update docs on success.
**Why:** A confirm gate prevents the agent running off on the wrong task; the chain keeps quality.
**Consequences:** Not one-shot autonomous; that was the accepted trade-off.

## 2026-07-01 — Naming: marketplace `claude-skills` / plugin `project-docs` / skill `structure`
**Context:** Initial plan used plugin `docs-structure` + skill `docs-structure` → ugly
invocation `/docs-structure:docs-structure`.
**Decision:** Marketplace `claude-skills` (collection), plugin `project-docs` (namespace),
skill `structure` (action) → `/project-docs:structure`.
**Why:** Mirrors `superpowers:brainstorming` (collection : action); no doubled name.
**Consequences:** Install ref is `project-docs@claude-skills`.

## 2026-07-01 — Distribute as a git marketplace plugin (updatable, user scope)
**Context:** Need a way for many projects to share ONE updatable doc-structure recipe.
**Decision:** A GitHub repo that is a Claude Code marketplace; install the plugin at user scope;
update via `/plugin marketplace update`.
**Why:** Native, versioned, single source of truth. Beats copy-paste, git submodule (per-repo
sync), or a hand-cloned `~/.claude/skills` dir (no versioning/catalog).
**Consequences:** Updates require bumping `plugin.json` version + push; install/update are
user-run interactive `/plugin` commands.

## 2026-07-01 — Keep code-referenced data out of `docs/` (learned in gathering_info)
**Context:** In the origin project, `.planning/` held both GSD docs AND code-referenced data
(url_catalogs, audits). Deleting it blindly broke code.
**Decision:** Generated/consumed data belongs under `data/`, not `docs/`; docs are docs only.
**Why:** `docs/` should be safe to restructure without breaking code paths.
**Consequences:** The `structure` skill scaffolds docs only and never invents data dirs.
