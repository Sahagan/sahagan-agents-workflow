#!/usr/bin/env pwsh
# bootstrap.ps1 — One-time setup for Sahagan Agent Template
#
# Run once to install init-project everywhere:
#
#   $b64 = (gh api repos/Sahagan/sahagan_agent_template/contents/scripts/bootstrap.ps1 --jq '.content') -join ''
#   [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)) | iex
#
# After bootstrap, from ANY folder:
#   init-project my-project
#   init-project my-project https://github.com/user/repo.git
#
# To update tools anytime:
#   Update-SahaganTools

param(
    [string]$InstallDir = "$HOME\.sahagan\scripts"
)

$ErrorActionPreference = "Stop"
$REPO = "Sahagan/sahagan_agent_template"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Sahagan Agent Template — Bootstrap     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ─── Preflight ────────────────────────────────────────────────────────────────

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "  [ERROR] GitHub CLI (gh) not found." -ForegroundColor Red
    Write-Host "  Install : winget install GitHub.cli" -ForegroundColor Yellow
    Write-Host "  Then run: gh auth login" -ForegroundColor Yellow
    exit 1
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] Not authenticated. Run: gh auth login" -ForegroundColor Red
    exit 1
}

# ─── Step 1: Download init-project.ps1 via gh api ────────────────────────────

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
$scriptPath = Join-Path $InstallDir "init-project.ps1"

Write-Host "  [1/3] Downloading init-project.ps1..." -ForegroundColor Yellow
$b64 = (gh api "repos/$REPO/contents/scripts/init-project.ps1" --jq '.content') -join ''
[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)) | Set-Content $scriptPath -Encoding UTF8
Write-Host "  [1/3] Saved to: $scriptPath" -ForegroundColor Green

# ─── Step 2: Add/update functions in PowerShell profile ──────────────────────

Write-Host "  [2/3] Updating PowerShell profile..." -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE -Parent
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

$functionBlock = @"

# ── Sahagan Agent Template ────────────────────────────────────────────────────
`$env:PATH = `$env:PATH + ";C:\Program Files\GitHub CLI"

function init-project {
    param(
        [Parameter(Mandatory=`$true)][string]`$ProjectName,
        [string]`$RepoUrl = "",
        [string]`$OutputDir = `$PWD
    )
    & "$scriptPath" -ProjectName `$ProjectName -RepoUrl `$RepoUrl -OutputDir `$OutputDir
}

function Update-SahaganTools {
    Write-Host "  Updating Sahagan tools..." -ForegroundColor Cyan
    `$b64 = (gh api repos/Sahagan/sahagan_agent_template/contents/scripts/bootstrap.ps1 --jq '.content') -join ''
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$b64)) | Invoke-Expression
}
# ─────────────────────────────────────────────────────────────────────────────
"@

$profileContent = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { "" }

if ($profileContent -notlike "*Sahagan Agent Template*") {
    Add-Content -Path $PROFILE -Value $functionBlock -Encoding UTF8
    Write-Host "  [2/3] Profile updated: $PROFILE" -ForegroundColor Green
} else {
    $newContent = $profileContent -replace '(?s)# ── Sahagan Agent Template ──.*?# ─{5,}[^\n]*\n', ($functionBlock.TrimStart() + "`n")
    Set-Content -Path $PROFILE -Value $newContent.TrimEnd() -Encoding UTF8
    Write-Host "  [2/3] Profile refreshed: $PROFILE" -ForegroundColor Green
}

# ─── Step 3: Load for current session ────────────────────────────────────────

Write-Host "  [3/3] Loading for current session..." -ForegroundColor Yellow

$env:PATH = $env:PATH + ";C:\Program Files\GitHub CLI"

function init-project {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectName,
        [string]$RepoUrl = "",
        [string]$OutputDir = $PWD
    )
    & $scriptPath -ProjectName $ProjectName -RepoUrl $RepoUrl -OutputDir $OutputDir
}

function Update-SahaganTools {
    Write-Host "  Updating Sahagan tools..." -ForegroundColor Cyan
    $b64 = (gh api repos/Sahagan/sahagan_agent_template/contents/scripts/bootstrap.ps1 --jq '.content') -join ''
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64)) | Invoke-Expression
}

Write-Host "  [3/3] Ready in this session" -ForegroundColor Green

# ─── Done ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   Bootstrap complete!                    ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  From ANY folder:" -ForegroundColor Cyan
Write-Host ""
Write-Host "    init-project my-project" -ForegroundColor White
Write-Host "    init-project my-project https://github.com/user/repo.git" -ForegroundColor White
Write-Host ""
Write-Host "  To update tools:" -ForegroundColor Cyan
Write-Host "    Update-SahaganTools" -ForegroundColor White
Write-Host ""
Write-Host "  (Restart PowerShell to activate in new terminals)" -ForegroundColor DarkGray
Write-Host ""
