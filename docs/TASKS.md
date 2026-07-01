# Tasks

Actionable open work. Check off when done and log the outcome in [PROGRESS.md](PROGRESS.md).
For direction/priorities see [ROADMAP.md](ROADMAP.md).

- [ ] End-to-end smoke test (user-run): `/plugin marketplace update claude-skills`, then
      `/project-docs:status` and `/project-docs:work` in a real structured project; confirm the
      Stop-hook reminder shows after non-doc edits. (Claude can't run `/plugin`.)
- [ ] Decide on an opt-out / throttle for the Stop-hook reminder (env var or repo marker file)
      so it isn't repeated every stop during long editing sessions.
      (files: `plugins/project-docs/hooks/remind-sync.sh`)
- [ ] Consider a lightweight behavioral check for commands (e.g. lint that each `commands/*.md`
      has valid frontmatter + guards on the right tracker). See [TECH_DEBT.md](TECH_DEBT.md).
- [ ] Optional: `archive` command (move resolved bugs / stale progress into an archive section).
- [ ] Optional: `handbook-add` command (scaffold a numbered handbook doc + register it in the table).

## Idea backlog (from discussion, not scheduled)
- Localize templates / non-English headings.
- Add more plugins to the `claude-skills` marketplace over time.
