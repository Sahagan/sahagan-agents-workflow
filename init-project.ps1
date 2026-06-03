#!/usr/bin/env pwsh
# Root-level shortcut — delegates to scripts/init-project.ps1
# Lets you run from the template folder without typing scripts/
#
# Usage (after cloning this repo):
#   .\init-project.ps1 project-b
#   .\init-project.ps1 project-b https://github.com/user/repo.git
#   .\init-project.ps1 project-b https://github.com/user/repo.git D:\projects

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false, Position=1)]
    [string]$RepoUrl = "",

    [Parameter(Mandatory=$false, Position=2)]
    [string]$OutputDir = $PWD,

    [switch]$NoOpen
)

& "$PSScriptRoot\scripts\init-project.ps1" `
    -ProjectName $ProjectName `
    -RepoUrl $RepoUrl `
    -OutputDir $OutputDir `
    -NoOpen:$NoOpen
