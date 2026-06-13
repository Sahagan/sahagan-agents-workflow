# Multi-Agent Coordination Protocol

## Roles & Permissions

| Agent | Role | Tool Access | Can Modify Files |
|-------|------|-------------|-----------------|
| อั่งเปา | Orchestrator | All tools | ✅ (coordination files only) |
| พายุ | Dev Lead | Edit,Write,Read,Bash,Glob,Grep | ✅ (code files) |
| ใต้ฝุ่น | QA Lead | Read,Bash,Glob,Grep | ❌ (read-only) |
| ติ่มซำ | UX/UI Designer | Edit,Write,Read,Bash,Glob,Grep | ✅ (UI files) |

## Spawn Patterns

### Pattern 1: Single Agent
```bash
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)

งาน: $TASK
ไฟล์: $FILES
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1
```

### Pattern 2: Parallel Agents
```bash
# Agent 1 background
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)
งาน: $BACKEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
PHAYU_PID=$!

# Agent 2 background  
cd $PROJECT_PATH && claude -p "$(cat persona/uxui-designer.md)
งาน: $FRONTEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
TIMSUM_PID=$!

wait $PHAYU_PID
wait $TIMSUM_PID
```

### Pattern 3: Sequential with Review
```bash
# Dev implement
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)
งาน: $TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1

# QA review after
cd $PROJECT_PATH && claude -p "$(cat persona/qa-lead.md)
review: $CHANGED_FILES
" --allowed-tools "Read,Bash,Glob,Grep" 2>&1
```

## Task Log Schema
```json
{
  "taskId": "PROJ-1",
  "agent": "phayu|taifoon|timsum|angpao",
  "status": "pending|in_progress|blocked|completed|failed",
  "task": "description",
  "files": ["path/to/file"],
  "startedAt": "ISO timestamp",
  "completedAt": "ISO timestamp",
  "blockers": [{"type": "string", "description": "string"}],
  "verificationGate": "pending|passed|failed",
  "qaApproved": false
}
```

## Conflict Resolution
เมื่อ agents เห็นไม่ตรงกัน:
1. อั่งเปา รับ feedback จากทั้งสองฝ่าย
2. พิจารณา user requirements เป็นหลัก
3. อั่งเปา ตัดสินใจขั้นสุดท้าย
4. Document decision ใน memory
