---
name: new-session
description: Spawn a new agent session for a specific team member (backend, frontend, or qa)
when_to_use: When ARIA needs to delegate work to Kai (BE), Nova (FE), or Sage (QA)
user-invocable: true
---

# New Session — Spawn Agent

ใช้ spawn agent session ใหม่สำหรับ Kai, Nova, หรือ Sage

## Usage

```
/new-session <agent> [task brief]

/new-session backend   — spawn Kai (Backend Developer)
/new-session frontend  — spawn Nova (Frontend Developer)
/new-session qa        — spawn Sage (QA Engineer)
```

## Protocol

When invoked, follow these steps:

### 1. Validate agent name
- `backend` → Kai (`kai-backend`) — `.claude/agents/backend.md`
- `frontend` → Nova (`nova-frontend`) — `.claude/agents/frontend.md`
- `qa` → Sage (`sage-qa`) — `.claude/agents/qa.md`
- ถ้า name ไม่ตรง: แจ้ง user และแสดง valid options

### 2. Prepare briefing document
สร้าง brief ที่ agent ต้องการ:

```markdown
## Task Brief for [Agent Name]

**From:** ARIA
**To:** [Agent Name]
**Task ID:** [task-id or generate one]
**Priority:** [high | medium | low]

### Context
[อธิบาย background + why this task matters]

### What to Do
[specific requirements — not vague instructions]

### Files Relevant
- [list specific files or directories]

### API Contracts
- [list endpoints or schemas if applicable]

### Expected Output
- [exact deliverables — files, test results, reports]

### Verification Gate
- [what the agent must pass before reporting done]

### Deadline / Notes
- [any constraints or important info]
```

### 3. Log handoff in `_shared/messages.jsonl`
```json
{
  "messageId": "msg-[timestamp]",
  "type": "handoff",
  "from": "aria-orchestrator",
  "to": "[agent-id]",
  "timestamp": "[ISO timestamp]",
  "subject": "[task summary]",
  "content": "[brief summary of what's being handed off]",
  "taskId": "[task-id]",
  "requiresResponse": true
}
```

### 4. Update `_shared/task-log.jsonl`
```json
{
  "taskId": "[task-id]",
  "title": "[task title]",
  "assignedTo": "[agent-id]",
  "status": "in_progress",
  "handoffFrom": "aria-orchestrator",
  "startedAt": "[ISO timestamp]",
  "expectedOutput": "[description]"
}
```

### 5. Spawn the agent using Agent tool
Use the Agent tool with:
- `subagent_type`: use agent's name (e.g., `kai-backend`, `nova-frontend`, `sage-qa`)
- `prompt`: the briefing document prepared in step 2

### 6. After agent completes
- Review agent's output against expected output
- Check if verification gate was passed
- If approved: update task-log status to `complete`
- If needs changes: log `request_changes` message and re-spawn
- If blocked: escalate to user

## Example

```
/new-session backend "Implement POST /api/users endpoint with email validation"
```

ARIA will:
1. Create task brief for Kai
2. Log handoff in messages.jsonl
3. Update task-log
4. Spawn Kai via Agent tool
5. Review Kai's output when done
