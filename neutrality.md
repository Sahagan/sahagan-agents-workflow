---
title: Neutrality in Agent Cloning
aliases:
  - Neutral Cloning
  - Backend-Neutral Templates
tags:
  - group/agents
  - type/design
  - meta/template
---

# Neutrality in Agent Cloning

> [!abstract] Design Principle
> When an agent profile is cloned (created from the base template), the result must be **backend-neutral** -- functioning identically across all supported LLM backends, hosting environments, and orchestration harnesses without modification. Neutrality ensures that agent identity, memory, skills, and behavior are portable and interoperable.

## Why Neutrality Matters

1. **Portability.** An agent cloned today for Claude Code must work tomorrow with Gemini CLI, Codex CLI, or any future harness -- without editing the profile.
2. **Interoperability.** Multi-agent workflows may mix backends. A neutral profile lets agents collaborate regardless of which LLM powers each one.
3. **Trust boundaries.** When cloning agents from external sources (marketplaces, shared repos, team templates), neutrality prevents hidden backend-specific assumptions from creating security or compatibility gaps.
4. **Future-proofing.** New LLM backends, tools, and orchestration platforms emerge constantly. Neutral profiles adapt without rewrites.

## Dimensions of Neutrality

### 1. LLM Backend Neutrality

Agent instructions (`AGENTS.md`) must not assume a specific LLM backend.

| Neutral | Not Neutral |
|---------|-------------|
| `{{primaryModel}}` | `claude-opus-4-6` |
| "Use the configured model" | "Use Claude Opus" |
| `AGENTS.md` (generic) + symlinks | Hardcoded `CLAUDE.md` only |
| `{{deepMemoryCmd}}` | `mempalace` (specific tool) |

**Rule:** All backend-specific values must use `{{placeholder}}` syntax. The agent's own config or the orchestration harness resolves placeholders at runtime.

**Symlink pattern:**
```bash
# AGENTS.md is the single source of truth
ln -s AGENTS.md CLAUDE.md    # Claude Code reads CLAUDE.md
ln -s AGENTS.md GEMINI.md    # Gemini CLI reads GEMINI.md
ln -s AGENTS.md CODEX.md     # Codex CLI reads CODEX.md
ln -s AGENTS.md KIMI.md      # Kimi Coder reads KIMI.md
```

### 2. Tool & Platform Neutrality

Agent profiles must not assume specific tools, CLIs, or platform features beyond what the base profile defines.

| Neutral | Not Neutral |
|---------|-------------|
| "Run the project's verification gate" | "Run `pnpm check`" (in base) |
| `{{deepMemoryCmd}} search "query"` | `mempalace search "query"` |
| "Use the configured task tracker" | "Create a Linear ticket" |

**Exception:** Agent-specific profiles (e.g., `agent-oracle-coding/AGENTS.md`) MAY reference specific tools that are part of that agent's defined tech stack. Neutrality applies to the base template, not to specializations.

### 3. Orchestration Neutrality

The agent profile must work whether the agent is:
- Run standalone (single session, one human)
- Part of a multi-agent wave (parallel workers, orchestrator)
- Managed by a desktop app (LoopDuck council)
- Spawned by a CI/CD pipeline

**Rule:** Never assume a specific orchestration model. The base profile's multi-agent rules (worktree isolation, scoped commits) work in all contexts.

### 4. Memory Backend Neutrality

The two-tier memory system is backend-agnostic by design:

| Tier | Neutral Pattern |
|------|----------------|
| Tier 1 (file-based) | Markdown files with YAML frontmatter -- works everywhere |
| Tier 2 (deep backend) | `{{deepMemoryCmd}}` placeholder -- agent config resolves to specific tool |

**Rule:** Never hardcode a specific vector DB, knowledge graph, or memory tool in the base template. Each agent's config or AGENTS.md specifies its Tier 2 backend.

## Neutrality Enforcement

### Automated Checks

Run `scripts/check-agent-neutrality.sh` to validate agent profiles:

```bash
# Validate all agent profiles
./scripts/check-agent-neutrality.sh

# Validate a specific agent
./scripts/check-agent-neutrality.sh agents/agent-oracle-coding
```

The script checks:
- No hardcoded model IDs in base template files (e.g., `claude-opus-4-6`, `gemini-2.5-pro`)
- No hardcoded tool names in base template files (e.g., `mempalace`, `chromadb`)
- No backend-specific instructions in `AGENTS.md` (e.g., "Claude will...", "Gemini supports...")
- All backend-varying config uses `{{placeholder}}` syntax
- Symlinks point to `AGENTS.md` (not copied/diverged)

### Manual Review Checklist

Before merging a new agent profile or base template change:

- [ ] base template files contain zero hardcoded model IDs
- [ ] base template files contain zero hardcoded tool/CLI names
- [ ] All backend-specific values use `{{camelCase}}` placeholders
- [ ] `AGENTS.md` reads correctly regardless of which backend loads it
- [ ] Memory system references use `{{deepMemoryCmd}}` not a specific tool
- [ ] Verification gates reference "the project's gate" not a specific command
- [ ] Agent-specific overrides are in the agent's own directory, not in the base template

## Cloning Workflow

### Creating a Neutral Agent

```bash
# 1. Copy base structure
cp -r agents/_base agents/agent-{name}

# 2. Customize identity (replace placeholders)
# Edit agents/agent-{name}/AGENTS.md
# Edit agents/agent-{name}/persona/README.md

# 2.5. Create config manifest
# Create agents/agent-{name}/config.manifest.json
# Declare required placeholders, their types, and defaults:
cat > agents/agent-{name}/config.manifest.json << 'EOF'
{
  "agentId": "agent-{name}",
  "requiredConfig": {
    "primaryModel": { "type": "model-id", "description": "LLM model identifier", "required": true },
    "fallbackModel": { "type": "model-id", "description": "Fallback model", "required": false },
    "deepMemoryCmd": { "type": "command", "description": "Tier 2 memory CLI command", "required": false },
    "memoryPath": { "type": "path", "description": "File-based memory directory", "required": true },
    "sessionsPath": { "type": "path", "description": "Session data directory", "required": false }
  }
}
EOF

# 3. Create backend symlinks
cd agents/agent-{name}
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md GEMINI.md

# 4. Validate neutrality
./scripts/check-agent-neutrality.sh agents/agent-{name}

# 5. Add agent-specific config (model, tools, memory backend)
# These go in the agent's own config -- NOT in the base template
```

The `config.manifest.json` file enables the harness to validate that all required configuration is resolved before activating the agent. When the harness reads the manifest, it can check each `required: true` entry against the resolved config and fail fast with a clear error rather than allowing the agent to start in a broken state. This prevents the "neutrality-passes-but-can't-run" scenario where an agent clears all structural checks yet fails at runtime because a critical placeholder like `{{primaryModel}}` or `{{memoryPath}}` was never substituted.

### Cloning from External Sources

When importing an agent profile from an external repository, marketplace, or team:

1. **Inspect before trusting.** Read all files before enabling the agent. See [[trust-model|Trust Model]].
2. **Validate neutrality.** Run the check script to ensure no hidden assumptions.
3. **Sandbox first.** Run the cloned agent in an isolated worktree with limited permissions.
4. **Adapt config.** Map external placeholders to your local config values.

## Placeholder Reference

See [[conventions|Conventions]] for the full placeholder table. Key neutrality-relevant placeholders:

| Placeholder | Purpose | Resolved By |
|-------------|---------|-------------|
| `{{primaryModel}}` | LLM model ID | Agent config |
| `{{fallbackModel}}` | Fallback model ID | Agent config |
| `{{deepMemoryCmd}}` | Tier 2 memory CLI | Agent config |
| `{{memoryPath}}` | File-based memory dir | Orchestration harness |
| `{{sessionsPath}}` | Session data dir | Orchestration harness |
| `{{agentId}}` | Agent identifier | Agent config |
| `{{agentName}}` | Display name | Agent config |

## See Also

- [[README|Base Profile]] -- agent template
- [[conventions|Conventions]] -- placeholder syntax and naming
- [[trust-model|Trust Model]] -- security for external cloning
- [[persona/README|Persona]] -- identity and principles
