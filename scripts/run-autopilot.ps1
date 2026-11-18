<#
  run-autopilot.ps1 - run the AI delivery team unattended (no chat window).

  Usage (from the repository folder, in PowerShell):
    .\scripts\run-autopilot.ps1 "Customers need a portal to view invoices and raise disputes..."
    .\scripts\run-autopilot.ps1 -File requirements\invoice-portal.md
    .\scripts\run-autopilot.ps1                  # resume where the last run stopped
    .\scripts\run-autopilot.ps1 -Level z ...     # use another permission level for this run
    .\scripts\run-autopilot.ps1 -File req.md -Method agile-customer-review
                                                 # delivery method for a NEW project:
                                                 # waterfall | agile | agile-customer-review

  Permission level: the one saved with set-permission-level.ps1 (default: ask-dangerous).
  Nobody can answer questions during an unattended run, so any action that would ask is
  refused and reported instead of waiting.

  Environment variables:
    GITHUB_PAT        GitHub token (needed in github and jira+github modes)
    PERMISSION_LEVEL  a / b / c / y / z - overrides the saved level for this run
    MAX_BUDGET_NOTE   free text written to the log (e.g. cost centre)

  Logs are written to .claude\runs\<timestamp>.log (ignored by git).
#>
param(
  [Parameter(Position = 0)][string]$Requirement = "",
  [string]$File = "",
  [string]$Level = "",
  [string]$Method = ""
)
$ErrorActionPreference = 'Continue'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Host "[FAIL] Run this inside your project's git repository folder." -ForegroundColor Red; exit 1 }
Set-Location $root

$req = ""
if ($File) {
  if (-not (Test-Path $File)) { Write-Host "[FAIL] File not found: $File" -ForegroundColor Red; exit 1 }
  $req = "the requirement document at " + ($File -replace '\\', '/')
} elseif ($Requirement) {
  $req = $Requirement
}

if ($Method) {
  if ($Method -notin @('waterfall', 'agile', 'agile-customer-review')) { Write-Host "[FAIL] -Method must be waterfall, agile or agile-customer-review." -ForegroundColor Red; exit 1 }
  if (-not $req) { Write-Host "[WARN] -Method only applies when starting a new project with a requirement; a resumed project keeps its recorded method." -ForegroundColor Yellow }
  else { $req = "$req (Delivery method: $Method)" }
}

& (Join-Path $PSScriptRoot 'preflight.ps1')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Permission level
$modes = @{ 'ask-all' = 'default'; 'ask-commands' = 'acceptEdits'; 'auto-review' = 'auto'; 'ask-dangerous' = 'bypassPermissions'; 'ask-none' = 'bypassPermissions' }
$letters = @{ 'a' = 'ask-all'; 'b' = 'ask-commands'; 'c' = 'auto-review'; 'y' = 'ask-dangerous'; 'z' = 'ask-none' }
$name = 'ask-dangerous'
$levelSaved = Join-Path '.claude' 'permission-level'
if (Test-Path $levelSaved) { $saved = (Get-Content $levelSaved -Raw).Trim(); if ($modes.ContainsKey($saved)) { $name = $saved } }
if ($env:PERMISSION_LEVEL) { $Level = $env:PERMISSION_LEVEL }
if ($Level) {
  if ($letters.ContainsKey($Level)) { $name = $letters[$Level] }
  elseif ($modes.ContainsKey($Level)) { $name = $Level }
  else { Write-Host "[FAIL] Unknown level '$Level'. Use a, b, c, y or z." -ForegroundColor Red; exit 1 }
}
$levelFile = Join-Path (Join-Path '.claude' 'permission-levels') "$name.json"
if (-not (Test-Path $levelFile)) { Write-Host "[FAIL] Missing $levelFile - copy it from the kit." -ForegroundColor Red; exit 1 }
if ($name -in @('ask-all', 'ask-commands')) {
  Write-Host "[WARN] Level '$name' asks before acting, but nobody can answer during an unattended run: those actions will be refused. Consider c, y or z." -ForegroundColor Yellow
}

$runs = Join-Path '.claude' 'runs'
New-Item -ItemType Directory -Force -Path $runs | Out-Null
$log = Join-Path $runs ((Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
$note = if ($env:MAX_BUDGET_NOTE) { $env:MAX_BUDGET_NOTE } else { 'none' }

Write-Host "Autopilot starting (permission level: $name, mode: $($modes[$name])) - log: $log"
"note: $note | level: $name" | Tee-Object -FilePath $log -Append | Out-Host

$prompt = ("/autopilot " + $req).Trim()
& claude -p --agent orchestrator --permission-mode $modes[$name] --permission-prompts none --settings $levelFile $prompt 2>&1 |
  ForEach-Object { "$_" } |
  Tee-Object -FilePath $log -Append
$code = $LASTEXITCODE

Write-Host "Autopilot run finished. Results: docs\project-state.md (story board and activity log), and GitHub pull requests in github mode."
exit $code
