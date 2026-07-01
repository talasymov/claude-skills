# Tech debt

Structural weaknesses worth paying down. One bullet per item.

- No automated behavioral test for the five commands — they're prompt files, validated only by
  frontmatter checks + manual smoke test. Only the hook has a fixture test.
  (files: `plugins/project-docs/commands/*.md`)
- Guard inconsistency: `decide.md` checks `docs/DECISIONS.md`; the other four check
  `docs/TASKS.md`. Intentional and functionally equivalent, but inconsistent — revisit if a
  shared guard helper is ever added. (files: `plugins/project-docs/commands/decide.md`)
- Stop-hook reminder has no throttle/opt-out; fires on every stop until non-doc work is
  committed. Acceptable for now (non-blocking) but see the TASKS item.
  (files: `plugins/project-docs/hooks/remind-sync.sh`)
