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
