#!/usr/bin/env pwsh
# init-project.ps1 — Init a new project workspace from Sahagan Agent Template
#
# Usage (after bootstrap):
#   init-project my-project
#   init-project my-project https://github.com/user/repo.git
#   init-project my-project https://github.com/user/repo.git D:\projects
#
# One-time bootstrap:
#   $b64 = (gh api repos/Sahagan/sahagan_agent_template/contents/scripts/bootstrap.ps1 --jq '.content') -join ''
#   [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)) | iex

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [string]$RepoUrl = "",
    [string]$OutputDir = $PWD,
    [string]$TemplateRepo = "Sahagan/sahagan_agent_template",
    [switch]$NoOpen
)

$ErrorActionPreference = "Stop"
$ProjectDir = Join-Path $OutputDir $ProjectName

# ─── Banner ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   ARIA Agent Template — Project Init     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Project  : $ProjectName" -ForegroundColor White
Write-Host "  Location : $ProjectDir" -ForegroundColor White
if ($RepoUrl -ne "") { Write-Host "  Repo     : $RepoUrl" -ForegroundColor White }
Write-Host ""

# ─── Preflight ────────────────────────────────────────────────────────────────

if (Test-Path $ProjectDir) {
    Write-Host "  [ERROR] Directory already exists: $ProjectDir" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  [ERROR] git not found. Install git and retry." -ForegroundColor Red
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "  [ERROR] GitHub CLI (gh) not found. Run: winget install GitHub.cli" -ForegroundColor Red
    exit 1
}

$codeAvailable = Get-Command code -ErrorAction SilentlyContinue

# ─── Step 1: Clone agent template (via gh — handles private repo auth) ────────

Write-Host "  [1/4] Cloning agent template..." -ForegroundColor Yellow
gh repo clone $TemplateRepo $ProjectDir -- --quiet 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Failed to clone template: $TemplateRepo" -ForegroundColor Red
    exit 1
}

Remove-Item -Path (Join-Path $ProjectDir ".git") -Recurse -Force
Write-Host "  [1/4] Template ready" -ForegroundColor Green

# ─── Step 2: Initialize project git ───────────────────────────────────────────

Write-Host "  [2/4] Initializing git..." -ForegroundColor Yellow
Push-Location $ProjectDir
git init -q
git add -A
git commit -q -m "Init: $ProjectName from sahagan_agent_template"
Pop-Location
Write-Host "  [2/4] Git initialized" -ForegroundColor Green

# ─── Step 3: Clone project repo ───────────────────────────────────────────────

$ProjectsDir = Join-Path $ProjectDir "projects"
New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null

if ($RepoUrl -ne "") {
    Write-Host "  [3/4] Cloning project repo..." -ForegroundColor Yellow
    $RepoName = ($RepoUrl -split "/" | Select-Object -Last 1) -replace "\.git$", ""
    $RepoPath = Join-Path $ProjectsDir $RepoName

    git clone $RepoUrl $RepoPath 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARN] Failed to clone $RepoUrl — continuing without it" -ForegroundColor DarkYellow
    } else {
        Write-Host "  [3/4] Cloned to projects/$RepoName" -ForegroundColor Green
    }
} else {
    Write-Host "  [3/4] No repo URL — empty projects/ folder created" -ForegroundColor DarkGray
    @"
# Projects

Add your project repos here, or re-run with -RepoUrl next time.
"@ | Set-Content (Join-Path $ProjectsDir "README.md") -Encoding UTF8
}

# ─── Step 4: Configure workspace ──────────────────────────────────────────────

Write-Host "  [4/4] Configuring workspace..." -ForegroundColor Yellow

$claudeMd = Join-Path $ProjectDir "CLAUDE.md"
if (Test-Path $claudeMd) {
    $content = Get-Content $claudeMd -Raw
    Set-Content $claudeMd -Value ("<!-- Project: $ProjectName -->`n" + $content) -Encoding UTF8
}

@"
# Project: $ProjectName

**Initialized:** $(Get-Date -Format "yyyy-MM-dd")
**Template:** sahagan_agent_template

## Project Repo
$(if ($RepoUrl -ne "") { "- $RepoUrl" } else { "- (not set — add to projects/)" })

## Quick Start

```
Open this folder in VS Code → Claude Code → /session-start
```

## Structure

```
$ProjectName/
├── CLAUDE.md               ← ARIA entry point
├── .claude/
│   ├── agents/             ← Kai, Nova, Sage definitions
│   └── skills/             ← /session-start, /assign, /new-session
├── agents/                 ← Persona + memories per agent
│   ├── orchestrator/
│   ├── backend/
│   ├── frontend/
│   └── qa/
├── _shared/                ← Session state, task log, decisions
└── projects/               ← Your code lives here
```
"@ | Set-Content (Join-Path $ProjectDir "PROJECT.md") -Encoding UTF8

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
Write-Host "  1. code `"$ProjectDir`"" -ForegroundColor White
Write-Host "  2. Claude Code → /session-start" -ForegroundColor White
Write-Host ""

if ($codeAvailable -and -not $NoOpen) {
    Write-Host "  Opening VS Code..." -ForegroundColor DarkGray
    code $ProjectDir
}
