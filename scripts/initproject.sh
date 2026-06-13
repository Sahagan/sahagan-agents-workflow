#!/bin/bash
# initproject.sh — สร้าง project ใหม่จาก agents-workflow template

set -e

TEMPLATE_REPO="https://github.com/sahaganN/agents-workflow.git"
UXUI_SKILL_REPO="https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git"

# ========== Parse Arguments ==========
PROJECT_NAME="$1"
TARGET_DIR="${2:-.}"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ ต้องระบุชื่อ project"
  echo "Usage: ./scripts/initproject.sh <project-name> [target-dir]"
  exit 1
fi

PROJECT_PATH="$TARGET_DIR/$PROJECT_NAME"

# ========== Check Existing ==========
if [ -d "$PROJECT_PATH" ]; then
  echo "❌ Directory '$PROJECT_PATH' มีอยู่แล้ว"
  echo "ใช้ชื่ออื่น หรือลบ directory เก่าก่อน"
  exit 1
fi

echo "🐱 อั่งเปา: เริ่มสร้าง project '$PROJECT_NAME'..."
echo "📁 Target: $PROJECT_PATH"

# ========== Clone Template ==========
echo ""
echo "📦 กำลัง clone template..."
git clone "$TEMPLATE_REPO" "$PROJECT_PATH" --depth 1 --quiet
echo "✅ Clone เสร็จแล้ว"

# ========== Strip Template Git ==========
echo "🔗 กำลัง detach จาก template git..."
rm -rf "$PROJECT_PATH/.git"
cd "$PROJECT_PATH"
git init --quiet
git add .
git commit -m "init: project from agents-workflow template" --quiet
echo "✅ Git init เสร็จแล้ว"

# ========== Setup UI/UX Pro Max Skill ==========
echo ""
echo "🎨 กำลัง setup UI/UX Pro Max Skill สำหรับติ่มซำ..."
mkdir -p ".claude/skills/ui-ux-pro-max"
TEMP_SKILL_DIR=$(mktemp -d)
if git clone "$UXUI_SKILL_REPO" "$TEMP_SKILL_DIR" --depth 1 --quiet 2>/dev/null; then
  cp -r "$TEMP_SKILL_DIR/." ".claude/skills/ui-ux-pro-max/"
  rm -rf "$TEMP_SKILL_DIR"
  echo "✅ UI/UX Pro Max Skill ติดตั้งแล้ว"
else
  rm -rf "$TEMP_SKILL_DIR"
  echo "⚠️  ติดตั้ง UI/UX Pro Max Skill ไม่สำเร็จ (จะข้ามไป)"
fi

# ========== Create Project Files ==========
echo ""
echo "📝 กำลังสร้าง project files..."

# PROJECT.md
cat > "PROJECT.md" << EOF
# $PROJECT_NAME

## Project Info
- Name: $PROJECT_NAME
- Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- Template: agents-workflow

## Tech Stack
<!-- TODO: ระบุ tech stack ของ project นี้ -->

## Team
- Orchestrator: อั่งเปา
- Dev Lead: พายุ
- QA Lead: ใต้ฝุ่น
- UX/UI: ติ่มซำ
EOF

# Initial memory
cat > "memories/MEMORY.md" << EOF
# Memory Index — $PROJECT_NAME

_ยังไม่มี memories บันทึกไว้ — อั่งเปาจะบันทึกระหว่าง session_
EOF

# Clear task log
> "projects/task-log.jsonl"

# Commit project setup
git add .
git commit -m "setup: initialize $PROJECT_NAME project files" --quiet

echo "✅ Project files สร้างแล้ว"

# ========== GitHub Repo (Optional) ==========
echo ""
read -p "🐙 ต้องการสร้าง GitHub repo ด้วยไหม? (y/N): " CREATE_GITHUB
if [[ "$CREATE_GITHUB" =~ ^[Yy]$ ]]; then
  if command -v gh &> /dev/null; then
    echo "กำลังสร้าง GitHub repo..."
    gh repo create "$PROJECT_NAME" --source=. --public --push
    echo "✅ GitHub repo สร้างแล้ว"
  else
    echo "⚠️  ไม่พบ gh CLI — ข้ามการสร้าง GitHub repo"
    echo "   ติดตั้ง gh ที่: https://cli.github.com"
    echo "   แล้วรัน: gh repo create $PROJECT_NAME --source=. --public --push"
  fi
fi

# ========== Done ==========
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  ✅ Project '$PROJECT_NAME' พร้อมแล้ว!  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "📁 Location: $(pwd)"
echo "🐱 ทีม: อั่งเปา, พายุ, ใต้ฝุ่น, ติ่มซำ พร้อมทำงาน"
echo ""
echo "วิธีเริ่มใช้งาน:"
echo "  1. เปิด '$PROJECT_NAME/' ใน VS Code"
echo "  2. รัน /session-start เพื่อเริ่ม session"
echo "  3. สั่งงานอั่งเปาได้เลย!"
echo ""
