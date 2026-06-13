# agents-workflow 🐱

Multi-agent workflow template สำหรับ Claude Code — ใช้ภายในบริษัทเท่านั้น

ประกอบด้วยครอบครัวแมว 4 ตัว ที่ทำงานร่วมกันเป็นทีม:

| Agent | ชื่อ | บทบาท | บุคลิก |
|-------|------|--------|--------|
| Orchestrator | **อั่งเปา** | ประสานงาน, spawn agents, มองภาพรวม | สงบนิ่ง เด็ดขาด หัวหน้าครอบครัว |
| Dev Lead | **พายุ** | Architecture, implementation, code review | Pragmatic รัก clean code ลูกชายอั่งเปา |
| QA Lead | **ใต้ฝุ่น** | Quality gate, test strategy, review | Skeptical methodical ภรรยาอั่งเปา |
| UX/UI Designer | **ติ่มซำ** | UI design, design system, accessibility | Perfectionist user-first ลูกสาวอั่งเปา |

---

## วิธีการ Init Project

### Prerequisites
- [Claude Code](https://claude.ai/code)
- Git
- (optional) [gh CLI](https://cli.github.com) สำหรับสร้าง GitHub repo

### ขั้นตอน

**1. Clone template นี้มาเครื่อง (ครั้งเดียว)**
```bash
git clone git@github.com-work:sahaganN/agents-workflow.git
cd agents-workflow
```

**2. เปิดใน Claude Code แล้วรัน:**
```
/initproject <ชื่อ-project>
```

ตัวอย่าง:
```
/initproject my-company-app
```

หรือใช้ shell script โดยตรง:
```bash
./scripts/initproject.sh my-company-app [target-dir]
```

---

## ผลลัพธ์หลัง initproject

คำสั่งนี้จะสร้าง **VS Code Workspace** ดังนี้:

```
workspace-my-company-app/
├── my-company-app.code-workspace   ← เปิดไฟล์นี้ใน VS Code
└── agents-workflow/                 ← Template (fresh clone, ไม่มี git history)
    ├── CLAUDE.md                    ← อั่งเปา
    ├── PROJECT.md                   ← project info
    ├── persona/                     ← personality ของแต่ละ agent
    ├── memories/                    ← project memory
    ├── projects/                    ← task tracking
    └── .claude/
        ├── agents/                  ← พายุ, ใต้ฝุ่น, ติ่มซำ
        ├── skills/
        │   ├── session-start/
        │   ├── session-end/
        │   └── ui-ux-pro-max/       ← ติ่มซำ ใช้เสมอ
        └── settings.json
```

> Template อยู่ใน `agents-workflow/` folder เดียว — user สามารถ **Add Folder to Workspace** เพื่อเพิ่ม project repos ได้เลย ทีมจะทำงานกับ project folders เหล่านั้นได้ทันที

---

## วิธีการทำงาน (Daily Workflow)

```
1. เปิด .code-workspace ใน VS Code + Claude Code

2. รัน /session-start
   → อั่งเปา โหลด memory, สรุป pending tasks

3. สั่งงาน (ภาษาไทยหรืออังกฤษ)
   → อั่งเปา วิเคราะห์ + plan
   → spawn พายุ (dev) และ/หรือ ติ่มซำ (ui) แบบ parallel
   → รอให้เสร็จ → spawn ใต้ฝุ่น (qa review)
   → สรุปผลให้ user

4. รัน /session-end
   → อั่งเปา สรุปงาน + บันทึก lessons
   → template ในเครื่องถูก improve อัตโนมัติ (local only, ไม่ push)
```

---

## หลักการสำคัญ

### Template เรียนรู้ได้ (Local Learning)
- ทุก `/session-end` → lessons learned บันทึกลง template ในเครื่อง
- Template ดีขึ้นเรื่อยๆ จาก context ของ project คุณเอง
- **ไม่มีการ commit กลับ git** — การพัฒนา template เป็น local only
- Template ที่ init มาใหม่จะ "สะอาด" เสมอ (fresh start)

### Multi-Agent ทำงานแบบ Parallel
```bash
# อั่งเปา spawn agents ผ่าน claude CLI
claude -p "$(cat persona/dev-lead.md) ..." \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &

claude -p "$(cat persona/uxui-designer.md) ..." \
  --allowed-tools "Edit,Write,Read,Bash,Glob,Grep" 2>&1 &

wait  # รอทั้งคู่

# QA review หลัง dev เสร็จ
claude -p "$(cat persona/qa-lead.md) ..." \
  --allowed-tools "Read,Bash,Glob,Grep" 2>&1
```

---

## Skills

| Command | ทำอะไร |
|---------|--------|
| `/session-start` | เริ่ม session, อั่งเปาโหลด context และ memory |
| `/session-end` | ปิด session, บันทึก lessons, improve template |
| `/initproject <name>` | สร้าง workspace + template ใหม่ |
