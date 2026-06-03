# Sahagan Agent Template

Personal AI development workspace template — a multi-agent team with persistent memory, session tracking, and UI/UX intelligence built in.

**One init command. Ready-to-work ARIA team. Per-project isolation.**

---

## The Team

| Agent | Name | Role | Personality |
|-------|------|------|-------------|
| **Orchestrator** | ARIA | Project Lead / Manager | สาวผู้บริหารไฟแรง — วางแผน มอบหมาย review ทุก project |
| **Backend** | Kai | Senior Backend Developer | หนุ่ม BE ไฟแรง เก่งสุดในโลก — API, DB, auth, performance |
| **Frontend** | Nova | Senior Frontend Developer | สาว FE เด็กแต่ประสบการณ์เยอะ — UI/UX Pro Max built-in |
| **QA** | Sage | QA Engineering Lead | สาวแกร่ง ขี้สงสัย รู้ทุกซอกทุกมุม — ผ่านไม่ผ่านชี้ขาด |

Every session starts with ARIA. ARIA delegates to Kai, Nova, or Sage via the Agent tool.

---

## Quick Start — New Project

### Windows (PowerShell)

```powershell
# Clone template once (to use the scripts)
git clone https://github.com/Sahagan/sahagan_agent_template.git
cd sahagan_agent_template

# Init a new project
.\scripts\init-project.ps1 -ProjectName "my-project"

# With an existing project repo
.\scripts\init-project.ps1 -ProjectName "my-project" -RepoUrl "https://github.com/user/repo.git"

# Custom output location
.\scripts\init-project.ps1 -ProjectName "my-project" -RepoUrl "https://github.com/user/repo.git" -OutputDir "D:\projects"
```

### Mac / Linux (bash)

```bash
# Clone template once
git clone https://github.com/Sahagan/sahagan_agent_template.git
cd sahagan_agent_template

# Init a new project
bash scripts/init-project.sh my-project

# With an existing project repo
bash scripts/init-project.sh my-project https://github.com/user/repo.git

# Custom output location
bash scripts/init-project.sh my-project https://github.com/user/repo.git ~/projects
```

The script will:
1. Clone this template as `<project-name>/`
2. Remove the template's git history (clean slate)
3. Init a fresh git repo for the project
4. Clone your project repo into `projects/`
5. Open VS Code automatically

---

## Every Session: How to Work

### 1. Open the project folder in VS Code

```
File > Open Folder > ~/projects/my-project/
```

### 2. Start Claude Code, type `/session-start`

ARIA will:
- Load her memory and team context
- Check for any pending or in-progress tasks
- Report status and ask what you want to work on

### 3. Give ARIA the task

```
ทำ user authentication ให้หน่อย — JWT, refresh token, login/logout page
```

### 4. ARIA decomposes and delegates

ARIA uses `/assign` to break the task and route it:
- Kai → JWT backend + refresh token API
- Nova → Login/logout UI
- Sage → Security review + test coverage

### 5. Session end

Before closing, ARIA runs session-end protocol:
- Updates task log
- Saves discoveries to memory
- Gives you a 3-bullet summary

---

## Workspace Structure (per project)

```
my-project/                         ← Open this in VS Code
│
├── CLAUDE.md                       ← ARIA entry point (auto-loaded by Claude Code)
├── PROJECT.md                      ← Project info + setup notes
│
├── .claude/
│   ├── settings.json               ← Permissions + session hooks
│   ├── agents/
│   │   ├── backend.md              ← Kai definition (spawnable)
│   │   ├── frontend.md             ← Nova definition (spawnable)
│   │   └── qa.md                   ← Sage definition (spawnable)
│   └── skills/
│       ├── session-start/          ← /session-start
│       ├── session-end/            ← /session-end
│       ├── new-session/            ← /new-session <agent>
│       ├── assign/                 ← /assign <task>
│       ├── verify/                 ← /verify
│       ├── ui-ux-pro-max/          ← UI/UX design intelligence
│       ├── ui-styling/             ← Tailwind + shadcn patterns
│       ├── design/                 ← Logo, icon, CIP design
│       ├── design-system/          ← Design tokens
│       ├── brand/                  ← Brand guidelines
│       ├── slides/                 ← Presentation design
│       └── banner-design/          ← Banner sizes + styles
│
├── agents/
│   ├── orchestrator/
│   │   ├── persona.md              ← ARIA's identity + working principles
│   │   └── memories/
│   │       ├── MEMORY.md           ← Memory index (always loaded)
│   │       └── team-roster.md      ← Team reference
│   ├── backend/
│   │   ├── persona.md              ← Kai's identity
│   │   └── memories/MEMORY.md
│   ├── frontend/
│   │   ├── persona.md              ← Nova's identity + UI/UX Pro Max ref
│   │   └── memories/MEMORY.md
│   └── qa/
│       ├── persona.md              ← Sage's identity + quality gates
│       └── memories/MEMORY.md
│
├── _shared/
│   ├── messages.jsonl              ← Inter-agent messages + handoffs
│   ├── task-log.jsonl              ← Active task tracker
│   └── decisions/                  ← Architecture Decision Records (ADR)
│       └── README.md
│
└── projects/
    └── my-project-repo/            ← Your actual project code (git repo)
        └── (source code)
```

---

## Skills Reference

| Command | Who uses it | What it does |
|---------|-------------|--------------|
| `/session-start` | ARIA | Load memory, check tasks, report status |
| `/session-end` | ARIA | Persist discoveries, update task log, summarize |
| `/assign <task>` | ARIA | Decompose task + auto-route to right agents |
| `/new-session <agent>` | ARIA | Spawn Kai / Nova / Sage with a briefing |
| `/verify` | Any | Run verification checks |

### Agent Routing (Quick Reference)

| Task Type | Kai (BE) | Nova (FE) | Sage (QA) |
|-----------|----------|-----------|-----------|
| API endpoint | ✅ | — | ✅ review |
| UI component | — | ✅ | ✅ review |
| Full-stack feature | ✅ | ✅ | ✅ review |
| Database / migration | ✅ | — | ✅ review |
| Auth / security | ✅ | ✅ | ✅ review |
| Design system | — | ✅ | — |
| Bug fix | ✅ or ✅ | ✅ or ✅ | ✅ verify |
| Performance | ✅ or ✅ | ✅ or ✅ | ✅ verify |

---

## Multi-Project Workflow

### Project A and Project B — completely isolated

```
~/projects/
├── project-a/                 ← ARIA for project A (separate memory)
│   ├── CLAUDE.md
│   ├── agents/orchestrator/memories/MEMORY.md   ← project A context only
│   ├── _shared/task-log.jsonl                   ← project A tasks only
│   └── projects/project-a-repo/
│
└── project-b/                 ← ARIA for project B (separate memory)
    ├── CLAUDE.md
    ├── agents/orchestrator/memories/MEMORY.md   ← project B context only
    ├── _shared/task-log.jsonl                   ← project B tasks only
    └── projects/project-b-repo/
```

**Each project has its own:**
- ARIA memory (no cross-contamination)
- Task log and messages
- Agent memories (Kai/Nova/Sage)
- Architecture decisions

**To switch projects:** Just open a different folder in VS Code. `/session-start` loads that project's context automatically.

### Init project B while working on A

```powershell
# From anywhere — doesn't affect project A
.\scripts\init-project.ps1 -ProjectName "project-b" -RepoUrl "https://github.com/user/project-b.git"
```

---

## Memory System

Each agent has persistent memory that survives across sessions.

### Memory types

| Type | What it stores | Where |
|------|---------------|-------|
| **user** | Your preferences, expertise, working style | `agents/*/memories/` |
| **feedback** | What worked / what to avoid (with why) | `agents/*/memories/` |
| **project** | Goals, decisions, blockers, deadlines | `agents/*/memories/` |
| **reference** | External links, dashboards, repos | `agents/*/memories/` |

### Memory index format

Every `MEMORY.md` is under 200 lines. One entry per memory file:

```markdown
- [memory-name](memory-file.md) — one-line hook describing what's in it
```

### What NOT to save

- Code patterns (read the code)
- Git history (use `git log`)
- Debug recipes (fix is in the code)
- Current session's task details (use task-log.jsonl)

---

## Session State: `_shared/`

### `task-log.jsonl`

One JSON per line. Tracks all active tasks:

```json
{
  "taskId": "TASK-001",
  "title": "Implement user authentication",
  "assignedTo": "kai-backend",
  "status": "in_progress",
  "handoffFrom": "aria-orchestrator",
  "startedAt": "2026-06-03T10:00:00Z",
  "expectedOutput": "POST /auth/login + POST /auth/refresh + tests"
}
```

Status values: `pending` | `in_progress` | `blocked` | `complete` | `failed`

### `messages.jsonl`

Inter-agent communication log:

```json
{
  "messageId": "msg-001",
  "type": "handoff",
  "from": "aria-orchestrator",
  "to": "kai-backend",
  "timestamp": "2026-06-03T10:00:00Z",
  "subject": "Implement JWT auth",
  "taskId": "TASK-001",
  "requiresResponse": true
}
```

Message types: `handoff` | `proposal` | `question` | `approval` | `request_changes` | `status`

### `decisions/`

Architecture Decision Records (ADR) for important choices:

```
decisions/
├── adr-001-auth-strategy.md
└── adr-002-db-schema.md
```

---

## UI/UX Pro Max (Nova's Toolkit)

Nova has access to a design intelligence database. Search it before building any UI:

```bash
# ค้นหา UI style
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "glassmorphism dashboard" --domain style

# ค้นหา color palette
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "SaaS product" --domain color

# ค้นหา typography
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "modern sans serif" --domain typography

# ค้นหาตาม stack
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "hero section" --stack nextjs

# Domains: product | style | typography | color | landing | chart | ux
# Stacks: react | nextjs | vue | nuxtjs | svelte | shadcn | html-tailwind
```

---

## Quality Gates

Sage enforces these before any task is marked complete:

| Gate | Requirement |
|------|------------|
| Unit tests | ≥ 80% coverage on changed files |
| Integration tests | All API contracts verified |
| Security | Zero OWASP Top 10 violations |
| Accessibility | WCAG 2.1 AA (FE work) |
| Performance | No regression vs baseline |
| E2E | Golden path + 3 error paths pass |

---

## Updating the Template

When a new version of `sahagan_agent_template` is released:

```bash
# In your existing project — pull template updates manually for specific files
# (Don't overwrite your agent memories!)

# Or re-init for new projects (new projects always get the latest)
bash scripts/init-project.sh new-project https://github.com/user/repo.git
```

---

## Template Source

**GitHub:** https://github.com/Sahagan/sahagan_agent_template  
**Base template:** https://github.com/kla-ondemand/atlas-agent-oracle-template (forked, heavily extended)  
**UI/UX skill:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill (integrated)
