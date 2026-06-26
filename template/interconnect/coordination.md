# Multi-Agent Coordination Protocol

## Roles & Permissions

| Agent | Role | Tool Access | Can Modify Files |
|-------|------|-------------|-----------------|
| อั่งเปา | Orchestrator | All tools | ✅ (coordination files only) |
| พายุ | Dev Lead | Edit,Write,Read,Bash,Glob,Grep | ✅ (code files) |
| โบนัส | Research Specialist | Read,Write,Bash,Glob,Grep,WebSearch,WebFetch | ✅ (research reports only — ห้าม Edit code) |
| ใต้ฝุ่น | QA Lead | Read,Bash,Glob,Grep | ❌ (read-only) |
| ติ่มซำ | UX/UI Designer | Edit,Write,Read,Bash,Glob,Grep | ✅ (UI files) |

---

## ⚠️ Routing Decision Rules (อั่งเปาต้องทำก่อน spawn ทุกครั้ง)

**กฎ: ก่อน spawn agent ใดๆ อั่งเปาต้องระบุ agent map ออกมาก่อนเสมอ**
ห้าม implicit routing — ต้องประกาศชัดว่าใครทำอะไร

### Route ไปโบนัส ถ้า request มีลักษณะเหล่านี้:
- คำถามเกี่ยวกับ technology/tools ภายนอก ("X คืออะไร", "A vs B", "best practices ของ Y")
- Trends, landscape, อัปเดตของวงการ ("อะไรใหม่", "ปี 2026 มีอะไร")
- ต้องการข้อมูลก่อนตัดสินใจ ("ควรใช้อะไร", "เปรียบเทียบ", "evaluate")
- ค้น pattern ใน codebase ("ใช้ที่ไหนบ้าง", "ไฟล์ไหนเกี่ยวข้อง", "archaeology")
- synthesis จาก docs หลายแหล่ง ("สรุป", "รวม", "compile")
- **อั่งเปา ห้าม WebSearch/WebFetch เอง** — ให้ spawn โบนัสเสมอ

### Route ไปพายุ ถ้า:
- Implement, build, fix, refactor code
- Architecture design, API design, DB schema
- Technical decisions ที่ต้องการ code output

### Route ไปใต้ฝุ่น ถ้า:
- Review code ที่เพิ่งเขียน (เสมอหลังพายุ/ติ่มซำเสร็จ)
- Quality gate, security audit, test strategy

### Route ไปติ่มซำ ถ้า:
- UI components, layout, design system
- Accessibility audit, UX flow

### Route หลายคน (Parallel) ถ้า:
- Feature ที่ต้องทำ BE + FE พร้อมกัน → พายุ + ติ่มซำ → ใต้ฝุ่น
- Research + Implement → โบนัส ก่อน → พายุ ต่อ

---

## Planning Gate (บังคับก่อนทุก spawn)

```
อั่งเปาต้องประกาศก่อนเสมอ:
"งานนี้จะ route:
 - โบนัส: [research task ถ้ามี]
 - พายุ: [dev task ถ้ามี]
 - ติ่มซำ: [UI task ถ้ามี]
 - ใต้ฝุ่น: [review หลังจาก ...]"
```

---

## Spawn Rule

**ใช้ Bash tool รัน `claude -p` เท่านั้น — ห้ามใช้ `Agent` tool ของ Claude Code**
เหตุผล: `claude -p` สร้าง OS subprocess จริง ทำให้ PIXEL AGENTS extension monitor ได้

---

## Spawn Patterns

### Pattern 1: Single Agent
```bash
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)

งาน: $TASK
ไฟล์: $FILES
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1
```

### Pattern 2: Research → Implement (โบนัส → พายุ)
```bash
# โบนัส research ก่อน
cd $PROJECT_PATH && claude -p "$(cat persona/researcher.md)
$(cat .claude/skills/planning-and-task-breakdown/SKILL.md)
งาน: $RESEARCH_QUESTION
ผลลัพธ์: เขียน report ลง research/$TOPIC.md
" --allowed-tools "Read,Write,Bash,Glob,Grep,WebSearch,WebFetch" 2>&1

# พายุ implement โดยใช้ research report
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)
$(cat .claude/skills/ponytail/SKILL.md)
Context จาก research: $(cat research/$TOPIC.md)
งาน: $IMPL_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1
```

### Pattern 3: Parallel Agents (BE + FE)
```bash
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)
งาน: $BACKEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
PHAYU_PID=$!

cd $PROJECT_PATH && claude -p "$(cat persona/uxui-designer.md)
งาน: $FRONTEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
TIMSUM_PID=$!

wait $PHAYU_PID && echo "✅ พายุ done"
wait $TIMSUM_PID && echo "✅ ติ่มซำ done"
```

### Pattern 4: Parallel with Worktrees (file isolation)
```bash
git worktree add .worktrees/phayu-work -b phayu/$FEATURE
git worktree add .worktrees/timsum-work -b timsum/$FEATURE

cd .worktrees/phayu-work && claude -p "$(cat ../../persona/dev-lead.md)
งาน: $BACKEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
PHAYU_PID=$!

cd .worktrees/timsum-work && claude -p "$(cat ../../persona/uxui-designer.md)
งาน: $FRONTEND_TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &
TIMSUM_PID=$!

wait $PHAYU_PID && wait $TIMSUM_PID
# รัน commands ต่อไปนี้จาก main repo directory
git merge phayu/$FEATURE timsum/$FEATURE
git worktree remove .worktrees/phayu-work
git worktree remove .worktrees/timsum-work
```

### Pattern 5: Sequential with Review
```bash
cd $PROJECT_PATH && claude -p "$(cat persona/dev-lead.md)
งาน: $TASK
" --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1

cd $PROJECT_PATH && claude -p "$(cat persona/qa-lead.md)
review: $CHANGED_FILES
" --allowed-tools "Read,Bash,Glob,Grep" 2>&1
```

---

## Task Log Schema
```json
{
  "taskId": "PROJ-1",
  "agent": "phayu|taifoon|timsum|angpao|bonus",
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
