# Roadmap

## Vision
A personal Claude Code marketplace of reusable skills. The first plugin, `project-docs`, lets
any project adopt one clear documentation structure (README front door → docs/ trackers →
handbook → superpowers artifacts) and keep it current — with the recipe updated centrally so
every project uses the latest version.

## Current focus
`project-docs` is stable at **v0.2.0** (scaffold skill + 5 commands + Stop-hook). Next work is
polish and the end-to-end install/update smoke test; then optional new capabilities.

## Milestones
- ✅ v0.1.0 — marketplace + `project-docs` plugin + `structure` skill + 9 templates
- ✅ v0.2.0 — commands (`work/sync/status/capture/decide`) + non-blocking doc-update Stop-hook
- ⬜ v0.2.x — polish from real use (see [TASKS.md](TASKS.md)); verified install/update smoke test
- ⬜ future — opt-out/throttle for the reminder hook; more commands; possibly more plugins

## Ideas parking lot (not committed)
- Opt-out / throttle for the Stop-hook reminder (env var or repo marker file).
- `archive` command to move resolved bugs/old progress into an archive section.
- `handbook-add` command to create a numbered handbook doc + register it in the reading table.
- Localize templates / support non-English section headings.
- Additional plugins in this marketplace beyond `project-docs`.
