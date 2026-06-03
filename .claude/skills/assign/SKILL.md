---
name: assign
description: Decompose a task and assign to the right agent(s). ARIA analyzes the task and routes to backend/frontend/qa automatically.
when_to_use: When user gives a task and ARIA needs to figure out which agent(s) should handle it
user-invocable: true
---

# Assign — Decompose & Route Task

ใช้เมื่อ user ให้ task และ ARIA ต้องวิเคราะห์ว่าจะมอบหมายให้ agent ไหน

## Usage

```
/assign <task description>
```

## Protocol

### Step 1: Analyze the task

ถาม 4 คำถามนี้:
1. มี server-side logic / API / DB / auth หรือไม่? → **Kai**
2. มี UI / component / styling / FE state หรือไม่? → **Nova**
3. ต้องการ testing / review / security check หรือไม่? → **Sage** (เกือบทุก task)
4. มี dependency ระหว่าง agents หรือไม่? → กำหนด order

### Step 2: Create execution plan

```markdown
## Execution Plan: [Task Title]

**Task ID:** TASK-[number]
**Requested by:** User
**Complexity:** simple | medium | complex

### Breakdown

| # | Subtask | Agent | Depends on | Est. |
|---|---------|-------|------------|------|
| 1 | [desc]  | Kai   | —          | —    |
| 2 | [desc]  | Nova  | #1         | —    |
| 3 | [desc]  | Sage  | #1, #2     | —    |

### Execution Order
[sequential / parallel / mixed — explain why]

### Definition of Done
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] QA approved
```

### Step 3: Get user approval (for complex tasks)

ถ้า task มี complexity = **complex** หรือมี architecture decision:
- Present the plan to user
- Wait for approval before spawning agents
- ถ้า **simple/medium**: proceed automatically

### Step 4: Execute plan

สำหรับแต่ละ subtask ตาม order ที่กำหนด:
1. Use `/new-session <agent>` skill to spawn the agent
2. Wait for result
3. Review → approve or request_changes
4. Proceed to next subtask

### Step 5: Final QA gate

หลังจาก implementation agents เสร็จ:
- ถ้ายังไม่ได้ spawn Sage: `/new-session qa` เสมอ
- Sage's approval = required before task is `complete`

### Step 6: Report to user

```markdown
## Task Complete: [Task Title]

**Status:** ✓ Complete
**Agents used:** Kai, Nova, Sage

### What was done:
- [brief summary per agent]

### Files changed:
- [list]

### QA Result:
- [Sage's verdict]
```

## Routing Guide (Quick Reference)

| Task Type | Primary | Secondary | QA |
|-----------|---------|-----------|-----|
| New API endpoint | Kai | — | Sage |
| New UI component | Nova | — | Sage |
| Full-stack feature | Kai → Nova | — | Sage |
| Bug fix (BE) | Kai | — | Sage |
| Bug fix (FE) | Nova | — | Sage |
| Performance issue | Kai or Nova | — | Sage |
| Security audit | — | — | Sage |
| Design system | Nova | — | — |
| DB migration | Kai | — | Sage |
| Auth/Auth flow | Kai | Nova | Sage |

## Example

```
/assign Add user profile page with avatar upload
```

ARIA will decompose as:
1. Kai: `POST /api/users/:id/avatar` endpoint + storage
2. Nova: Profile page component + upload UI
3. Sage: Integration tests + security review (file upload)
