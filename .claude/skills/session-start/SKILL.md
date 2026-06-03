---
name: session-start
description: Initialize a session by loading memory, task-log, and context
when_to_use: At the beginning of every session, before starting any work
user-invocable: true
---

# Session Start Protocol

Follow this sequence at the start of every session:

1. **Load memory index** -- Read `MEMORY.md` (auto-loaded). Scan for relevant entries.
2. **Read relevant memories** -- Based on the task, read specific memory files referenced in the index.
3. **Check task-log** -- Read `task-log.jsonl` for any `in_progress` or `blocked` work from prior sessions.
4. **Load session metrics** (if they exist) -- Check `metrics/session-metrics.jsonl` for the last 3 sessions. Compare to baseline. Flag anomalies.
5. **Check pending actions** -- Look for overdue action items from retrospectives.
6. **Deep memory wake-up** (optional) -- If a deep memory backend is configured, run `{{deepMemoryCmd}} wake-up`.
7. **Verify stale memories** -- If any recalled memory references a specific file, function, or flag, verify it still exists before acting on it.

Report what you found:
- In-progress tasks and their status
- Relevant memories for the current task
- Any anomalies or overdue items
