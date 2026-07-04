# sahagan-agents-workflow 🐱

[![npm version](https://img.shields.io/npm/v/sahagan-agents-workflow.svg)](https://www.npmjs.com/package/sahagan-agents-workflow) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![npm downloads](https://img.shields.io/npm/dm/sahagan-agents-workflow.svg)](https://www.npmjs.com/package/sahagan-agents-workflow)

Multi-agent workflow template for **Claude Code** and **OpenAI Codex** — a family of five cat agents working together as a coordinated team.

## The Family

| Agent | Name | Role |
|-------|------|------|
| Orchestrator | **Angpao** (อั่งเปา) | Coordinates, spawns agents, sees the big picture |
| Dev Lead | **Phayu** (พายุ) | Architecture, implementation, code review |
| QA Lead | **Taifoon** (ใต้ฝุ่น) | Quality gate, test strategy, review |
| UX/UI Designer | **Timsum** (ติ่มซำ) | UI design, design system, accessibility |
| Research Specialist | **Bonus** (โบนัส) | Web research, planning breakdown, structured reports |

![PIXEL AGENTS — agents working in VS Code](.github/assets/pixel-agents-demo.png)
*Agents visible in [PIXEL AGENTS](https://marketplace.visualstudio.com/items?itemName=sahagan.pixel-agents) VS Code extension — each sub-agent appears as a pixel character in your office layout*

---

## Install

```bash
npm install -g sahagan-agents-workflow
```

---

## Quick Start

```bash
aw init my-app          # 1. Create workspace
# 2. Open my-app.code-workspace in VS Code
# 3. Run /session-start — Angpao is ready
```

---

## CLI Commands

### `aw init <project-name> [parent-dir]`

Create a new agents-workflow workspace.

```bash
aw init my-app
aw init my-app D:\working
```

**What it does:**
- Prompts for language and AI tool
- Copies the bundled template (no internet required)
- Installs `CLAUDE.md` and/or `AGENTS.md` based on your tool choice
- Applies language directive to all instruction files
- Installs all agent skills from GitHub
- Creates a VS Code `.code-workspace` file
- Initializes a local git repo

**Output:**
```
workspace-my-app/
├── my-app.code-workspace   ← open this in VS Code
└── agents-workflow/
```

---

### `aw upgrade [agents-workflow-path]`

Upgrade an existing workspace with the template bundled in the currently installed package.

```bash
aw upgrade                              # run from inside agents-workflow/
aw upgrade D:\working\workspace-my-app  # or pass path to workspace
```

**What it does:**
- **Checks npm for a newer package version; if it installs one, rerun `aw upgrade`**
- Smart-diffs bundled template files against the workspace
- Backs up only changed existing files before overwriting them
- Adds missing bundled template files
- Re-installs all skills to their latest versions
- Commits the upgrade with a descriptive message

| Item | Action |
|------|--------|
| Bundled template files | ✅ Added or updated when different |
| Changed existing files | 💾 Backed up before overwrite |
| All skills | ✅ Re-installed from GitHub (latest) |

**What it preserves (user data):**

| Item | Action |
|------|--------|
| `memories/` | 🔒 Never touched |
| `projects/task-log.jsonl` | 🔒 Never touched |
| `PROJECT.md` | 🔒 Never touched |
| `context/session-state.json` | 🔒 Never touched |

Template-managed files, including files under `interconnect/`, may be updated when the bundled template differs. A backup of changed existing files is saved to `.upgrade-backup-{timestamp}/` before they are overwritten.

---

### `aw help`

Show the full help page with all commands, prompts, and installed skills.

```bash
aw help
```

---

## CLI Prompts

Both `init` and `upgrade` ask two questions:

**1. Language**
```
🌐 เลือกภาษา / Choose language:
  [1] ภาษาไทย (Thai)
  [2] English
```

Choosing English prepends a language directive to every instruction and persona file so all agents respond in English.

**2. AI Tool**
```
🤖 Choose AI tool:
  [1] Claude Code (Anthropic) — default
  [2] Codex (OpenAI)
  [3] Both (Claude Code + Codex)
```

| Choice | Files installed | Spawn command |
|--------|----------------|---------------|
| Claude Code | `CLAUDE.md` | `claude -p "..." --allowed-tools "..."` |
| Codex | `AGENTS.md` | `codex --approval-mode full-auto "..."` |
| Both | both files | either tool |

---

## Getting Started

### Claude Code

1. Open `my-app.code-workspace` in VS Code
2. Claude Code loads `CLAUDE.md` → **Angpao is ready**
3. Run `/session-start`
4. Give tasks in natural language
5. Run `/session-end` when done

### Codex

1. Open `my-app.code-workspace` in VS Code
2. Open a terminal in the `agents-workflow/` directory
3. Run `codex` — it reads `AGENTS.md` → **Angpao is ready**
4. Session start runs automatically on launch
5. Type `session end` to close the session

### Both

Use Claude Code in the IDE and Codex in the terminal simultaneously — both share the same persona files and memory.

---

## How Agents Work

Angpao is the orchestrator. When a task arrives, Angpao:

1. Reads `context/session-state.json` for current project state
2. Breaks the task down using `planning-and-task-breakdown`
3. Spawns specialist agents as **real OS subprocesses** via `claude -p` or `codex`
4. Collects JSON summary blocks from each agent
5. Updates session state and task log

Each spawned agent is a separate process — visible in your task manager and in the [PIXEL AGENTS](https://marketplace.visualstudio.com/items?itemName=sahagan.pixel-agents) VS Code extension as a pixel character in your office layout.

---

## Spawn Patterns

Angpao orchestrates agents using the patterns below. All examples assume you're inside the `agents-workflow/` directory.

### Basic Sequential (Phayu → Taifoon)

```bash
# Step 1: Phayu implements
claude -p "$(cat persona/dev-lead.md)
Task: implement user auth" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"

# Step 2: Taifoon reviews
claude -p "$(cat persona/qa-lead.md)
$(cat .claude/skills/code-review-and-quality/SKILL.md)
$(cat .claude/skills/security-and-hardening/SKILL.md)
Review: src/auth/" \
  --allowed-tools "Read,Bash,Glob,Grep"
```

### Phayu — Spawn Patterns (3 Modes)

Select the pattern that matches the task — never inject both skills simultaneously.

**Pattern A — API / Interface Design**
```bash
claude -p "$(cat persona/dev-lead.md)
$(cat .claude/skills/api-and-interface-design/SKILL.md)
Task: design REST endpoints for user management" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"
```

**Pattern B — Debug / Bug Fix**
```bash
claude -p "$(cat persona/dev-lead.md)
$(cat .claude/skills/debugging-and-error-recovery/SKILL.md)
Task: debug JWT refresh token expiry issue" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"
```

**Pattern C — General Implementation**
```bash
claude -p "$(cat persona/dev-lead.md)
Task: refactor auth module" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"
```

### Basic Parallel (Phayu + Timsum)

```bash
# Fire both simultaneously — independent tasks
claude -p "$(cat persona/dev-lead.md)
Task: build API endpoints" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" &

claude -p "$(cat persona/uxui-designer.md)
$(cat .claude/skills/ui-ux-pro-max/SKILL.md)
Task: design login form" \
  --allowed-tools "Edit,Write,Read,Bash" &

wait
```

### Parallel with Git Worktrees (File Isolation)

When parallel agents touch overlapping files, use git worktrees so each agent works on its own branch:

```bash
# Create isolated branches per agent
git worktree add ../wt-phayu  -b feat/phayu-auth
git worktree add ../wt-timsum -b feat/timsum-login-ui

# Spawn agents in their own worktrees
(cd ../wt-phayu  && claude -p "$(cat persona/dev-lead.md)
Task: implement auth" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep") &

(cd ../wt-timsum && claude -p "$(cat persona/uxui-designer.md)
Task: build login UI" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep") &

wait

# Merge branches when done
git merge feat/phayu-auth
git merge feat/timsum-login-ui

# Clean up worktrees
git worktree remove ../wt-phayu
git worktree remove ../wt-timsum
```

### Error Recovery (spawn_agent wrapper)

```bash
spawn_agent() {
  local name="$1" prompt="$2" tools="$3" retries="${4:-2}"
  for i in $(seq 1 $((retries + 1))); do
    if claude -p "$prompt" --allowed-tools "$tools"; then
      return 0
    fi
    echo "⚠️ $name failed (attempt $i/$((retries + 1))), retrying..."
    sleep 2
  done
  echo "❌ $name failed after $((retries + 1)) attempts"
  return 1
}

spawn_agent "Phayu" "$(cat persona/dev-lead.md)
Task: refactor auth module" "Edit,Write,Read,Bash,Glob,Grep"
```

### Shared Session State

All agents read a shared JSON file before starting so they have full context:

```bash
# Angpao writes task assignments
cat > context/session-state.json << 'EOF'
{
  "session": "2026-06-26",
  "task": "user authentication",
  "assignments": {
    "phayu": "implement JWT refresh rotation in src/auth/",
    "taifoon": "review security of src/auth/ after Phayu is done",
    "timsum": "design login form components in src/components/"
  },
  "sharedContext": {
    "techStack": ["Next.js", "PostgreSQL", "Redis"],
    "constraints": ["no new deps", "tests required"]
  }
}
EOF

# Inject session state into each agent's prompt
STATE=$(cat context/session-state.json)
claude -p "$(cat persona/dev-lead.md)
Session state: $STATE
Task: implement JWT refresh rotation" \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"
```

### Bonus Research Spawn

Bonus uses WebSearch and WebFetch to gather information before the team implements:

```bash
# Spawn Bonus with MCP web tools
claude -p "$(cat persona/researcher.md)
$(cat .claude/skills/planning-and-task-breakdown/SKILL.md)
Research: best practices for JWT refresh token rotation in 2025.
Return a structured markdown report with sources." \
  --allowed-tools "Read,Write,WebSearch,WebFetch,Bash" \
  --mcp-config mcp-researcher.json.example
```

### Structured Agent Output

Every agent closes with a JSON summary block so Angpao can parse results:

```json
{
  "agent": "phayu",
  "taskId": "auth-001",
  "status": "done",
  "filesChanged": ["src/auth/jwt.ts", "src/auth/refresh.ts"],
  "summary": "Implemented JWT refresh rotation with Redis-backed token store",
  "nextSteps": ["taifoon: security review of src/auth/", "deploy to staging"]
}
```

---

## Installed Skills

Each agent is automatically equipped with skills from the most popular open-source skill repositories:

| Agent | Skill | Repo | Stars |
|-------|-------|------|-------|
| Angpao (Orchestrator) | `planning-and-task-breakdown` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Taifoon (QA) | `code-review-and-quality` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Taifoon (QA) | `security-and-hardening` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Phayu (Dev) | `api-and-interface-design` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Phayu (Dev) | `debugging-and-error-recovery` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Timsum (UX/UI) | `ui-ux-pro-max` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | ⭐ 93k |
| Bonus (Research) | `planning-and-task-breakdown` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |

Skills are injected into each agent's prompt at spawn time via `$(cat .claude/skills/<name>/SKILL.md)`.

---

## Session Skills (Claude Code)

| Command | What it does |
|---------|-------------|
| `/session-start` | Load memory, check task log, report context — Angpao is ready |
| `/session-end` | Update task log, save memory, improve template from lessons learned |
| `/initproject` | Create a new project workspace from within Claude Code |

**Codex equivalent:** Session start runs automatically when `codex` launches (AGENTS.md instructions). Type `session end` / `end session` to trigger the end protocol.

---

## Project Structure

```
workspace-my-app/
├── my-app.code-workspace
└── agents-workflow/
    ├── CLAUDE.md                    ← Angpao's instructions for Claude Code
    ├── AGENTS.md                    ← Angpao's instructions for Codex
    ├── PROJECT.md                   ← project info & tech stack
    ├── persona/
    │   ├── orchestrator.md
    │   ├── dev-lead.md              ← API design & debugging skill patterns
    │   ├── qa-lead.md               ← includes Review & Security skill references
    │   ├── uxui-designer.md
    │   └── researcher.md            ← Bonus: web research + structured reports
    ├── context/
    │   └── session-state.template.json  ← shared state template for all agents
    ├── mcp-researcher.json.example  ← MCP config for Bonus's web tools
    ├── .claude/
    │   └── skills/
    │       ├── planning-and-task-breakdown/
    │       ├── code-review-and-quality/
    │       ├── security-and-hardening/
    │       ├── api-and-interface-design/
    │       ├── debugging-and-error-recovery/
    │       └── ui-ux-pro-max/
    ├── memories/
    │   └── MEMORY.md                ← persisted across sessions
    ├── projects/
    │   └── task-log.jsonl           ← task tracking
    └── interconnect/                ← agent coordination config
```

---

## Requirements

- **Node.js** ≥ 18
- **Git** — for skill installation and repo init
- **claude** CLI — [Claude Code](https://claude.ai/code) (Claude Code mode)
- **codex** CLI — [OpenAI Codex](https://github.com/openai/codex) (Codex mode)
