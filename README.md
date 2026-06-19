# sahagan-agents-workflow 🐱

[![npm version](https://img.shields.io/npm/v/sahagan-agents-workflow.svg)](https://www.npmjs.com/package/sahagan-agents-workflow) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![npm downloads](https://img.shields.io/npm/dm/sahagan-agents-workflow.svg)](https://www.npmjs.com/package/sahagan-agents-workflow)

Multi-agent workflow template for **Claude Code** and **OpenAI Codex**.

A family of four cat agents working together as a team:

| Agent | Name | Role |
|-------|------|------|
| Orchestrator | **Angpao** (อั่งเปา) | Coordinates, spawns agents, sees the big picture |
| Dev Lead | **Phayu** (พายุ) | Architecture, implementation, code review |
| QA Lead | **Taifoon** (ใต้ฝุ่น) | Quality gate, test strategy, review |
| UX/UI Designer | **Timsum** (ติ่มซำ) | UI design, design system, accessibility |

![PIXEL AGENTS — agents working in VS Code](.github/assets/pixel-agents-demo.png)
*Agents visible in [PIXEL AGENTS](https://marketplace.visualstudio.com/items?itemName=sahagan.pixel-agents) VS Code extension — each sub-agent appears as a pixel character in your office layout*

---

## Install

```bash
npm install -g sahagan-agents-workflow
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

Upgrade an existing workspace to the latest template version.

```bash
aw upgrade                              # run from inside agents-workflow/
aw upgrade D:\working\workspace-my-app  # or pass path to workspace
```

**What it updates:**
| Item | Action |
|------|--------|
| `persona/*.md` | ✅ Overwritten with latest |
| `CLAUDE.md` / `AGENTS.md` | ✅ Overwritten with latest |
| All skills | ✅ Re-installed from GitHub (latest) |

**What it preserves (user data):**
| Item | Action |
|------|--------|
| `memories/` | 🔒 Never touched |
| `projects/task-log.jsonl` | 🔒 Never touched |
| `PROJECT.md` | 🔒 Never touched |
| `interconnect/` | 🔒 Never touched |

A backup of overwritten files is saved to `.upgrade-backup-{timestamp}/` before any changes are made.

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

## Installed Skills

Each agent is automatically equipped with skills from the most popular open-source skill repositories:

| Agent | Skill | Repo | Stars |
|-------|-------|------|-------|
| Angpao (Orchestrator) | `planning-and-task-breakdown` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Taifoon (QA) | `code-review-and-quality` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Taifoon (QA) | `security-and-hardening` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | ⭐ 62k |
| Phayu (Dev) | `ponytail` + `ponytail-review` + `ponytail-audit` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | ⭐ 36k |
| Timsum (UX/UI) | `ui-ux-pro-max` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | ⭐ 93k |

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

## How Agents Are Spawned

Angpao spawns sub-agents as real OS subprocesses — visible to monitoring tools:

**Claude Code:**
```bash
# Dev Lead (Phayu) — with Ponytail skill
claude -p "$(cat persona/dev-lead.md)
$(cat .claude/skills/ponytail/SKILL.md)
Task: {{task}}" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep"

# QA Lead (Taifoon) — read-only with review + security skills
claude -p "$(cat persona/qa-lead.md)
$(cat .claude/skills/code-review-and-quality/SKILL.md)
$(cat .claude/skills/security-and-hardening/SKILL.md)
Review: {{files}}" --allowed-tools "Read,Bash,Glob,Grep"
```

**Codex:**
```bash
# Dev Lead
codex --approval-mode full-auto "$(cat persona/dev-lead.md)
$(cat .claude/skills/ponytail/SKILL.md)
Task: {{task}}"

# QA Lead — suggest mode prevents auto-apply
codex --approval-mode suggest "$(cat persona/qa-lead.md)
$(cat .claude/skills/code-review-and-quality/SKILL.md)
$(cat .claude/skills/security-and-hardening/SKILL.md)
Review: {{files}}"
```

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
    │   ├── dev-lead.md              ← includes Ponytail skill reference
    │   ├── qa-lead.md               ← includes Review & Security skill references
    │   └── uxui-designer.md
    ├── .claude/
    │   └── skills/
    │       ├── planning-and-task-breakdown/
    │       ├── code-review-and-quality/
    │       ├── security-and-hardening/
    │       ├── ponytail/
    │       ├── ponytail-review/
    │       ├── ponytail-audit/
    │       ├── ponytail-debt/
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
