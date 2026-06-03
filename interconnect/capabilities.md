---
title: Agent Capabilities
aliases:
  - Capability Declaration
  - Skill Registry
  - Agent Card
tags:
  - group/agents
  - type/design
  - meta/template
  - capability/interconnect
---

# Agent Capabilities

> [!abstract] Machine-Readable Skill and Expertise Declaration
> Every agent can declare its capabilities -- skills, expertise domains, authority levels, and voting weight. This enables discovery ("who can help with this domain?"), routing (assign tasks by expertise match), and authority ("who can veto architecture changes?").

## Capability Manifest

Agents participating in multi-agent workflows or distributed for cloning MUST include a capabilities manifest -- either as a `capabilities` section in the `README.md` config block or as a standalone `capabilities.json` in their directory. Without it, orchestrators cannot route tasks by expertise match, and cloned agents cannot declare what configuration they require to operate. Standalone single-agent setups MAY still omit it.

> [!warning] Capabilities Required for Distributed and Multi-Agent Use
> Without a capabilities manifest, a cloned agent may pass neutrality checks but still be unable to operate: the harness has no way to know what the agent needs (models, memory backend, tools) and cannot validate that required config is resolved before activating it.

### Format

```json
{
  "agentId": "agent-{{name}}",
  "role": "{{role}}",
  "skills": [
    {
      "id": "{{skill-id-1}}",
      "name": "{{Skill Name}}",
      "proficiency": "expert",
      "domains": ["{{domain-1}}", "{{domain-2}}"]
    },
    {
      "id": "{{skill-id-2}}",
      "name": "{{Skill Name}}",
      "proficiency": "advanced",
      "domains": ["{{domain-3}}"]
    },
    {
      "id": "architecture-review",
      "name": "Architecture Review",
      "proficiency": "expert",
      "domains": ["api-design", "module-boundaries", "scalability"]
    },
    {
      "id": "code-review",
      "name": "Code Review",
      "proficiency": "expert",
      "domains": ["security", "correctness", "performance"]
    }
  ],
  "expertiseDomains": [
    "architecture",
    "{{domain-1}}",
    "{{domain-2}}",
    "api-design",
    "module-boundaries"
  ],
  "vetoDomains": [
    "architecture",
    "breaking-changes",
    "security"
  ],
  "votingWeight": 1,
  "canDelegate": true,
  "canReview": true,
  "maxConcurrentTasks": 3
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `agentId` | string | Yes | Agent identifier (`agent-{name}`) |
| `role` | string | Yes | Human-readable role title |
| `skills` | Skill[] | Yes | List of declared skills |
| `expertiseDomains` | string[] | Yes | Areas of deep knowledge |
| `vetoDomains` | string[] | No | Areas where this agent can block decisions |
| `votingWeight` | number | No | Relative voting weight (default: 1) |
| `canDelegate` | boolean | No | Can this agent delegate work to others? (default: false) |
| `canReview` | boolean | No | Can this agent review others' work? (default: false) |
| `maxConcurrentTasks` | number | No | Max parallel tasks (default: 3) |

### Skill Object

```yaml
# Skill Object Schema
AgentSkill:
  id: string           # kebab-case identifier (e.g., "data-analysis")
  name: string         # Human-readable name
  proficiency: Proficiency
  domains: string[]    # Specific sub-areas within this skill

Proficiency:
  enum:
    - expert           # Can teach, design systems, handle edge cases
    - advanced         # Can work independently, make sound decisions
    - intermediate     # Can implement with guidance, needs review
    - novice           # Learning, needs close support
```

## Expertise Domains

Standard domain vocabulary for consistent cross-agent matching:

### Technical Domains

| Domain | Covers |
|--------|--------|
| `architecture` | System design, module boundaries, API contracts |
| `backend` | Server-side logic, databases, APIs |
| `frontend` | UI components, state management, styling |
| `security` | Auth, encryption, OWASP, vulnerability assessment |
| `performance` | Profiling, optimization, caching, load testing |
| `testing` | Unit, integration, E2E, test strategy |
| `devops` | CI/CD, deployment, infrastructure, monitoring |
| `database` | Schema design, migrations, query optimization |
| `api-design` | REST, GraphQL, protocol buffers, versioning |
| `documentation` | Technical writing, API docs, user guides |

### Language/Framework Domains

> [!tip] Custom Domains
> Language and framework domains are project-specific. Each agent declares its own language/framework domains in its capabilities manifest. There is no canonical list -- agents add domains matching their tech stack.

Example domains (customize per agent):

| Domain | Covers |
|--------|--------|
| `{{language-1}}` | Language-specific tools, patterns, ecosystem |
| `{{framework-1}}` | Framework components, patterns, conventions |

### Process Domains

| Domain | Covers |
|--------|--------|
| `breaking-changes` | API evolution, deprecation, migration |
| `module-boundaries` | Plugin SDK, import boundaries, contracts |
| `scalability` | Horizontal/vertical scaling, data partitioning |
| `observability` | Logging, tracing, metrics, alerting |

> [!tip] Extending the Domain Vocabulary
> Agents can use custom domains beyond this list. The standard vocabulary ensures cross-agent matching for common areas. Custom domains are project-specific and should be documented in the agent's own profile.

## Veto Domains

An agent with veto power in a domain can **block decisions** that affect that domain. Veto is not a permanent block -- it triggers a deliberation round (see [[interconnect/coordination|Coordination]]).

**Rules:**
- Veto domains must be a subset of expertise domains (you can only veto what you deeply understand)
- Veto triggers a structured concern with rationale, not a silent block
- After 3 deliberation rounds, unresolved vetoes escalate to human

## Voting Weight

Default weight is 1 (equal votes). Weights can be adjusted for:
- **Domain expertise:** Weight 2 for architecture decisions if agent is the architecture expert
- **Seniority:** Weight 2 for senior agents in code review votes
- **Equal by default:** All agents start at weight 1

> [!warning] Weight Must Be Justified
> Voting weight above 1 must be justified by domain expertise or role. Never use weight to silence other agents. The goal is informed consensus, not authority dominance.

## A2A Alignment

The capability manifest maps to Google A2A's `AgentCard`:

| Capability Field | A2A AgentCard Field | Mapping |
|-----------------|---------------------|---------|
| `agentId` | `name` | Direct |
| `role` | `description` | Direct |
| `skills[].id` | `skills[].id` | Direct |
| `skills[].name` | `skills[].name` | Direct |
| `skills[].domains` | (not in A2A) | Extension |
| `expertiseDomains` | (not in A2A) | Extension |
| `vetoDomains` | (not in A2A) | Extension |
| `votingWeight` | (not in A2A) | Extension |

When generating an A2A `AgentCard` from capabilities, map `skills` directly and include extensions in `capabilities` as custom fields.

## Discovery Protocol

### Local Discovery (File-Based)

Agents discover each other by reading capability manifests from sibling directories:

```bash
# List all available agents
ls agents/agent-*/

# Read a specific agent's capabilities
cat agents/agent-{name}/capabilities.json

# Or parse from README.md config block
grep -A 50 '"capabilities"' agents/agent-{name}/README.md
```

### Orchestrator-Mediated Discovery

In multi-agent workflows, the orchestrator (LoopDuck, CLI script, `.agents/config.json`) reads all capabilities and assigns tasks by matching:

```
Task tags: ["rust", "security", "backend"]
Agent expertise: ["architecture", "typescript", "rust"]
Match score: 1/3 (rust matches)
```

The agent with the highest match score gets the task.

### Remote Discovery (A2A)

For agents running as services, use A2A discovery:

```bash
# Discover remote agent
curl https://agent.example.com/.well-known/agent-card.json
```

## Type Definitions

```yaml
# Agent Capabilities Schema
AgentCapabilities:
  agentId: string
  role: string
  skills: AgentSkill[]
  expertiseDomains: string[]
  vetoDomains?: string[]
  votingWeight?: number        # default: 1
  canDelegate?: boolean        # default: false
  canReview?: boolean          # default: false
  maxConcurrentTasks?: number  # default: 3

AgentSkill:
  id: string
  name: string
  proficiency: expert | advanced | intermediate | novice
  domains: string[]
```

## See Also

- [[interconnect/README|Interconnect Overview]] -- how agents connect
- [[interconnect/coordination|Coordination]] -- consensus and decision-making
- [[conventions|Conventions]] -- naming and type definitions
- [[skills/README|Skills]] -- base skill inventory (prose version)
