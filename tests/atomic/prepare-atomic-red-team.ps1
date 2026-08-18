[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$atomicRoot = Join-Path $HOME 'AtomicRedTeam'
$atomicsPath = Join-Path $atomicRoot 'atomics'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git is required. Install it before preparing Atomic Red Team.'
}

Install-Module -Name Invoke-AtomicRedTeam,powershell-yaml -Scope CurrentUser -Force -Repository PSGallery

if (-not (Test-Path (Join-Path $atomicsPath 'T1059.004/T1059.004.yaml'))) {
    if (Test-Path $atomicRoot) {
        throw "Expected atomics are missing under $atomicRoot. Move or remove that directory before retrying."
    }
    git clone --depth 1 --filter=blob:none --sparse https://github.com/redcanaryco/atomic-red-team.git $atomicRoot
    Push-Location $atomicRoot
    try {
        git sparse-checkout set atomics
    }
    finally {
        Pop-Location
    }
}

Write-Host "Atomic test definitions are ready at: $atomicsPath"
Write-Host 'Next, preview a specific test before executing it:'
Write-Host '  pwsh -File tests/atomic/run-atomic-test.ps1 -Technique T1059.004 -TestNumber 8'
