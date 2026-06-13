#!/usr/bin/env node
/**
 * agents-workflow CLI
 * Usage: aw init <project-name> [workspace-parent-dir]
 */

const { execSync } = require('child_process')
const { existsSync, mkdirSync, writeFileSync, rmSync, cpSync } = require('fs')
const { join, resolve } = require('path')
const readline = require('readline')
const os = require('os')

const TEMPLATE_REPO = 'https://github.com/Sahagan/sahagan_agent_template.git'
const UXUI_SKILL_REPO = 'https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git'

const args = process.argv.slice(2)
const command = args[0]

function ask(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })
  return new Promise(resolve => rl.question(question, ans => { rl.close(); resolve(ans) }))
}

function run(cmd, cwd = '.', silent = false) {
  try {
    execSync(cmd, { cwd: resolve(cwd), stdio: silent ? 'pipe' : 'inherit' })
    return true
  } catch {
    return false
  }
}

async function initProject(projectName, parentDir = '.') {
  if (!projectName) {
    console.error('❌ ต้องระบุชื่อ project')
    console.error('Usage: aw init <project-name> [parent-dir]')
    process.exit(1)
  }

  const workspaceDir = resolve(parentDir, `workspace-${projectName}`)
  const templateDir = join(workspaceDir, 'agents-workflow')
  const workspaceFile = join(workspaceDir, `${projectName}.code-workspace`)

  if (existsSync(workspaceDir)) {
    console.error(`❌ Workspace '${workspaceDir}' มีอยู่แล้ว`)
    process.exit(1)
  }

  console.log(`🐱 อั่งเปา: เริ่มสร้าง workspace '${projectName}'...`)
  console.log(`📁 Workspace: ${workspaceDir}`)

  // Create workspace directory
  mkdirSync(workspaceDir, { recursive: true })

  // Clone template fresh
  console.log('\n📦 กำลัง clone template...')
  run(`git clone ${TEMPLATE_REPO} "${templateDir}" --depth 1 --quiet`)
  console.log('✅ Clone เสร็จแล้ว')

  // Strip git & reinit
  console.log('🔗 Detach จาก template git...')
  rmSync(join(templateDir, '.git'), { recursive: true, force: true })
  run('git init', templateDir, true)
  run('git add .', templateDir, true)
  run('git commit -m "init: fresh template for ' + projectName + '"', templateDir, true)
  console.log('✅ Git init เสร็จแล้ว (local only)')

  // Setup UI/UX Pro Max Skill
  console.log('\n🎨 Setup UI/UX Pro Max Skill สำหรับติ่มซำ...')
  const skillDir = join(templateDir, '.claude', 'skills', 'ui-ux-pro-max')
  mkdirSync(skillDir, { recursive: true })
  const tempSkillDir = join(os.tmpdir(), `uxui-skill-${Date.now()}`)
  if (run(`git clone ${UXUI_SKILL_REPO} "${tempSkillDir}" --depth 1 --quiet`, '.', true)) {
    try {
      cpSync(tempSkillDir, skillDir, { recursive: true })
      rmSync(tempSkillDir, { recursive: true, force: true })
      console.log('✅ UI/UX Pro Max Skill ติดตั้งแล้ว')
    } catch {
      console.log('⚠️  ติดตั้ง UI/UX Pro Max Skill ไม่สำเร็จ (ข้ามไป)')
    }
  } else {
    console.log('⚠️  ติดตั้ง UI/UX Pro Max Skill ไม่สำเร็จ (ข้ามไป)')
  }

  // Create project-specific files
  console.log('\n📝 สร้าง project files...')
  const now = new Date().toISOString()

  writeFileSync(join(templateDir, 'PROJECT.md'), `# ${projectName}

## Project Info
- Name: ${projectName}
- Created: ${now}
- Workspace: workspace-${projectName}/
- Template: agents-workflow (fresh clone, no git link)

## Tech Stack
<!-- TODO: ระบุ tech stack ของ project นี้ -->

## Team
- Orchestrator: อั่งเปา
- Dev Lead: พายุ
- QA Lead: ใต้ฝุ่น
- UX/UI: ติ่มซำ
`)

  writeFileSync(join(templateDir, 'memories', 'MEMORY.md'), `# Memory Index — ${projectName}

_ยังไม่มี memories บันทึกไว้ — อั่งเปาจะบันทึกระหว่าง session_
`)

  writeFileSync(join(templateDir, 'projects', 'task-log.jsonl'), '')

  // Remove CLI from template copy (it's only for the package, not the template)
  const cliInTemplate = join(templateDir, 'scripts', 'cli.js')
  if (existsSync(cliInTemplate)) rmSync(cliInTemplate, { force: true })

  run('git add .', templateDir, true)
  run(`git commit -m "setup: ${projectName} project initialized"`, templateDir, true)

  // Create VS Code Workspace file
  console.log('🗂️  สร้าง VS Code Workspace file...')
  const workspaceConfig = {
    folders: [
      {
        name: '🐱 agents-workflow (template)',
        path: './agents-workflow'
      }
    ],
    settings: {
      'window.title': `${projectName} — agents-workflow`
    },
    extensions: {
      recommendations: ['anthropic.claude-code']
    }
  }
  writeFileSync(workspaceFile, JSON.stringify(workspaceConfig, null, 2))
  console.log('✅ Workspace file สร้างแล้ว')

  // GitHub repo (optional)
  const createGithub = await ask('\n🐙 ต้องการสร้าง GitHub repo สำหรับ project นี้ด้วยไหม? (y/N): ')
  if (createGithub.toLowerCase() === 'y') {
    const ghAvailable = run('gh --version', '.', true)
    if (ghAvailable) {
      run(`gh repo create ${projectName} --source="${templateDir}" --public --push`)
      console.log('✅ GitHub repo สร้างแล้ว')
    } else {
      console.log('⚠️  ไม่พบ gh CLI — ข้ามการสร้าง GitHub repo')
    }
  }

  // Done
  console.log('\n╔════════════════════════════════════════════════╗')
  console.log(`║  ✅ Workspace '${projectName}' พร้อมแล้ว!`)
  console.log('╚════════════════════════════════════════════════╝')
  console.log(`\n📁 Workspace: ${workspaceDir}`)
  console.log(`\n${workspaceDir}/`)
  console.log(`├── ${projectName}.code-workspace   ← เปิดไฟล์นี้ใน VS Code`)
  console.log(`└── agents-workflow/                 ← Template (fresh, ไม่มี git link)`)
  console.log('\n🐱 ทีม: อั่งเปา, พายุ, ใต้ฝุ่น, ติ่มซำ พร้อมทำงาน')
  console.log('\n💡 วิธีใช้งาน:')
  console.log(`   1. เปิด ${projectName}.code-workspace ใน VS Code`)
  console.log('   2. รัน /session-start → อั่งเปาพร้อมแล้ว')
  console.log('   3. ✨ Add Folder to Workspace เพื่อเพิ่ม project repos ได้เลย')
}

switch (command) {
  case 'init':
    initProject(args[1], args[2]).catch(err => {
      console.error('❌ Error:', err.message)
      process.exit(1)
    })
    break
  default:
    console.log('agents-workflow CLI 🐱')
    console.log('')
    console.log('Commands:')
    console.log('  aw init <project-name> [parent-dir]   สร้าง VS Code workspace ใหม่')
    console.log('')
    console.log('Examples:')
    console.log('  aw init my-app')
    console.log('  aw init my-app D:\\working')
    console.log('')
    console.log('Output:')
    console.log('  workspace-my-app/')
    console.log('  ├── my-app.code-workspace')
    console.log('  └── agents-workflow/')
}
