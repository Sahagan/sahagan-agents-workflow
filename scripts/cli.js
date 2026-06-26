#!/usr/bin/env node
/**
 * agents-workflow CLI
 * Usage:
 *   aw init <project-name> [workspace-parent-dir]
 *   aw upgrade [agents-workflow-path]
 */

const { execSync } = require('child_process')
const { existsSync, mkdirSync, writeFileSync, readFileSync, rmSync, cpSync, readdirSync } = require('fs')
const { join, resolve } = require('path')
const readline = require('readline')
const os = require('os')

const TEMPLATE_SRC          = join(__dirname, '..', 'template')
const UXUI_SKILL_REPO       = 'https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git'
const PONYTAIL_SKILL_REPO   = 'https://github.com/DietrichGebert/ponytail.git'
const ADDYOSMANI_SKILL_REPO = 'https://github.com/addyosmani/agent-skills.git'

const args    = process.argv.slice(2)
const command = args[0]

// ─── i18n messages ────────────────────────────────────────────────────────────

const MSGS = {
  th: {
    langPrompt:    '🌐 เลือกภาษา / Choose language:\n  [1] ภาษาไทย (Thai)\n  [2] English (default — press Enter)\n> ',
    toolPrompt:    '\n🤖 เลือก AI tool:\n  [1] Claude Code (Anthropic) — ค่าเริ่มต้น\n  [2] Codex (OpenAI)\n  [3] ทั้งคู่ (Claude Code + Codex)\n> ',
    toolClaude:    'Claude Code',
    toolCodex:     'Codex',
    toolBoth:      'Claude Code + Codex',
    errorNoProject:  '❌ ต้องระบุชื่อ project\nUsage: aw init <project-name> [parent-dir]',
    errorExists:   d => `❌ Workspace '${d}' มีอยู่แล้ว`,
    starting:      n => `🐱 อั่งเปา: เริ่มสร้าง workspace '${n}'...`,
    workspaceAt:   d => `📁 Workspace: ${d}`,
    copying:       '📦 กำลัง copy template...',
    copied:        '✅ Copy เสร็จแล้ว (bundled — ไม่ต้อง internet)',
    aiSetup:       t => `\n🤖 Setup สำหรับ ${t}...`,
    aiReady:       t => `✅ ${t} พร้อมแล้ว`,
    gitInit:       '🔗 Init git repo ใหม่...',
    gitDone:       '✅ Git init เสร็จแล้ว (local only)',
    skillSetup:    '🎨 UI/UX Pro Max Skill (ติ่มซำ)...',
    skillDone:     '✅ UI/UX Pro Max ติดตั้งแล้ว',
    skillFail:     '⚠️  UI/UX Pro Max ไม่สำเร็จ (ข้ามไป)',
    addySetup:     '⚙️  Planning & Review Skills (อั่งเปา + ใต้ฝุ่น)...',
    addyDone:      '✅ Planning, Code Review & Security ติดตั้งแล้ว',
    addyFail:      '⚠️  Planning & Review Skills ไม่สำเร็จ (ข้ามไป)',
    ponytailSetup: '🐴 Ponytail Skill (พายุ)...',
    ponytailDone:  '✅ Ponytail ติดตั้งแล้ว',
    ponytailFail:  '⚠️  Ponytail ไม่สำเร็จ (ข้ามไป)',
    creatingFiles: '📝 สร้าง project files...',
    wsFile:        '🗂️  สร้าง VS Code Workspace file...',
    wsFileDone:    '✅ Workspace file สร้างแล้ว',
    teamReady:     '🐱 ทีม: อั่งเปา, พายุ, โบนัส, ใต้ฝุ่น, ติ่มซำ พร้อมทำงาน',
    howToUse:      '💡 วิธีใช้งาน:',
    step1:         f => `   1. เปิด ${f} ใน VS Code`,
    step2: {
      claude: '   2. รัน /session-start → อั่งเปาพร้อมแล้ว',
      codex:  '   2. รัน codex ใน terminal → อั่งเปาอ่าน AGENTS.md พร้อมแล้ว',
      both:   '   2. Claude Code: /session-start  |  Codex: codex ใน terminal',
    },
    step3: '   3. ✨ Add Folder to Workspace เพื่อเพิ่ม project repos ได้เลย',
    upgradeNotFound:  d => `❌ ไม่พบ agents-workflow directory ที่ '${d}'\n   ระบุ path ตรงๆ หรือรันใน workspace directory`,
    upgradeDetected:  d => `📁 พบ agents-workflow: ${d}`,
    upgradeBackup:    d => `💾 Backup ไฟล์เดิมไปที่: ${d}`,
    upgradeBackupDone:  '✅ Backup เสร็จแล้ว',
    upgradeFiles:       '📄 อัปเดต template files (persona, CLAUDE.md, AGENTS.md)...',
    upgradeFilesDone:   '✅ Template files อัปเดตแล้ว',
    upgradeSkills:      '\n🔄 อัปเดต skills ทั้งหมด...',
    upgradeCommit:      '🔗 Commit การเปลี่ยนแปลง...',
    upgradeUpdated:     '\n✅ สิ่งที่อัปเดต:',
    upgradeKept:        '🔒 สิ่งที่ไม่แตะ (user data):',
    projectMd: (n, now) => `# ${n}\n\n## Project Info\n- Name: ${n}\n- Created: ${now}\n- Workspace: workspace-${n}/\n- Template: agents-workflow\n\n## Tech Stack\n<!-- TODO: ระบุ tech stack ของ project นี้ -->\n\n## Team\n- Orchestrator: อั่งเปา\n- Dev Lead: พายุ\n- QA Lead: ใต้ฝุ่น\n- UX/UI: ติ่มซำ\n`,
    memoryMd: n => `# Memory Index — ${n}\n\n_ยังไม่มี memories บันทึกไว้ — อั่งเปาจะบันทึกระหว่าง session_\n`,
  },

  en: {
    langPrompt:    '🌐 เลือกภาษา / Choose language:\n  [1] ภาษาไทย (Thai)\n  [2] English (default — press Enter)\n> ',
    toolPrompt:    '\n🤖 Choose AI tool:\n  [1] Claude Code (Anthropic) — default\n  [2] Codex (OpenAI)\n  [3] Both (Claude Code + Codex)\n> ',
    toolClaude:    'Claude Code',
    toolCodex:     'Codex',
    toolBoth:      'Claude Code + Codex',
    errorNoProject:  '❌ Project name required\nUsage: aw init <project-name> [parent-dir]',
    errorExists:   d => `❌ Workspace '${d}' already exists`,
    starting:      n => `🐱 Angpao: Creating workspace '${n}'...`,
    workspaceAt:   d => `📁 Workspace: ${d}`,
    copying:       '📦 Copying template...',
    copied:        '✅ Template copied (bundled — no internet needed)',
    aiSetup:       t => `\n🤖 Setting up ${t}...`,
    aiReady:       t => `✅ ${t} ready`,
    gitInit:       '🔗 Initializing git repo...',
    gitDone:       '✅ Git initialized (local only)',
    skillSetup:    '🎨 UI/UX Pro Max Skill (Timsum)...',
    skillDone:     '✅ UI/UX Pro Max installed',
    skillFail:     '⚠️  UI/UX Pro Max failed (skipped)',
    addySetup:     '⚙️  Planning & Review Skills (Angpao + Taifoon)...',
    addyDone:      '✅ Planning, Code Review & Security installed',
    addyFail:      '⚠️  Planning & Review Skills failed (skipped)',
    ponytailSetup: '🐴 Ponytail Skill (Phayu)...',
    ponytailDone:  '✅ Ponytail installed',
    ponytailFail:  '⚠️  Ponytail failed (skipped)',
    creatingFiles: '📝 Creating project files...',
    wsFile:        '🗂️  Creating VS Code Workspace file...',
    wsFileDone:    '✅ Workspace file created',
    teamReady:     '🐱 Team: Angpao, Phayu, Bonus, Taifoon, Timsum are ready',
    howToUse:      '💡 How to use:',
    step1:         f => `   1. Open ${f} in VS Code`,
    step2: {
      claude: '   2. Run /session-start → Angpao is ready',
      codex:  '   2. Run codex in terminal → Angpao reads AGENTS.md and is ready',
      both:   '   2. Claude Code: /session-start  |  Codex: run codex in terminal',
    },
    step3: '   3. ✨ Add Folder to Workspace to add project repos',
    upgradeNotFound:  d => `❌ Could not find agents-workflow directory at '${d}'\n   Pass the path directly or run from within a workspace directory`,
    upgradeDetected:  d => `📁 Found agents-workflow: ${d}`,
    upgradeBackup:    d => `💾 Backing up existing files to: ${d}`,
    upgradeBackupDone:  '✅ Backup complete',
    upgradeFiles:       '📄 Updating template files (persona, CLAUDE.md, AGENTS.md)...',
    upgradeFilesDone:   '✅ Template files updated',
    upgradeSkills:      '\n🔄 Updating all skills...',
    upgradeCommit:      '🔗 Committing changes...',
    upgradeUpdated:     '\n✅ What was updated:',
    upgradeKept:        '🔒 What was preserved (user data):',
    projectMd: (n, now) => `# ${n}\n\n## Project Info\n- Name: ${n}\n- Created: ${now}\n- Workspace: workspace-${n}/\n- Template: agents-workflow\n\n## Tech Stack\n<!-- TODO: specify tech stack for this project -->\n\n## Team\n- Orchestrator: Angpao (อั่งเปา)\n- Dev Lead: Phayu (พายุ)\n- QA Lead: Taifoon (ใต้ฝุ่น)\n- UX/UI: Timsum (ติ่มซำ)\n`,
    memoryMd: n => `# Memory Index — ${n}\n\n_No memories yet — Angpao will record during sessions_\n`,
  },
}

// ─── helpers ──────────────────────────────────────────────────────────────────

function ask(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })
  return new Promise(res => rl.question(question, ans => { rl.close(); res(ans) }))
}

function run(cmd, cwd = '.', silent = false) {
  try {
    execSync(cmd, { cwd: resolve(cwd), stdio: silent ? 'pipe' : 'inherit' })
    return true
  } catch {
    return false
  }
}

function getSelfVersion() {
  try { return require('../package.json').version } catch { return null }
}

function getLatestNpmVersion(pkg) {
  try {
    return execSync(`npm view ${pkg} version`, { stdio: 'pipe', timeout: 8000 }).toString().trim()
  } catch { return null }
}

function toolLabel(m, tool) {
  return { claude: m.toolClaude, codex: m.toolCodex, both: m.toolBoth }[tool]
}

function applyLanguageDirective(dir, lang) {
  if (lang === 'th') return

  const directive =
    '> **Response Language: English** — Always respond to the user in English, ' +
    'regardless of the language used in these instruction files.\n\n'

  for (const file of ['CLAUDE.md', 'AGENTS.md', 'persona/orchestrator.md', 'persona/dev-lead.md', 'persona/qa-lead.md', 'persona/uxui-designer.md', 'persona/researcher.md', 'interconnect/coordination.md', '.claude/skills/session-start/SKILL.md', '.claude/skills/session-end/SKILL.md', '.claude/skills/initproject/SKILL.md']) {
    const p = join(dir, file)
    if (!existsSync(p)) continue
    writeFileSync(p, directive + readFileSync(p, 'utf8'), 'utf8')
  }
}

function installSkills(workflowDir, m) {
  const skillsDir = join(workflowDir, '.claude', 'skills')
  mkdirSync(skillsDir, { recursive: true })

  // UI/UX Pro Max (ติ่มซำ)
  console.log(m.skillSetup)
  const uxuiDir = join(skillsDir, 'ui-ux-pro-max')
  if (existsSync(uxuiDir)) rmSync(uxuiDir, { recursive: true, force: true })
  mkdirSync(uxuiDir, { recursive: true })
  const tmpUxui = join(os.tmpdir(), `uxui-${Date.now()}`)
  if (run(`git clone ${UXUI_SKILL_REPO} "${tmpUxui}" --depth 1 --quiet`, '.', true)) {
    try { cpSync(tmpUxui, uxuiDir, { recursive: true }); rmSync(tmpUxui, { recursive: true, force: true }); console.log(m.skillDone) }
    catch { console.log(m.skillFail) }
  } else { console.log(m.skillFail) }

  // addyosmani: planning + code-review + security (อั่งเปา + ใต้ฝุ่น)
  console.log(m.addySetup)
  const tmpAddy = join(os.tmpdir(), `addy-${Date.now()}`)
  if (run(`git clone ${ADDYOSMANI_SKILL_REPO} "${tmpAddy}" --depth 1 --quiet`, '.', true)) {
    try {
      for (const skill of ['planning-and-task-breakdown', 'code-review-and-quality', 'security-and-hardening']) {
        const dst = join(skillsDir, skill)
        if (existsSync(dst)) rmSync(dst, { recursive: true, force: true })
        cpSync(join(tmpAddy, 'skills', skill), dst, { recursive: true })
      }
      rmSync(tmpAddy, { recursive: true, force: true })
      console.log(m.addyDone)
    } catch { console.log(m.addyFail) }
  } else { console.log(m.addyFail) }

  // Ponytail (พายุ)
  console.log(m.ponytailSetup)
  const tmpPony = join(os.tmpdir(), `ponytail-${Date.now()}`)
  if (run(`git clone ${PONYTAIL_SKILL_REPO} "${tmpPony}" --depth 1 --quiet`, '.', true)) {
    try {
      for (const d of readdirSync(skillsDir).filter(x => x.startsWith('ponytail'))) {
        rmSync(join(skillsDir, d), { recursive: true, force: true })
      }
      cpSync(join(tmpPony, 'skills'), skillsDir, { recursive: true })
      rmSync(tmpPony, { recursive: true, force: true })
      console.log(m.ponytailDone)
    } catch { console.log(m.ponytailFail) }
  } else { console.log(m.ponytailFail) }
}

// ─── init ─────────────────────────────────────────────────────────────────────

async function initProject(projectName, parentDir = '.') {
  // 1. Language
  const rawLang = await ask(MSGS.th.langPrompt)
  const lang = rawLang.trim() === '1' ? 'th' : 'en'
  const m = MSGS[lang]

  if (!projectName) {
    console.error(m.errorNoProject)
    process.exit(1)
  }

  // 2. AI tool
  const rawTool = await ask(m.toolPrompt)
  const n = rawTool.trim()
  const tool = n === '2' ? 'codex' : n === '3' ? 'both' : 'claude'
  const label = toolLabel(m, tool)

  const workspaceDir  = resolve(parentDir, `workspace-${projectName}`)
  const workflowDir   = join(workspaceDir, 'agents-workflow')
  const workspaceFile = join(workspaceDir, `${projectName}.code-workspace`)

  if (existsSync(workspaceDir)) {
    console.error(m.errorExists(workspaceDir))
    process.exit(1)
  }

  console.log(m.starting(projectName))
  console.log(m.workspaceAt(workspaceDir))

  // 3. Copy bundled template
  console.log('\n' + m.copying)
  mkdirSync(workflowDir, { recursive: true })
  cpSync(TEMPLATE_SRC, workflowDir, { recursive: true })
  console.log(m.copied)

  // 4. Apply language directive
  applyLanguageDirective(workflowDir, lang)

  // 5. Handle AI instruction files
  console.log(m.aiSetup(label))
  if (tool === 'claude' && existsSync(join(workflowDir, 'AGENTS.md'))) rmSync(join(workflowDir, 'AGENTS.md'))
  if (tool === 'codex'  && existsSync(join(workflowDir, 'CLAUDE.md'))) rmSync(join(workflowDir, 'CLAUDE.md'))
  console.log(m.aiReady(label))

  // 6. Init git
  console.log(m.gitInit)
  run('git init', workflowDir, true)
  run('git add .', workflowDir, true)
  run(`git commit -m "init: fresh template for ${projectName}"`, workflowDir, true)
  console.log(m.gitDone)

  // 7. Install skills
  console.log('')
  installSkills(workflowDir, m)

  // 8. Project files
  console.log('\n' + m.creatingFiles)
  const now = new Date().toISOString()
  writeFileSync(join(workflowDir, 'PROJECT.md'), m.projectMd(projectName, now))
  writeFileSync(join(workflowDir, 'memories', 'MEMORY.md'), m.memoryMd(projectName))
  writeFileSync(join(workflowDir, 'projects', 'task-log.jsonl'), '')
  run('git add .', workflowDir, true)
  run(`git commit -m "setup: ${projectName} project initialized"`, workflowDir, true)

  // 9. VS Code workspace file
  console.log(m.wsFile)
  writeFileSync(workspaceFile, JSON.stringify({
    folders: [{ name: '🐱 agents-workflow (template)', path: './agents-workflow' }],
    settings: { 'window.title': `${projectName} — agents-workflow` },
    extensions: { recommendations: ['anthropic.claude-code'] },
  }, null, 2))
  console.log(m.wsFileDone)

  // 10. Done
  console.log('\n╔════════════════════════════════════════════════╗')
  console.log(`║  ✅ Workspace '${projectName}' ready!`)
  console.log('╚════════════════════════════════════════════════╝')
  console.log(`\n📁 ${workspaceDir}`)
  console.log(`├── ${projectName}.code-workspace`)
  console.log(`└── agents-workflow/`)
  console.log('\n' + m.teamReady)
  console.log(`🤖 AI: ${label}`)
  console.log('\n' + m.howToUse)
  console.log(m.step1(`${projectName}.code-workspace`))
  console.log(m.step2[tool])
  console.log(m.step3)
}

// ─── upgrade ──────────────────────────────────────────────────────────────────

async function upgradeWorkflow(targetPath = '.') {
  // 0. Self-update check
  const currentVer = getSelfVersion()
  const latestVer  = getLatestNpmVersion('sahagan-agents-workflow')
  if (latestVer && currentVer && latestVer !== currentVer) {
    console.log(`📦 New version available: v${currentVer} → v${latestVer}`)
    console.log('🔄 Updating sahagan-agents-workflow...')
    run('npm install -g sahagan-agents-workflow@latest', '.', false)
    console.log('✅ Package updated to v' + latestVer)
  } else if (latestVer) {
    console.log(`✅ Already on latest version (${latestVer})`)
  }

  // 1. Language
  const rawLang = await ask(MSGS.th.langPrompt)
  const lang = rawLang.trim() === '1' ? 'th' : 'en'
  const m = MSGS[lang]

  // 2. Detect agents-workflow directory
  let workflowDir = resolve(targetPath)
  if (!existsSync(join(workflowDir, 'persona'))) {
    const nested = join(workflowDir, 'agents-workflow')
    if (existsSync(join(nested, 'persona'))) {
      workflowDir = nested
    } else {
      console.error(m.upgradeNotFound(workflowDir))
      process.exit(1)
    }
  }
  console.log(m.upgradeDetected(workflowDir))

  // 3. AI tool
  const rawTool = await ask(m.toolPrompt)
  const n = rawTool.trim()
  const tool = n === '2' ? 'codex' : n === '3' ? 'both' : 'claude'
  const label = toolLabel(m, tool)

  // 4. Backup files that will be overwritten
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
  const backupDir = join(workflowDir, `.upgrade-backup-${ts}`)
  mkdirSync(backupDir, { recursive: true })
  console.log(m.upgradeBackup(backupDir))
  for (const f of ['CLAUDE.md', 'AGENTS.md']) {
    const src = join(workflowDir, f)
    if (existsSync(src)) cpSync(src, join(backupDir, f))
  }
  const personaSrc = join(workflowDir, 'persona')
  if (existsSync(personaSrc)) cpSync(personaSrc, join(backupDir, 'persona'), { recursive: true })
  console.log(m.upgradeBackupDone)

  // 5. Overwrite template files
  console.log(m.upgradeFiles)
  cpSync(join(TEMPLATE_SRC, 'persona'), join(workflowDir, 'persona'), { recursive: true })
  cpSync(join(TEMPLATE_SRC, 'CLAUDE.md'), join(workflowDir, 'CLAUDE.md'))
  cpSync(join(TEMPLATE_SRC, 'AGENTS.md'), join(workflowDir, 'AGENTS.md'))
  // copy context/ template (new in v1.3.0)
  const contextSrc = join(TEMPLATE_SRC, 'context')
  const contextDst = join(workflowDir, 'context')
  if (existsSync(contextSrc)) {
    if (!existsSync(contextDst)) mkdirSync(contextDst, { recursive: true })
    cpSync(contextSrc, contextDst, { recursive: true })
  }
  // copy mcp example
  const mcpSrc = join(TEMPLATE_SRC, 'mcp-researcher.json.example')
  if (existsSync(mcpSrc)) cpSync(mcpSrc, join(workflowDir, 'mcp-researcher.json.example'))
  console.log(m.upgradeFilesDone)

  // 6. Apply language directive
  applyLanguageDirective(workflowDir, lang)

  // 7. Handle AI instruction files
  console.log(m.aiSetup(label))
  if (tool === 'claude' && existsSync(join(workflowDir, 'AGENTS.md'))) rmSync(join(workflowDir, 'AGENTS.md'))
  if (tool === 'codex'  && existsSync(join(workflowDir, 'CLAUDE.md'))) rmSync(join(workflowDir, 'CLAUDE.md'))
  console.log(m.aiReady(label))

  // 8. Update all skills
  console.log(m.upgradeSkills)
  installSkills(workflowDir, m)

  // 9. Git commit
  console.log('\n' + m.upgradeCommit)
  run('git add .', workflowDir, true)
  run('git commit -m "upgrade: agents-workflow updated to latest template"', workflowDir, true)

  // 10. Done
  console.log('\n╔════════════════════════════════════════════════╗')
  console.log('║  ✅ Upgrade complete!')
  console.log('╚════════════════════════════════════════════════╝')
  console.log(`\n📁 ${workflowDir}`)
  console.log(`🤖 AI: ${label}`)
  console.log(m.upgradeUpdated)
  console.log('   ✅ persona/*.md')
  console.log('   ✅ CLAUDE.md / AGENTS.md')
  console.log('   ✅ skills (ponytail, ui-ux-pro-max, planning, code-review, security)')
  console.log(`\n${m.upgradeKept}`)
  console.log('   🔒 memories/')
  console.log('   🔒 projects/task-log.jsonl')
  console.log('   🔒 PROJECT.md')
  console.log('   🔒 interconnect/')
  console.log(`\n💾 Backup: ${backupDir}`)
}

// ─── help ─────────────────────────────────────────────────────────────────────

function showHelp() {
  const line = '─'.repeat(60)
  console.log('')
  console.log('  agents-workflow CLI 🐱')
  console.log('  Multi-agent workflow for Claude Code & OpenAI Codex')
  console.log('')
  console.log(line)
  console.log('  COMMANDS')
  console.log(line)
  console.log('')
  console.log('  aw init <project-name> [parent-dir]')
  console.log('    Create a new agents-workflow workspace.')
  console.log('    Prompts for language and AI tool, then:')
  console.log('      • Copies bundled template (no internet needed)')
  console.log('      • Installs CLAUDE.md and/or AGENTS.md based on tool choice')
  console.log('      • Applies language directive to all instruction files')
  console.log('      • Installs all agent skills from GitHub')
  console.log('      • Creates a VS Code .code-workspace file')
  console.log('      • Initializes a local git repo')
  console.log('')
  console.log('  aw upgrade [agents-workflow-path]')
  console.log('    Upgrade an existing workspace to the latest template version.')
  console.log('    Prompts for language and AI tool, then:')
  console.log('      • Checks npm for newer version and self-updates if available')
  console.log('      • Backs up current persona/, CLAUDE.md, AGENTS.md')
  console.log('      • Overwrites template files with latest bundled version')
  console.log('      • Re-installs all skills to their latest versions')
  console.log('      • Commits the upgrade with a descriptive message')
  console.log('    Preserves: memories/, projects/, PROJECT.md, interconnect/')
  console.log('    Path defaults to ./agents-workflow if not specified.')
  console.log('')
  console.log('  aw help')
  console.log('    Show this help message.')
  console.log('')
  console.log(line)
  console.log('  PROMPTS (asked by init & upgrade)')
  console.log(line)
  console.log('')
  console.log('  Language:')
  console.log('    [1] ภาษาไทย (Thai)   — all agent responses in Thai')
  console.log('    [2] English           — prepends English directive to all files')
  console.log('')
  console.log('  AI Tool:')
  console.log('    [1] Claude Code       — installs CLAUDE.md, uses claude -p to spawn')
  console.log('    [2] Codex             — installs AGENTS.md, uses codex --approval-mode')
  console.log('    [3] Both              — installs both files')
  console.log('')
  console.log(line)
  console.log('  INSTALLED SKILLS')
  console.log(line)
  console.log('')
  console.log('  Agent           Skill                        Source')
  console.log('  ─────────────  ───────────────────────────  ──────────────────────────')
  console.log('  Angpao         planning-and-task-breakdown   addyosmani/agent-skills ⭐62k')
  console.log('  Taifoon (QA)   code-review-and-quality       addyosmani/agent-skills ⭐62k')
  console.log('  Taifoon (QA)   security-and-hardening        addyosmani/agent-skills ⭐62k')
  console.log('  Phayu (Dev)    ponytail (+ review/audit)     DietrichGebert/ponytail ⭐36k')
  console.log('  Timsum (UX)    ui-ux-pro-max                 nextlevelbuilder        ⭐93k')
  console.log('  Bonus (Research)  planning-and-task-breakdown   addyosmani/agent-skills ⭐62k')
  console.log('')
  console.log(line)
  console.log('  EXAMPLES')
  console.log(line)
  console.log('')
  console.log('  aw init my-app')
  console.log('  aw init my-app D:\\working')
  console.log('  aw upgrade')
  console.log('  aw upgrade D:\\working\\workspace-my-app')
  console.log('')
  console.log(line)
  console.log('  REQUIREMENTS')
  console.log(line)
  console.log('')
  console.log('  • Node.js ≥ 18')
  console.log('  • Git (for skill installation and repo init)')
  console.log('  • claude CLI  — Claude Code mode')
  console.log('  • codex CLI   — Codex mode')
  console.log('')
}

// ─── router ───────────────────────────────────────────────────────────────────

switch (command) {
  case 'init':
    initProject(args[1], args[2]).catch(err => {
      console.error('❌ Error:', err.message)
      process.exit(1)
    })
    break
  case 'upgrade':
    upgradeWorkflow(args[1]).catch(err => {
      console.error('❌ Error:', err.message)
      process.exit(1)
    })
    break
  case 'help':
    showHelp()
    break
  default:
    console.log('')
    console.log('  agents-workflow CLI 🐱')
    console.log('')
    console.log('  aw init <project-name> [parent-dir]    Create a new workspace')
    console.log('  aw upgrade [agents-workflow-path]      Upgrade an existing workspace')
    console.log('  aw help                                Show full help')
    console.log('')
}
