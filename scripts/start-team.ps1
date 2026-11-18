<#
  start-team.ps1 - open an interactive Claude Code session as the Orchestrator, using the
  permission level chosen with set-permission-level.ps1 (default: ask-dangerous).

  Usage (from the repository folder, in PowerShell or the VS Code terminal):
    .\scripts\start-team.ps1                # use the saved level
    .\scripts\start-team.ps1 -Level z       # use another level for this session only
#>
param([string]$Level = "")
$ErrorActionPreference = 'Continue'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Host "[FAIL] Run this inside your project's git repository folder." -ForegroundColor Red; exit 1 }
Set-Location $root

$modes = @{ 'ask-all' = 'default'; 'ask-commands' = 'acceptEdits'; 'auto-review' = 'auto'; 'ask-dangerous' = 'bypassPermissions'; 'ask-none' = 'bypassPermissions' }
$letters = @{ 'a' = 'ask-all'; 'b' = 'ask-commands'; 'c' = 'auto-review'; 'y' = 'ask-dangerous'; 'z' = 'ask-none' }

$name = 'ask-dangerous'
$file = Join-Path '.claude' 'permission-level'
if (Test-Path $file) { $saved = (Get-Content $file -Raw).Trim(); if ($modes.ContainsKey($saved)) { $name = $saved } }
if ($env:PERMISSION_LEVEL) { $Level = $env:PERMISSION_LEVEL }
if ($Level) {
  if ($letters.ContainsKey($Level)) { $name = $letters[$Level] }
  elseif ($modes.ContainsKey($Level)) { $name = $Level }
  else { Write-Host "[FAIL] Unknown level '$Level'. Use a, b, c, y or z." -ForegroundColor Red; exit 1 }
}

$levelFile = Join-Path (Join-Path '.claude' 'permission-levels') "$name.json"
if (-not (Test-Path $levelFile)) { Write-Host "[FAIL] Missing $levelFile - copy it from the kit." -ForegroundColor Red; exit 1 }

Write-Host "Starting the delivery team (permission level: $name, mode: $($modes[$name]))"
& claude --agent orchestrator --permission-mode $modes[$name] --settings $levelFile
exit $LASTEXITCODE
