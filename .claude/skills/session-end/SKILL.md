---
name: session-end
description: Persist discoveries and update state before ending a session
when_to_use: Before ending a session or switching to a different task
user-invocable: true
---

# Session End Protocol

Follow this sequence before ending a session:

1. **Update task-log** -- Set final status (`completed`, `blocked`, `in_progress`) and `lastAction` for each task worked on.
2. **Save discoveries** -- Persist non-obvious findings as project or feedback memories:
   - Corrections received -> feedback memory (include **Why** and **How to apply**)
   - Confirmed approaches -> feedback memory (record what worked)
   - Decisions made -> project memory (include **Why** and **How to apply**)
   - External resources found -> reference memory
3. **Update stale memories** -- If any memory encountered during work was outdated, update or remove it.
4. **Write session metrics** -- Append to `metrics/session-metrics.jsonl`:
   - Tasks attempted, completed, failed
   - Gates passed/failed
   - Revision cycles
   - Blocker types encountered
5. **Check skill progression** -- If criteria met for a proficiency level change, update the skill record.
6. **Mine session** (optional) -- If deep memory backend is configured, run `{{deepMemoryCmd}} mine` for verbatim storage.

Report what was persisted.
