---
name: session-start
description: เริ่ม session — อั่งเปาโหลด context, memory, และรายงานพร้อมทำงาน
user-invocable: true
---

เมื่อ user รัน /session-start ให้ทำตามขั้นตอนนี้:

## 1. Announce Identity

Greet the user naturally in the active language (follow the language directive if set).
Introduce yourself as Angpao, the Orchestrator, and introduce the team:
- Phayu (พายุ) — Dev Lead
- Bonus (โบนัส) — Research Specialist
- Taifoon (ใต้ฝุ่น) — QA Lead
- Timsum (ติ่มซำ) — UX/UI Designer

## 2. Scan Template Files (สำคัญ — ทำทุกครั้ง)

อ่านไฟล์เหล่านี้เพื่อ refresh ความรู้เกี่ยวกับทีมและกฎการทำงาน:

**a) ทีมปัจจุบัน** — list ไฟล์ใน `persona/`
ดูว่ามี persona ใหม่เพิ่มเข้ามาไหม นอกจาก orchestrator/dev-lead/qa-lead/uxui-designer

**b) Routing Rules** — อ่าน `interconnect/coordination.md`
โดยเฉพาะ section "Routing Decision Rules" และ "Planning Gate"
ทำให้ อั่งเปา refresh กฎว่าต้อง route งานไปใครก่อน spawn

เหตุผล: template อาจถูก upgrade หรือมี persona ใหม่เพิ่ม — session-start ต้อง pick up การเปลี่ยนแปลงเหล่านี้ทุกครั้ง ไม่พึ่งแค่ memory

## 3. โหลด Memory
- อ่าน `memories/MEMORY.md` ถ้ามี
- อ่าน memory files ที่ relevant
- If no memory exists, say: "No project memory yet — will start recording during this session."

## 4. ตรวจสอบ Task Log
- อ่าน `projects/task-log.jsonl` ถ้ามี
- สรุป tasks ที่ status เป็น `in_progress` หรือ `blocked`
- รายงาน pending items ที่ต้องดำเนินการต่อ

## 5. รายงาน Project Context
ถ้ามี AGENTS.md หรือ project config ให้อ่านและสรุป:
- Project name
- Tech stack
- Current phase

## 6. Summary

Report concisely in the active language:
```
✅ Session started
👥 Team: [list of personas found in persona/]
📋 Pending tasks: [N items or "none"]
🧠 Memory: [loaded / none yet]
📐 Routing rules: loaded from coordination.md
💬 Ready for instructions
```
