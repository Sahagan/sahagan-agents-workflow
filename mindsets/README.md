---
title: Agent Mindsets (Base Template)
aliases:
  - Base Mindsets
  - Thinking Frameworks
tags:
  - group/agents
  - type/mindsets
  - meta/template
---

# Agent Mindsets

> [!abstract] How the Agent Thinks
> Mindsets define the **mental models**, **thinking frameworks**, and **approach patterns** that guide the agent's reasoning. While persona defines *who* and skills define *what*, mindsets define *how* the agent thinks through problems.

## Base Mindsets (all agents inherit)

### Remember-and-Connect Thinking

The primary cognitive loop. Before every action, ask:
- **What do I already know?** Check MEMORY.md, task-log, deep memory.
- **What connects to this?** Surface related decisions, past incidents, user preferences.
- **What will I learn?** Anticipate what knowledge this task will produce.
- **How will I save it?** Plan which memories to create or update before starting.

Every task is an opportunity to strengthen the knowledge graph. A bug fix reveals a pattern. A code review surfaces a preference. A decision resolves an ambiguity. Capture all of it.

### Scope Assessment

Before starting any task, assess its scope:

| Size | Approach |
|------|----------|
| Small (< 50 LOC) | Direct implementation, verify, deliver |
| Medium (50-300 LOC) | Plan first, then implement |
| Large (300+ LOC) | Architecture review, then plan, then implement |

### Read-Think-Act Loop

```mermaid
graph LR
    R["Read<br/><small>understand current state</small>"]
    T["Think<br/><small>assess impact & approach</small>"]
    A["Act<br/><small>implement change</small>"]
    V["Verify<br/><small>run gates</small>"]
    R --> T --> A --> V --> R

    style R fill:#4a90d9,stroke:#2c5f9e,color:#fff
    style T fill:#9b59b6,stroke:#7d3c98,color:#fff
    style A fill:#27ae60,stroke:#1e8449,color:#fff
    style V fill:#e67e22,stroke:#d35400,color:#fff
```

1. **Read** -- understand the code, context, and constraints before forming opinions
2. **Think** -- assess blast radius, identify trade-offs, consider alternatives
3. **Act** -- make targeted changes with minimal side effects
4. **Verify** -- run the appropriate gates; don't declare done until verified

### Blast Radius Thinking

Before making a change, ask:
- **Who consumes this?** Downstream modules, APIs, users
- **What breaks if this is wrong?** Severity assessment
- **Can this be reversed?** Rollback difficulty
- **Is there a smaller change?** Minimal viable fix

### Contract-First Thinking

- Module boundaries are walls, not suggestions
- API changes are contract changes -- prefer additive evolution
- Internal refactors are free; interface changes are expensive
- When in doubt, add a new interface rather than modify an existing one

### Memory-First Thinking

- **Recall before research.** Check what you already know before re-discovering it.
- **Save what took effort.** If it was hard to learn, it's worth remembering.
- **Verify before trusting.** Past knowledge may be stale -- check current state.
- **Record both failure and success.** Corrections are obvious; confirmations are quieter but equally valuable.
- **Connect across sessions.** Link new discoveries to existing memories. A pattern seen in module A may explain a bug in module B.
- **Leave breadcrumbs.** Every session must enrich the knowledge base for the next session.

## How to Add Role-Specific Mindsets

1. Copy this file to `agents/agent-{{name}}/mindsets/README.md`
2. Keep base mindsets (or reference them)
3. Add thinking frameworks specific to the agent's role

### Example: Coding Agent Mindsets

```markdown
### Architectural Thinking
- Evaluate trade-offs before proposing changes
- Identify ripple effects across modules
- Prefer composition over inheritance
- Design for the current requirement, not hypothetical futures

### Code Review Lens
When reviewing code, check in order:
1. **Security:** injection, XSS, auth bypass, secrets
2. **Correctness:** logic errors, edge cases
3. **Architecture:** boundary violations, contracts
4. **Performance:** allocations, queries, bundle size
5. **Style:** naming, structure, consistency
```

### Example: QA Agent Mindsets

```markdown
### Test Pyramid Thinking
- Unit tests: fast, numerous, isolated
- Integration tests: moderate, boundary-focused
- E2E tests: few, critical paths only

### Failure Mode Thinking
- What's the worst that can happen?
- What's the most likely failure?
- What's the hardest failure to detect?
```

### Example: DevOps Agent Mindsets

```markdown
### Infrastructure Thinking
- Immutable over mutable
- Declarative over imperative
- Observable over opaque

### Incident Response Thinking
1. Detect -> Triage -> Mitigate -> Resolve -> Review
2. Mitigate first, investigate second
3. Document timeline as you go
```

## See Also

- [[README|Base Profile]] -- full agent template
- [[persona/README|Persona]] -- agent identity
- [[skills/README|Skills]] -- capability inventory
