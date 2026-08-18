[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^T[0-9]{4}(\.[0-9]{3})?$')]
    [string]$Technique,
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 99)]
    [int]$TestNumber,
    [switch]$Execute,
    [switch]$Cleanup
)

$ErrorActionPreference = 'Stop'
$atomicsPath = Join-Path (Join-Path $HOME 'AtomicRedTeam') 'atomics'
if (-not (Test-Path $atomicsPath)) {
    throw "Atomics folder not found at $atomicsPath. Run prepare-atomic-red-team.ps1 first."
}

Import-Module Invoke-AtomicRedTeam -Force
Write-Host "Previewing $Technique test $TestNumber. Read its commands and dependencies before execution."
Invoke-AtomicTest $Technique -TestNumbers $TestNumber -ShowDetails -PathToAtomicsFolder $atomicsPath

if (-not $Execute) {
    Write-Host 'Preview only: no atomic test was run.'
    Write-Host 'To execute after review, set ATOMIC_LAB_APPROVED=YES and add -Execute.'
    exit 0
}

if ($env:ATOMIC_LAB_APPROVED -ne 'YES') {
    throw 'Execution blocked. Set ATOMIC_LAB_APPROVED=YES only after reviewing the displayed test.'
}

if ($Cleanup) {
    Invoke-AtomicTest $Technique -TestNumbers $TestNumber -Cleanup -PathToAtomicsFolder $atomicsPath
}
else {
    Invoke-AtomicTest $Technique -TestNumbers $TestNumber -PathToAtomicsFolder $atomicsPath
}
