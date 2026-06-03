---
title: Agent Skills (Base Template)
aliases:
  - Base Skills
  - Skills Template
tags:
  - group/agents
  - type/skills
  - meta/template
---

# Agent Skills

> [!abstract] Capability Inventory
> Skills define **what the agent can do**. Each agent inherits base skills and adds role-specific ones. Skills are grouped by category and can be referenced by orchestrators for task assignment.

## Shipped with the Template

These are the slash-commands wired into `.claude/skills/` and `.claude/commands/` that every cloned agent gets out of the box. They are lifecycle hooks and validation gates -- distinct from the aspirational capability inventory below.

| Command | Location | Trigger | Purpose |
|---------|----------|---------|---------|
| **`/session-start`** | `.claude/skills/session-start/SKILL.md` | `SessionStart` hook (auto) + user-invocable | Load memory, task-log, and context at session start |
| **`/session-end`** | `.claude/skills/session-end/SKILL.md` | `SessionEnd` hook (auto) + user-invocable | Persist discoveries and update state before ending |
| **`/verify`** | `.claude/skills/verify/SKILL.md` | `PostToolUse` reminder after edits + user-invocable | Run the neutrality check on documentation |
| **`/new-agent`** | `.claude/commands/new-agent.md` | User-invocable | Clone this template into a new agent repo |

> [!note] Lifecycle vs Capabilities
> The shipped commands above are concrete tooling. The capability inventory that follows describes the **base skills every cloned agent is expected to fulfill** -- either through built-in agent behavior, harness features, or additional skill implementations. They are aspirational requirements, not implemented slash-commands.

## Base Skills (all agents inherit)

### Memory & Recall

| Skill | Description |
|-------|-------------|
| **File memory management** | Create, update, remove, and index memory files |
| **Deep memory integration** | Mine sessions, search decisions, wake-up context via Tier 2 backend |
| **Cross-session recall** | Remember preferences, project state, past decisions |
| **Stale memory detection** | Verify claims against current code; remove outdated entries |

### Task & Project Tracking

| Skill | Description |
|-------|-------------|
| **Task log management** | Track active/blocked/completed tasks in `task-log.jsonl` |
| **Multi-project switching** | Save context, switch worktrees, restore state |
| **Progress handoff** | Persist state for session-to-session or agent-to-agent handoff |

### Git & Branching

| Skill | Description |
|-------|-------------|
| **Worktree isolation** | Create/manage/cleanup git worktrees for parallel work |
| **Branch management** | Naming conventions, rebase workflow, conflict avoidance |
| **Submodule workflow** | Two-step commit (submodule first, then parent ref update) |

### Code Quality

| Skill | Description |
|-------|-------------|
| **Security awareness** | OWASP top 10, injection vectors, auth flows |
| **Verification gates** | Run lint, type-check, test, build pipelines |
| **Code review** | Correctness, performance, style consistency |

## How to Add Role-Specific Skills

1. Copy this file to `agents/agent-{{name}}/skills/README.md`
2. Keep the base skills section (or reference it)
3. Add skill categories specific to the agent's role
4. Include domain knowledge if the agent specializes in specific areas

### Example: Coding Agent Skills

```markdown
## Code Generation
| Skill | Description |
|-------|-------------|
| **{{Language}}** | Language-specific patterns, tooling, ecosystem |
| **{{Framework}}** | Framework components, state management, conventions |

## Architecture
| Skill | Description |
|-------|-------------|
| **System design** | Module boundaries, API contracts |
| **Dependency analysis** | Impact assessment, ripple effects |
```

> [!tip] Customize Per Agent
> Replace `{{Language}}` and `{{Framework}}` with the agent's actual tech stack when creating a specialized agent.

### Example: QA Agent Skills

```markdown
## Testing
| Skill | Description |
|-------|-------------|
| **Test strategy** | Unit, integration, E2E coverage planning |
| **Test generation** | Property-based, snapshot, regression tests |

## Verification
| Skill | Description |
|-------|-------------|
| **Bug reproduction** | Minimal repro cases from bug reports |
| **Performance profiling** | Identify bottlenecks, benchmark changes |
```

## See Also

- [[README|Base Profile]] -- full agent template
- [[persona/README|Persona]] -- agent identity
- [[mindsets/README|Mindsets]] -- thinking frameworks
