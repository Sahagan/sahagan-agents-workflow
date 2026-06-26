---
name: initproject
description: สร้าง VS Code Workspace ใหม่จาก agents-workflow template — fresh clone, no git, พร้อม workspace file
user-invocable: true
---

Usage: `/initproject <project-name>`

## ขั้นตอนการทำงาน

### Step 1: ยืนยัน Parameters

ถามหรือยืนยัน:
1. **project-name** — ชื่อ project (จาก argument)
2. **workspace location** — จะสร้าง workspace ที่ไหน
   - Default: parent directory ของ current workspace
   - Format: `workspace-<project-name>/`

ตัวอย่าง: `/initproject my-app` → สร้าง `../workspace-my-app/`

### Step 2: สร้าง Workspace Directory

```bash
WORKSPACE_DIR="../workspace-{{project-name}}"
TEMPLATE_DIR="$WORKSPACE_DIR/agents-workflow"

mkdir -p "$WORKSPACE_DIR"
```

### Step 3: Clone Template Fresh

```bash
# Clone ไม่เอา depth limit เพื่อให้ได้ทุก file
git clone https://github.com/sahaganN/agents-workflow.git "$TEMPLATE_DIR" --depth 1

# ลบ git history ทั้งหมด — ไม่ผูกกับ template repo
rm -rf "$TEMPLATE_DIR/.git"

# Init git ใหม่ใน template dir (optional, สำหรับ track local changes)
cd "$TEMPLATE_DIR" && git init && git add . && git commit -m "init: fresh template for {{project-name}}"
```

### Step 4: Setup UI/UX Pro Max Skill

```bash
# Clone skill สำหรับติ่มซำ
mkdir -p "$TEMPLATE_DIR/.claude/skills/ui-ux-pro-max"
git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git /tmp/uxui-skill --depth 1
cp -r /tmp/uxui-skill/. "$TEMPLATE_DIR/.claude/skills/ui-ux-pro-max/"
rm -rf /tmp/uxui-skill
```

### Step 5: สร้าง PROJECT.md

สร้างไฟล์ `$TEMPLATE_DIR/PROJECT.md`:
```markdown
# {{project-name}}

## Project Info
- Name: {{project-name}}
- Created: {{ISO date}}
- Workspace: workspace-{{project-name}}/
- Template: agents-workflow (fresh clone)

## Tech Stack
<!-- TODO: specify tech stack for this project -->

## Team
- Orchestrator: Angpao (อั่งเปา)
- Dev Lead: Phayu (พายุ)
- Research Specialist: Bonus (โบนัส)
- QA Lead: Taifoon (ใต้ฝุ่น)
- UX/UI Designer: Timsum (ติ่มซำ)
```

Reset `memories/MEMORY.md` และ `projects/task-log.jsonl` ให้ว่างเปล่า

### Step 6: สร้าง VS Code Workspace File

สร้างไฟล์ `$WORKSPACE_DIR/{{project-name}}.code-workspace`:
```json
{
  "folders": [
    {
      "name": "🐱 agents-workflow (template)",
      "path": "./agents-workflow"
    }
  ],
  "settings": {
    "window.title": "{{project-name}} — agents-workflow"
  },
  "extensions": {
    "recommendations": [
      "anthropic.claude-code"
    ]
  }
}
```

### Step 7: Report Result

```
✅ Workspace '{{project-name}}' created!

📁 Location: workspace-{{project-name}}/
├── {{project-name}}.code-workspace   ← open this in VS Code
└── agents-workflow/                   ← Template (fresh, no git link)

How to use:
1. Open {{project-name}}.code-workspace in VS Code
2. Claude Code loads CLAUDE.md → Angpao is ready
3. Run /session-start to begin
4. ✨ Add Folder to Workspace to add your project repos
```

## หมายเหตุสำคัญ

- Template ใน workspace **ไม่ผูกกับ git** ของต้นทาง — แก้ไขได้อิสระ
- ทุก `/session-end` → อั่งเปาจะ improve template ใน workspace นี้ (local only)
- ถ้าต้องการ workspace ใหม่ รัน `/initproject` อีกครั้ง — ได้ template สะอาดเสมอ
