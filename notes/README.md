---
title: Agent Notes
aliases:
  - Notes
  - Agent Observations
tags:
  - group/agents
  - type/notes
  - meta/template
---

# Agent Notes

> [!abstract] Persistent Notes and Observations
> The notes directory stores the agent's working notes, observations, research findings, and analysis in Obsidian-compatible Markdown format. Unlike memories (structured, cross-session recall) or project context (task-specific), notes are freeform knowledge artifacts that the agent produces during work.

## Purpose

Notes capture knowledge that doesn't fit neatly into the memory system:
- **Research notes** -- findings from investigating a topic, technology, or codebase area
- **Decision logs** -- reasoning behind architectural or design decisions (more detailed than memory)
- **Meeting/session notes** -- detailed context from conversations or reviews
- **Analysis** -- performance analysis, security review findings, code audit results
- **Drafts** -- work-in-progress documentation, proposals, or design docs

## Directory Structure

```
notes/
  README.md              # this file
  {topic}.md             # individual notes
  {date}-{topic}.md      # dated notes (e.g., 2026-04-16-auth-review.md)
  {project}/             # per-project note subdirectories (optional)
```

## Note Format

```markdown
---
title: {{descriptive title}}
tags:
  - type/note
  - topic/{{topic}}
created: {{ISO date}}
updated: {{ISO date}}
related:
  - "[[related note or memory]]"
---

# {{Title}}

{{content body -- freeform Markdown}}
```

## Notes vs. Memories

| Aspect | Notes | Memories |
|--------|-------|----------|
| **Format** | Freeform, detailed | Structured (rule + Why + How to apply) |
| **Purpose** | Knowledge artifacts | Cross-session recall |
| **Size** | Unbounded | Concise (indexed in MEMORY.md) |
| **Lifecycle** | Persists as reference | Updated/removed when stale |
| **Loaded** | On demand | MEMORY.md auto-loaded every session |

> [!tip] When to Use Each
> If you need to recall a fact quickly next session → **memory**. If you need to reference detailed analysis later → **note**. If a note produces a reusable insight, promote the insight to a memory.

## Rules

1. Notes use Obsidian-compatible Markdown (frontmatter, wikilinks, callouts)
2. One topic per note -- keep notes focused
3. Date-prefix notes that are time-sensitive (e.g., `2026-04-16-sprint-review.md`)
4. Link related notes with wikilinks
5. Tag notes for discoverability (`type/note`, `topic/{{topic}}`)
6. Notes are NOT indexed in MEMORY.md -- they are separate from the memory system

## See Also

- [[memories/README|Memories]] -- structured cross-session recall
- [[README|Base Profile]] -- full agent template
- [[conventions|Conventions]] -- formatting and naming rules
