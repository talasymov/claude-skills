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
