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
