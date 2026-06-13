---
name: session-end
description: ปิด session — อั่งเปา update task log, บันทึก memory, improve template จาก lessons learned
user-invocable: true
---

เมื่อ user รัน /session-end ให้ทำตามขั้นตอนนี้:

## 1. Update Task Log

อ่าน `projects/task-log.jsonl` แล้ว:
- อัปเดต tasks ที่เสร็จในวันนี้ → status: `completed`, เพิ่ม `completedAt`
- Tasks ที่ยังค้าง → อัปเดต `lastAction` และ `blockers`

## 2. บันทึก Memory

พิจารณาว่ามี discoveries อะไรที่ควรจำ:
- Technical decisions ที่ตัดสินใจพร้อม reason
- Patterns ที่ได้ผลดี / ไม่ดี
- Blockers ที่เจอและแก้อย่างไร
- Context ของ project ที่สำคัญ

บันทึกลง `memories/` เป็นไฟล์แยก อัปเดต `memories/MEMORY.md` index

## 3. ⭐ Improve Template (Local Learning)

**สำคัญ**: ทุก session จบต้องทำขั้นตอนนี้

ทบทวน session นี้ว่ามีอะไรที่ควร improve ใน template:

### สิ่งที่ควร improve:
- **Persona** — ถ้าสังเกตว่า agent ทำงานไม่ดีในบาง context → ปรับ `persona/*.md`
- **Coordination** — ถ้า workflow ไม่ smooth → ปรับ `interconnect/coordination.md`
- **Skills** — ถ้า `/session-start`, `/session-end` หรือ skill อื่นควร improve → ปรับ `.claude/skills/*/SKILL.md`
- **CLAUDE.md** — ถ้าอั่งเปาควรรู้อะไรเพิ่ม → ปรับ `CLAUDE.md`

### หลักการ:
- Improve เฉพาะ local template (ไม่ commit, ไม่ push)
- เป็นการ personalize template ตาม project ของคุณ
- Template ใหม่จาก `/initproject` ยังสะอาดเสมอ (จาก GitHub)

### ตัวอย่าง:
```
"session นี้เจอว่า พายุ มักจะลืม check TypeScript errors ก่อน report"
→ เพิ่ม reminder ใน persona/dev-lead.md

"session นี้เจอว่า workflow BE+FE parallel ได้ผลดี"
→ เพิ่ม note ใน interconnect/coordination.md
```

## 4. สรุป Session

```
## Session Summary — {{date}}

### งานที่เสร็จ ✅
- [task 1]

### งานที่ค้าง 🔄
- [task N]: [blocker]

### Template Improvements 📈
- [สิ่งที่ improve ใน session นี้]

### Next Session
- [สิ่งที่ต้องทำต่อ]
```

## 5. ปิด Session

"บันทึกและ improve template เรียบร้อยแล้วครับ
Template ในเครื่องดีขึ้นจาก session นี้
พบกัน session หน้าครับ 🐱"
