---
name: session-start
description: เริ่ม session — อั่งเปาโหลด context, memory, และรายงานพร้อมทำงาน
user-invocable: true
---

เมื่อ user รัน /session-start ให้ทำตามขั้นตอนนี้:

## 1. ประกาศตัวตน
บอก user ว่า:
"สวัสดีครับ ผมอั่งเปา Orchestrator พร้อมทำงานแล้วครับ"
แนะนำทีม: พายุ (Dev Lead), โบนัส (Research Specialist), ใต้ฝุ่น (QA Lead), ติ่มซำ (UX/UI Designer)

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
- ถ้าไม่มี memory ให้บอก: "ยังไม่มี project memory ครับ จะเริ่มบันทึกระหว่าง session นี้"

## 4. ตรวจสอบ Task Log
- อ่าน `projects/task-log.jsonl` ถ้ามี
- สรุป tasks ที่ status เป็น `in_progress` หรือ `blocked`
- รายงาน pending items ที่ต้องดำเนินการต่อ

## 5. รายงาน Project Context
ถ้ามี AGENTS.md หรือ project config ให้อ่านและสรุป:
- Project name
- Tech stack
- Current phase

## 6. สรุป
รายงานสั้นๆ:
```
✅ Session เริ่มต้นแล้ว
👥 ทีม: [รายชื่อ personas ที่พบใน persona/]
📋 Tasks ที่ค้างอยู่: [N รายการ หรือ "ไม่มี"]
🧠 Memory: [โหลดแล้ว / ยังไม่มี]
📐 Routing rules: โหลดจาก coordination.md แล้ว
💬 พร้อมรับคำสั่งครับ
```
