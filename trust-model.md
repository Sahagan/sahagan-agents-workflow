---
title: Trust Model for Agent Cloning
aliases:
  - Trust Model
  - Agent Trust
  - Cloning Security
tags:
  - group/agents
  - type/design
  - meta/security
---

# Trust Model for Agent Cloning

> [!abstract] Security Boundaries for Cloned Agent Profiles
> When agent profiles are cloned from external sources -- shared repositories, marketplaces, team templates, or community contributions -- they must pass through a trust pipeline before activation. This document defines the trust levels, verification steps, and sandboxing rules that protect the host system.

## Why a Trust Model

Agent profiles contain instructions that an LLM follows. A malicious or careless profile could:

- **Exfiltrate data** -- instruct the agent to read secrets and post them externally
- **Modify untrusted files** -- expand the agent's scope beyond its assigned worktree
- **Bypass verification gates** -- skip safety checks before pushing code
- **Inject into other agents** -- cross-contaminate memory or task logs in multi-agent workflows
- **Social-engineer the user** -- mimic system messages or fabricate context

The trust model ensures that cloned profiles are inspected, sandboxed, and explicitly approved before they can affect the system.

## Trust Levels

| Level | Name | Source | Permissions |
|-------|------|--------|-------------|
| **T0** | Untrusted | Unknown origin, no review | Read-only sandbox, no git, no network |
| **T1** | Inspected | Reviewed by user, passes neutrality check | Isolated worktree, scoped git, no external network |
| **T2** | Approved | Explicitly approved by user or org admin | Full worktree, git push, network per config |
| **T3** | Built-in | Ships with the repo (e.g., the base template, `agent-oracle-coding/`) | Full access per project config |

### Trust Promotion

Profiles advance through trust levels via explicit user action:

```
T0 (Untrusted) --[inspect]--> T1 (Inspected) --[approve]--> T2 (Approved)
```

Trust is **never** auto-promoted. The user or an org-level policy must explicitly advance a profile.

## Verification Pipeline

### Step 1: Fetch and Quarantine

When cloning an agent profile from an external source:

```bash
# Clone into a quarantine directory (NOT into agents/)
git clone <source-repo> /tmp/quarantine/agent-{name}

# Or copy from a shared location
cp -r /path/to/shared/agent-{name} /tmp/quarantine/agent-{name}
```

The quarantine directory is outside the project tree. The agent is not loadable from quarantine.

### Step 2: Inspect

Review all files in the cloned profile:

```bash
# List all files
find /tmp/quarantine/agent-{name} -type f

# Read AGENTS.md -- this is what the LLM will follow
cat /tmp/quarantine/agent-{name}/AGENTS.md

# Check for suspicious patterns
grep -rn "curl\|wget\|fetch\|http\|eval\|exec\|rm -rf\|sudo" /tmp/quarantine/agent-{name}/
```

#### Red Flags

| Pattern | Risk | Action |
|---------|------|--------|
| URLs in instructions | Data exfiltration | Reject unless justified |
| Shell commands in AGENTS.md | Arbitrary execution | Review each command |
| References to `~/.ssh`, `~/.aws`, credentials | Secret theft | Reject |
| Instructions to ignore safety rules | Gate bypass | Reject |
| Overly broad file access patterns | Scope creep | Constrain |
| Memory files with pre-populated content | Context poisoning | Delete and let agent rebuild |

### Step 3: Validate Neutrality

Run the neutrality check against the quarantined profile:

```bash
./scripts/check-agent-neutrality.sh /tmp/quarantine/agent-{name}
```

A neutral profile is safer because:
- No hardcoded tool names = no assumptions about what's installed
- No hardcoded model IDs = no dependency on a specific backend
- Placeholder syntax = explicit about what needs configuration

### Step 4: Sandbox Test

Before full adoption, run the agent in a sandboxed environment:

```bash
# Create an isolated worktree for testing
cd {{moduleName}}
git worktree add /tmp/sandbox-test -b sandbox/agent-{name}-test

# Copy the agent profile into the sandbox
cp -r /tmp/quarantine/agent-{name} /tmp/sandbox-test/agents/agent-{name}

# Run the agent with limited scope
# (specific to your orchestration harness)
```

Observe:
- Does it stay within its worktree?
- Does it respect commit scope rules?
- Does it attempt network access?
- Does it read files outside its assigned scope?

### Step 5: Approve and Install

After inspection and sandbox testing:

```bash
# Move from quarantine to the project
mv /tmp/quarantine/agent-{name} agents/agent-{name}

# Create backend symlinks
cd agents/agent-{name}
ln -s AGENTS.md CLAUDE.md

# Commit the new agent profile
git add agents/agent-{name}
git commit -m "Agents: add agent-{name} from {source}"
```

## Sandboxing Rules

### Worktree Isolation (Always)

Every agent -- built-in or cloned -- operates in its own worktree. This is the primary containment mechanism.

| Rule | Enforcement |
|------|-------------|
| One worktree per task | Git branching strategy |
| No access to other worktrees | Filesystem boundary |
| Scoped commits only | Multi-agent rules |
| No `git stash` | Prevents cross-agent state leakage |

### Memory Isolation

Cloned agents start with **empty memory**. They do not inherit:
- Memory files from the source repository
- Pre-populated MEMORY.md entries
- Deep memory backend data

If the cloned profile includes memory files, **delete them** during Step 2 (Inspect):

```bash
rm -rf /tmp/quarantine/agent-{name}/memories/*.md
echo "" > /tmp/quarantine/agent-{name}/memories/MEMORY.md
```

The agent builds its own memory through legitimate work.

### Scope Constraints

| Trust Level | File Access | Git Access | Network |
|-------------|-------------|------------|---------|
| T0 | Read-only in sandbox | None | None |
| T1 | Read/write in worktree | Commit only (no push) | None |
| T2 | Read/write in worktree | Commit + push | Per config |
| T3 | Per project config | Full | Per config |

## Multi-Agent Trust

When running multiple agents in a wave, trust applies per-agent:

- A T1 agent can work alongside T3 agents
- Each agent's trust level constrains only that agent
- Cross-agent communication (if any) respects the lowest trust level of the pair
- Shared resources (e.g., the monorepo main branch) require T2+ to push

### Trust Inheritance

Cloned agents do **not** inherit trust from their source:
- A T3 built-in agent's fork starts at T0
- A community-shared profile starts at T0
- A team member's profile starts at T1 (inspected by virtue of team membership, but still requires explicit approval for T2)

### Sub-Agent Spawning

When a running agent (Agent A) dynamically spawns another agent (Agent B) as a sub-agent during a session, trust is assigned at spawn time and cannot be escalated afterward.

#### Starting Trust by Profile Origin

| Agent B Profile Origin | Starting Trust |
|------------------------|----------------|
| Built-in profile (T3) | T3 |
| Approved profile (T2) | min(A's trust, T2) |
| External / cloned profile | T0 — regardless of A's trust |

> [!warning] Auto-Promotion Through Spawning is Forbidden
> A high-trust agent cannot elevate an external profile by spawning it. An external profile always starts at T0, even if spawned by a T3 agent. Trust promotion still requires the explicit user or org-admin action described in the pipeline above.

#### Trust Ceiling Rule

A sub-agent's effective trust is capped by its parent's trust level:

```
effective_trust(B) = min(trust(A), own_trust(B))
```

A T1 parent cannot produce a T2-effective sub-agent. If Agent A holds T1 and spawns an approved (T2) profile, Agent B runs at T1 for the duration of that session.

#### Capability Requirement: `canDelegate`

An agent must explicitly declare delegation authority in its capabilities manifest before it is permitted to spawn sub-agents. Without this flag the orchestrator blocks the spawn attempt.

```yaml
# agents/agent-{name}/AGENTS.md capabilities block
capabilities:
  canDelegate: true   # required to spawn sub-agents; omit or set false to deny
```

> [!note] Principle of Least Privilege
> Most agents should not declare `canDelegate: true`. Only orchestrator-role agents that are explicitly designed to coordinate sub-agents should carry this capability.

#### Worktree Isolation for Spawned Agents

The spawning agent is responsible for creating an isolated worktree for each sub-agent it spawns. The sub-agent is scoped to that worktree and cannot read or write the parent's worktree.

```bash
# Agent A creates an isolated worktree before handing off to Agent B
git worktree add /tmp/{{subTaskId}} -b agent/{{agentB}}/{{subTaskId}}

# Agent B receives /tmp/{{subTaskId}} as its working directory
# Agent B has no reference to Agent A's worktree path
```

| Rule | Rationale |
|------|-----------|
| Parent creates the worktree | Keeps the spawning decision auditable under A's trust scope |
| Sub-agent path is not disclosed to the sub-agent | Prevents path-traversal to parent context |
| Worktree removed by parent after merge | Parent retains lifecycle ownership |

## Revoking Trust

Trust can be revoked at any time:

```bash
# Demote to T0 (quarantine)
mv agents/agent-{name} /tmp/quarantine/agent-{name}
git rm -r agents/agent-{name}
git commit -m "Agents: revoke trust for agent-{name}"

# Or delete entirely
rm -rf agents/agent-{name}
git rm -r agents/agent-{name}
git commit -m "Agents: remove agent-{name}"
```

Revocation is immediate. The agent cannot execute after its profile is removed from the project tree.

## See Also

- [[neutrality|Neutrality]] -- backend-neutral cloning design
- [[README|Base Profile]] -- agent template
- [[conventions|Conventions]] -- naming and placeholder rules
- [[projects/branching|Branching]] -- worktree isolation strategy
