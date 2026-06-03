---
title: Naming Conventions & Type Definitions
aliases:
  - Conventions
  - Naming
  - Types
tags:
  - group/agents
  - type/conventions
  - meta/template
---

# Naming Conventions & Type Definitions

> [!abstract] Strict Standards for Agent Profiles
> All agent profiles MUST follow these naming conventions and type definitions. Consistency across files enables reliable tooling, template substitution, and multi-agent interoperability.

---

## Document Format

> [!tip] Two-Tier Format Rule
> Agent profiles use two distinct Markdown formats based on audience. **Documentation** (human knowledge base) uses full Obsidian-compatible Markdown. **Instructions** (LLM-consumed) use plain Markdown for backend portability.

### Format Tiers

| Tier | Audience | Format | Files |
|------|----------|--------|-------|
| **Documentation** | Humans (Obsidian vault) | Obsidian Markdown | `README.md`, `conventions.md`, `neutrality.md`, `trust-model.md`, `persona/`, `memories/`, `skills/`, `mindsets/`, `projects/` |
| **Instructions** | LLM backends | Plain Markdown | `AGENTS.md` (and its symlinks: `CLAUDE.md`, `GEMINI.md`, `CODEX.md`, `KIMI.md`) |

### Documentation Files (Obsidian Format)

All documentation files **must** include:

1. **YAML frontmatter** with `title`, `aliases`, `tags` (and optionally `cssclasses`)
2. **Wikilinks** for cross-references: `[[path|Display Text]]`
3. **Callouts** where appropriate (see palette below)
4. **Mermaid diagrams** for architecture, flows, and state machines (where they add clarity)

### Instruction Files (Plain Format)

`AGENTS.md` files **must not** include:

- YAML frontmatter (`---` blocks)
- Wikilinks (`[[...]]`)
- Obsidian callouts (`> [!type]`)
- Mermaid diagrams
- `cssclasses` or Obsidian-specific metadata

This ensures instructions are readable by any LLM backend (Claude, Gemini, Codex, Kimi) without Obsidian parsing.

### Callout Palette

Use these callout types consistently across all documentation files:

| Callout | Purpose | When to Use |
|---------|---------|-------------|
| `> [!abstract]` | Section summary | Opening block of every major document -- one-sentence purpose statement |
| `> [!tip]` | Helpful guidance | Non-obvious best practices, shortcuts, or architectural insights |
| `> [!warning]` | Critical rules | Rules where violation causes real damage (data loss, branch contamination, security) |
| `> [!example]` | Concrete examples | Collapsible examples that illustrate a pattern or concept |
| `> [!note]` | Additional context | Supplementary information that adds depth but isn't essential |
| `> [!danger]` | Security/safety | Critical security warnings, irreversible actions, trust boundaries |

**Avoid** using: `[!info]` (use `[!note]`), `[!caution]` (use `[!warning]`), `[!summary]` (use `[!abstract]`). Keeping the palette small ensures visual consistency across the vault.

### Frontmatter Template

```yaml
---
title: Document Title
aliases:
  - Short Name
  - Alternative Name
tags:
  - group/agents
  - type/{persona|skills|mindsets|conventions|design}
  - meta/template          # only in base template files
  - role/{coding|qa|devops} # only in agent-specific files
cssclasses:
  - wide-page              # optional, for wide content
---
```

### Mermaid Usage

Use Mermaid diagrams for:
- **State machines** (`stateDiagram-v2`) -- task lifecycle, worktree states
- **Sequence diagrams** (`sequenceDiagram`) -- multi-agent coordination, project switching
- **Flowcharts** (`graph TD/LR`) -- memory tiers, decision trees, architecture
- **Mind maps** (`mindmap`) -- concept overviews, memory mapping

Keep diagrams focused -- one concept per diagram, under 20 nodes.

---

## Naming Styles

### File & Directory Names: `kebab-case`

```
agents/
  persona/
  memories/
  skills/
  mindsets/
  projects/
  agent-oracle-coding/
  agent-qa-testing/
```

- Lowercase only
- Hyphens as separators
- Agent directories: `agent-{name}` prefix required
- Base directory: template root

### JSON Fields: `camelCase`

```json
{
  "taskId": "PROJ-42",
  "agentId": "agent-oracle-coding",
  "baseBranch": "main",
  "lastAction": "Implemented feature X",
  "startedAt": "2026-04-16T10:00:00Z",
  "filesChanged": ["src/feature.ts"],
  "verificationGate": "pending"
}
```

- First word lowercase, subsequent words capitalized
- No underscores, no hyphens
- Boolean fields: `is`/`has` prefix (e.g., `isBlocked`, `hasWorktree`)
- Timestamp fields: `*At` suffix (e.g., `createdAt`, `updatedAt`, `startedAt`)
- Array fields: plural (e.g., `blockers`, `filesChanged`, `worktrees`)

### YAML Frontmatter Fields: `lowercase`

```yaml
---
name: Memory Name
description: one-line description
type: feedback
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[related-note]]"
---
```

- All lowercase, no separators
- Standard fields: `name`, `description`, `type`, `created`, `updated`, `related`
- Tag fields: `title`, `aliases`, `tags`, `cssclasses`

### Placeholder Syntax: `{{camelCase}}`

Templates use **double curly braces** with **camelCase** naming:

```
Branch: feature/{{taskId}}
Module: {{moduleName}}
Worktree: /tmp/{{taskId}}
```

| Placeholder | Meaning | Example Value |
|-------------|---------|---------------|
| `{{agentId}}` | Agent identifier | `agent-oracle-coding` |
| `{{agentName}}` | Agent display name | `Oracle` |
| `{{taskId}}` | Task identifier | `PROJ-42` |
| `{{moduleName}}` | Module/submodule path | `my-module` |
| `{{branchName}}` | Git branch | `feature/proj-42` |
| `{{worktreePath}}` | Worktree directory | `/tmp/proj-42` |
| `{{status}}` | Task status | `in_progress` |
| `{{lastAction}}` | Last action description | `Implemented feature X` |
| `{{scope}}` | Commit scope prefix | `Auth` |
| `{{description}}` | Short description | `add token refresh` |
| `{{featureName}}` | Feature being built | `token refresh` |
| `{{featureArea}}` | Area/domain | `authentication` |
| `{{referenceFile}}` | File to reference | `src/auth/token.ts` |
| `{{finalStatus}}` | End-of-session status | `completed` |
| `{{memoryPath}}` | File-based memory dir | `.claude/projects/{project}/memory/` |
| `{{sessionsPath}}` | Session data dir | `~/.claude/projects/` |
| `{{deepMemoryCmd}}` | Deep memory CLI tool | `mempalace` |
| `{{primaryModel}}` | Primary LLM model ID | `claude-opus-4-6` |
| `{{fallbackModel}}` | Fallback LLM model ID | `claude-sonnet-4-6` |
| `{{monorepoRoot}}` | Monorepo root directory | `~/projects/my-monorepo` |
| `{{files}}` | File list for git add | `src/auth.ts src/auth.test.ts` |
| `{{version}}` | Release version string | `v2026.4.16` |
| `{{waveNumber}}` | Wave ordinal | `3` |

#### Neutrality-Critical Placeholders

These placeholders **must** be used in base template files instead of hardcoded values. They are resolved by the agent's own config or the orchestration harness at runtime. See [[neutrality|Neutrality in Cloning]] for the full design principle.

| Placeholder | Neutrality Dimension | Hardcoded Anti-Pattern |
|-------------|---------------------|------------------------|
| `{{primaryModel}}` | LLM backend | `claude-opus-4-6`, `gemini-2.5-pro` |
| `{{fallbackModel}}` | LLM backend | `claude-sonnet-4-6` |
| `{{deepMemoryCmd}}` | Tool/platform | `mempalace`, `chromadb` |
| `{{memoryPath}}` | Orchestration | `~/.claude/projects/foo/memory/` |
| `{{sessionsPath}}` | Orchestration | `~/.claude/projects/` |
| `{{verifyCmd}}` | Tool/platform | `pnpm check`, `cargo clippy` |
| `{{lintCmd}}` | Tool/platform | `oxlint`, `eslint` |
| `{{formatCmd}}` | Tool/platform | `oxfmt`, `prettier` |
| `{{testCmd}}` | Tool/platform | `vitest`, `cargo test` |
| `{{buildCmd}}` | Tool/platform | `pnpm build`, `cargo build` |
| `{{taskTracker}}` | External service | `Linear`, `Jira`, `GitHub Issues` |
| `{{ciPipeline}}` | Orchestration | `GitHub Actions`, `GitLab CI` |

### Git Branch Names: `kebab-case` with type prefix

```
feature/{task-id}
fix/{task-id}
refactor/{task-id}
chore/{task-id}
agent/{agent-id}/{task-id}
release/{version}
hotfix/{task-id}
```

- Prefix = branch type (lowercase)
- Body = task ID (lowercase, hyphenated)
- Agent-scoped = extra `{agent-id}/` segment

### Task IDs: `UPPER-N`

```
PROJ-42
MOD-99
```

- Uppercase prefix (project/module abbreviation)
- Hyphen separator
- Numeric suffix
- Each project defines its own prefix table

### Agent IDs: `agent-{kebab-case}`

```
agent-oracle-coding
agent-qa-testing
agent-devops-deploy
```

- Always prefixed with `agent-`
- Lowercase kebab-case role description

### Commit Messages: `{Scope}: {action}`

```
Auth: add token refresh handler
CLI: fix verbose flag parsing
UI: update responsive grid layout
```

- Scope = PascalCase module/area name
- Action = lowercase imperative verb phrase
- No period at end
- Under 72 characters

---

## Type Definitions

### TaskLogEntry

```yaml
TaskLogEntry:
  taskId: string           # "PROJ-42" -- UPPER-N format
  moduleName: string       # "my-module" -- kebab-case module path
  branchName: string       # "feature/proj-42" -- full branch name
  worktreePath: string     # "/tmp/proj-42" -- absolute path
  status: TaskStatus
  wave?: number            # optional -- wave ordinal (multi-agent)
  startedAt: string        # ISO 8601 timestamp
  lastAction: string       # human-readable last action
  blockers: Blocker[]      # structured blocker list (see below)
  filesChanged: string[]   # list of relative file paths
  verificationGate: GateStatus

  # --- Inter-agent fields (optional, for multi-agent coordination) ---
  waitingFor?: string      # optional -- agent ID this task depends on (e.g., "agent-qa")
  handoffFrom?: string     # optional -- agent ID that handed off this task
  reviewStatus?: ReviewStatus  # optional
  reviewedBy?: string      # optional -- agent ID that reviewed (or is reviewing)

TaskStatus:
  enum: [pending, in_progress, blocked, completed, failed]

GateStatus:
  enum: [pending, passed, failed, skipped]

ReviewStatus:
  enum: [not_requested, requested, in_review, approved, changes_requested]

# Structured blocker (replaces plain string[] for inter-agent work)
Blocker:
  type: BlockerType
  description: string
  raisedBy?: string        # optional -- agent ID
  assignedTo?: string      # optional -- agent ID responsible for resolution
  raisedAt: string         # ISO 8601
  resolvedAt?: string      # optional -- ISO 8601
  resolution?: string      # optional -- how it was resolved

BlockerType:
  enum: [missing_info, architecture, security, performance, dependency, review, consensus, tooling, unknown]
```

> [!note] Backward Compatibility
> The `blockers` field accepts both `string[]` (legacy) and `Blocker[]` (structured). Agents should write structured blockers for inter-agent work but can fall back to plain strings for single-agent tasks.

### WorktreeState

```yaml
WorktreeState:
  worktrees: WorktreeEntry[]
  updatedAt: string        # ISO 8601 timestamp

WorktreeEntry:
  taskId: string           # "PROJ-42"
  moduleName: string       # "my-module"
  worktreePath: string     # "/tmp/proj-42"
  branchName: string       # "feature/proj-42"
  baseBranch: string       # "main"
  status: TaskStatus
  lastCommit: string       # short SHA
  lastCommitMsg?: string   # optional -- commit message
  createdAt: string        # ISO 8601
  updatedAt: string        # ISO 8601
```

### MemoryFile (frontmatter)

```yaml
MemoryFrontmatter:
  name: string             # descriptive name
  description: string      # one-line relevance hook
  type: MemoryType
  created: string          # ISO date (YYYY-MM-DD)
  updated: string          # ISO date (YYYY-MM-DD)
  related?: string[]       # optional -- wikilinks to related notes

MemoryType:
  enum: [user, feedback, project, reference]
```

### AgentConfig

```yaml
AgentConfig:
  agentId: string                 # "agent-{name}"
  model: string                   # primary model ID
  fallbackModel?: string          # optional -- fallback model ID
  maxConcurrentTasks: number      # default: 3
  defaultBranch: string           # "feature/{{taskId}}"
  worktreeIsolation: boolean      # default: true
  worktreeBase: string            # "/tmp"
  memory: MemoryConfig
  taskTracking: TaskTrackingConfig

MemoryConfig:
  fileBasedPath: string           # "{{memoryPath}}"
  deepMemoryEnabled: boolean      # default: true
  deepMemoryCmd?: string          # optional -- CLI command for Tier 2 backend
  autoMineOnComplete: boolean     # default: false
  wakeUpOnStart: boolean          # default: true
  maxMemoryIndexLines: number     # default: 200

TaskTrackingConfig:
  taskLogPath: string             # "agents/agent-{name}/projects/task-log.jsonl"
  worktreeStatePath: string       # "agents/agent-{name}/projects/worktree-state.json"
  autoSaveOnSwitch: boolean       # default: true
```

### SessionMetrics (self-improvement)

```yaml
SessionMetrics:
  sessionId: string                # "sess-2026-04-16-001"
  agentId: string                  # "agent-oracle-coding"
  startedAt: string                # ISO 8601
  endedAt: string                  # ISO 8601
  metrics:
    tasksAttempted: number
    tasksCompleted: number
    tasksFailed: number
    gatesPassed: number
    gatesFailed: number
    revisionCycles: number         # times work was revised before passing
    blockersRaised: number
    blockersResolved: number
    memoriesCreated: number
    memoriesUpdated: number
    memoriesRemoved: number
    handoffsInitiated: number
    handoffsReceived: number
    reviewsRequested: number
    reviewsCompleted: number
  blockerBreakdown: map<BlockerType, number>
  skillsUsed: string[]             # skill IDs from capabilities
  domainsActive: string[]          # expertise domains active this session
  discoveries: string[]            # key learnings (one-liners)
```

### SkillProgression (self-improvement)

```yaml
SkillProgression:
  skillId: string                  # "primary-skill"
  proficiency: Proficiency         # current level
  tasksCompleted: number           # total tasks using this skill
  tasksFailed: number
  successRate: number              # 0.0 - 1.0
  avgRevisionCycles: number
  lastUsed: string                 # ISO date
  lastProgression: string          # ISO date of last level change
  progressionHistory: ProgressionEvent[]

ProgressionEvent:
  from: Proficiency
  to: Proficiency
  date: string                     # ISO date
  evidence: string                 # why the change was justified

Proficiency:
  enum: [expert, advanced, intermediate, novice]
```

### RetroItem (self-improvement)

```yaml
RetroItem:
  category:
    enum: [went_well, to_improve, action_item]
  item: string                     # description
  tags: RetroTag[]
  severity?:                       # optional
    enum: [low, medium, high]
  actionOwner?: string             # optional -- agent ID (for action_items)
  targetDate?: string              # optional -- ISO date deadline (for action_items)
  resolvedBy?: string              # optional -- sprint/session where resolved
  memoryRef?: string               # optional -- reference to generated memory file

RetroTag:
  enum: [process, technical, collaboration, tooling, communication, architecture, security, performance]
```

### ObsidianFrontmatter (documentation files)

```yaml
ObsidianFrontmatter:
  title: string
  aliases?: string[]               # optional
  tags: string[]
  cssclasses?: string[]            # optional
```

### Inter-Agent Event Types

Standardized event names for multi-agent coordination. Events are emitted by agents and consumed by orchestrators or other agents. See [[interconnect/README|Interconnect]] for the full protocol.

```yaml
# Event envelope
AgentEvent:
  event: EventType
  emittedBy: string        # agent ID
  timestamp: string        # ISO 8601
  taskId?: string          # optional -- related task
  context?: map<string, any>  # optional -- event-specific data

EventType:
  enum:
    # Task lifecycle
    - task.started
    - task.completed
    - task.failed
    - task.blocked
    - task.unblocked
    - task.handed_off

    # Review
    - review.requested
    - review.completed
    - review.changes_requested

    # Wave orchestration
    - wave.started
    - wave.completed
    - wave.failed

    # Phase transitions
    - phase.transition

    # Consensus
    - consensus.proposed
    - consensus.vote_cast
    - consensus.reached
    - consensus.escalated

    # Blocker
    - blocker.raised
    - blocker.resolved
```

| Event | Emitted When | Key Context Fields |
|-------|-------------|-------------------|
| `task.started` | Agent begins work on a task | `taskId`, `branchName` |
| `task.completed` | Task passes verification gates | `taskId`, `filesChanged` |
| `task.failed` | Task cannot be completed | `taskId`, `reason` |
| `task.blocked` | Blocker identified | `taskId`, `blockerType`, `waitingFor` |
| `task.unblocked` | Blocker resolved | `taskId`, `resolution` |
| `task.handed_off` | Work transferred to another agent | `taskId`, `from`, `to`, `expectedOutput` |
| `review.requested` | Agent requests review from another | `taskId`, `requestedFrom`, `branchName` |
| `review.completed` | Review approved | `taskId`, `reviewedBy` |
| `review.changes_requested` | Review found issues | `taskId`, `reviewedBy`, `concerns` |
| `wave.started` | Wave begins execution | `waveNumber`, `taskCount` |
| `wave.completed` | All tasks in wave done | `waveNumber`, `completedCount` |
| `phase.transition` | Workflow phase changes | `from`, `to`, `triggeredBy` |
| `consensus.proposed` | Proposal submitted for vote | `proposalId`, `subject` |
| `consensus.vote_cast` | Agent casts a vote | `proposalId`, `vote`, `voter` |
| `consensus.reached` | Consensus achieved | `proposalId`, `outcome` |
| `consensus.escalated` | Cannot reach consensus | `proposalId`, `roundsCompleted` |
| `blocker.raised` | New blocker identified | `taskId`, `blockerType`, `raisedBy` |
| `blocker.resolved` | Blocker resolved | `taskId`, `resolvedBy`, `resolution` |

### Inter-Agent Message Types

```yaml
AgentMessage:
  messageId: string
  type: MessageType
  from: string             # agent ID
  to: string               # agent ID or "all"
  timestamp: string        # ISO 8601
  subject: string
  content: string
  references?: string[]    # optional -- related message/task IDs
  requiresResponse: boolean

MessageType:
  enum: [proposal, concern, question, agreement, objection, compromise, decision, handoff, status]

# Consensus voting
ConsensusVoteRecord:
  voteId: string
  proposalRef: string      # message ID of the proposal
  voter: string            # agent ID
  vote: ConsensusVote
  conditions?: string[]    # optional -- for approve_with_conditions
  rationale: string
  timestamp: string

ConsensusVote:
  enum: [approve, approve_with_conditions, request_changes, abstain]
```

### Tag Taxonomy

```
group/{group}           # organizational group (e.g., group/agents)
type/{type}             # document type (e.g., type/persona, type/skills)
role/{role}             # agent role (e.g., role/coding, role/qa)
capability/{cap}        # agent capability (e.g., capability/memory)
meta/{meta}             # meta-document (e.g., meta/template)
```

---

## Validation Checklist

Before committing agent profile files, verify:

- [ ] File names are `kebab-case.md`
- [ ] Directory names are `kebab-case/`
- [ ] JSON fields are `camelCase`
- [ ] YAML frontmatter fields are `lowercase`
- [ ] Placeholders use `{{camelCase}}` (double braces)
- [ ] Git branches use `type/kebab-case`
- [ ] Task IDs use `UPPER-N`
- [ ] Agent IDs use `agent-kebab-case`
- [ ] Commit messages use `Scope: action`
- [ ] Status enums match `TaskStatus` type
- [ ] Timestamps are ISO 8601
- [ ] No project-specific references in base template

### Format Validation

- [ ] Documentation files have YAML frontmatter (`title`, `aliases`, `tags`)
- [ ] Documentation files use wikilinks for cross-references
- [ ] `AGENTS.md` files have NO frontmatter, wikilinks, or callouts
- [ ] Callouts use only the approved palette (`abstract`, `tip`, `warning`, `example`, `note`, `danger`)
- [ ] Mermaid diagrams are focused (one concept, under 20 nodes)

### Neutrality Validation (for base template changes)

- [ ] No hardcoded LLM model IDs (use `{{primaryModel}}`, `{{fallbackModel}}`)
- [ ] No hardcoded tool/CLI names (use `{{deepMemoryCmd}}`, `{{verifyCmd}}`, etc.)
- [ ] No backend-specific language ("Claude will...", "Gemini supports...")
- [ ] All backend-varying config uses `{{camelCase}}` placeholders
- [ ] `AGENTS.md` is readable by any LLM backend
- [ ] Symlinks point to `AGENTS.md` (not copied/diverged files)
- [ ] Run `scripts/check-agent-neutrality.sh` -- 0 violations

---

## See Also

- [[README|Base Profile]] -- agent template
- [[interconnect/README|Interconnect]] -- inter-agent connectivity
- [[interconnect/capabilities|Capabilities]] -- skill and expertise declaration
- [[interconnect/coordination|Coordination]] -- consensus and decision-making
- [[neutrality|Neutrality]] -- backend-neutral cloning design
- [[trust-model|Trust Model]] -- external agent cloning security
- [[projects/README|Projects]] -- task tracking
- [[memories/README|Memories]] -- memory system
