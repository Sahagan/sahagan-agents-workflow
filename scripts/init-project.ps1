#!/usr/bin/env pwsh
# init-project.ps1
# Init a new project workspace from the Sahagan Agent Template
#
# Usage:
#   .\scripts\init-project.ps1 -ProjectName "my-project"
#   .\scripts\init-project.ps1 -ProjectName "my-project" -RepoUrl "https://github.com/user/repo.git"
#   .\scripts\init-project.ps1 -ProjectName "my-project" -RepoUrl "https://github.com/user/repo.git" -OutputDir "D:\projects"

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [string]$RepoUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "",

    [Parameter(Mandatory=$false)]
    [string]$TemplateRepo = "https://github.com/Sahagan/sahagan_agent_template.git",

    [switch]$NoOpen
)

# ─── Config ───────────────────────────────────────────────────────────────────

$ErrorActionPreference = "Stop"

# Resolve output directory
if ($OutputDir -eq "") {
    $OutputDir = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
}

$ProjectDir = Join-Path $OutputDir $ProjectName

# ─── Banner ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   ARIA Agent Template — Project Init     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Project  : $ProjectName" -ForegroundColor White
Write-Host "  Location : $ProjectDir" -ForegroundColor White
if ($RepoUrl -ne "") {
    Write-Host "  Repo     : $RepoUrl" -ForegroundColor White
}
Write-Host ""

# ─── Preflight ────────────────────────────────────────────────────────────────

if (Test-Path $ProjectDir) {
    Write-Host "  [ERROR] Directory already exists: $ProjectDir" -ForegroundColor Red
    Write-Host "  Delete it first or choose a different project name." -ForegroundColor Red
    exit 1
}

$gitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitAvailable) {
    Write-Host "  [ERROR] git not found. Install git and retry." -ForegroundColor Red
    exit 1
}

$codeAvailable = Get-Command code -ErrorAction SilentlyContinue

# ─── Step 1: Clone agent template ─────────────────────────────────────────────

Write-Host "  [1/4] Cloning agent template..." -ForegroundColor Yellow
git clone $TemplateRepo $ProjectDir 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Failed to clone template from $TemplateRepo" -ForegroundColor Red
    exit 1
}

# Remove .git from template clone (so the project dir is not a git repo itself)
Remove-Item -Path (Join-Path $ProjectDir ".git") -Recurse -Force
Write-Host "  [1/4] Template ready (git history removed)" -ForegroundColor Green

# ─── Step 2: Initialize project git ───────────────────────────────────────────

Write-Host "  [2/4] Initializing project git..." -ForegroundColor Yellow
Push-Location $ProjectDir
git init -q
git add -A
git commit -q -m "Init: $ProjectName from sahagan_agent_template"
Pop-Location
Write-Host "  [2/4] Git initialized (clean slate)" -ForegroundColor Green

# ─── Step 3: Clone project repo ───────────────────────────────────────────────

$ProjectsDir = Join-Path $ProjectDir "projects"

if ($RepoUrl -ne "") {
    Write-Host "  [3/4] Cloning project repo..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null

    # Derive repo folder name from URL
    $RepoName = ($RepoUrl -split "/" | Select-Object -Last 1) -replace "\.git$", ""
    $RepoPath = Join-Path $ProjectsDir $RepoName

    git clone $RepoUrl $RepoPath 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARN] Failed to clone $RepoUrl — continuing without it" -ForegroundColor DarkYellow
    } else {
        Write-Host "  [3/4] Project repo cloned to projects/$RepoName" -ForegroundColor Green
    }
} else {
    Write-Host "  [3/4] No repo URL provided — creating empty projects/ folder" -ForegroundColor DarkGray
    New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null

    # Create a placeholder README
    $placeholderReadme = @"
# Projects

Add your project repos here.

```bash
# Clone a repo manually
cd projects/
git clone <your-repo-url>

# Or use the init script with -RepoUrl next time
```
"@
    Set-Content -Path (Join-Path $ProjectsDir "README.md") -Value $placeholderReadme -Encoding UTF8
}

# ─── Step 4: Patch CLAUDE.md with project name ────────────────────────────────

Write-Host "  [4/4] Configuring workspace..." -ForegroundColor Yellow

$claudeMd = Join-Path $ProjectDir "CLAUDE.md"
if (Test-Path $claudeMd) {
    $content = Get-Content $claudeMd -Raw
    # Inject project name context at the top
    $projectHeader = "<!-- Project: $ProjectName -->`n"
    Set-Content -Path $claudeMd -Value ($projectHeader + $content) -Encoding UTF8
}

# Write project info file
$projectInfo = @"
# Project: $ProjectName

**Initialized:** $(Get-Date -Format "yyyy-MM-dd")
**Template:** sahagan_agent_template

## Project Repo
$(if ($RepoUrl -ne "") { "- $RepoUrl" } else { "- (not set — add to projects/)" })

## Quick Start

\`\`\`
Open this folder in VS Code → Claude Code → /session-start
\`\`\`

## Structure

\`\`\`
$ProjectName/
├── CLAUDE.md               ← ARIA entry point (auto-loaded by Claude Code)
├── .claude/
│   ├── agents/             ← Kai (BE), Nova (FE), Sage (QA) definitions
│   └── skills/             ← /session-start, /assign, /new-session, UI/UX Pro Max
├── agents/                 ← Persona + memories for each agent
│   ├── orchestrator/       ← ARIA's memory
│   ├── backend/            ← Kai's memory
│   ├── frontend/           ← Nova's memory
│   └── qa/                 ← Sage's memory
├── _shared/                ← Session state, task log, decisions
│   ├── messages.jsonl
│   ├── task-log.jsonl
│   └── decisions/
└── projects/               ← Project code lives here
    └── $ProjectName/
\`\`\`
"@
Set-Content -Path (Join-Path $ProjectDir "PROJECT.md") -Value $projectInfo -Encoding UTF8

Write-Host "  [4/4] Workspace configured" -ForegroundColor Green

# ─── Done ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   Project ready!                         ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Location : $ProjectDir" -ForegroundColor White
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open VS Code: code `"$ProjectDir`"" -ForegroundColor White
Write-Host "  2. Start Claude Code in that folder" -ForegroundColor White
Write-Host "  3. Type: /session-start" -ForegroundColor White
Write-Host "  4. ARIA will load up and you're ready to work" -ForegroundColor White
Write-Host ""

# Auto-open VS Code if available and not suppressed
if ($codeAvailable -and -not $NoOpen) {
    Write-Host "  Opening VS Code..." -ForegroundColor DarkGray
    code $ProjectDir
}
