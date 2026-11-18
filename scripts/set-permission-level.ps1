<#
  set-permission-level.ps1 - choose how much the agent team asks you before acting.
  The choice is saved for this computer in .claude\permission-level (not committed) and is
  used by start-team.ps1 and run-autopilot.ps1.

  Usage (from the repository folder, in PowerShell):
    .\scripts\set-permission-level.ps1              # show the current level and the options
    .\scripts\set-permission-level.ps1 y            # or: ask-dangerous
    .\scripts\set-permission-level.ps1 ask-all      # or: a

  Levels:
    a  ask-all        Ask before every file change, command and GitHub/Jira action.
    b  ask-commands   File edits run freely; ask before commands that are not pre-approved
                      and before any dangerous action.
    c  auto-review    Claude Code's built-in safety reviewer approves routine actions;
                      ask before any dangerous action.
    y  ask-dangerous  Never ask, except before a dangerous action.          (default)
    z  ask-none       Never ask, not even for dangerous actions.
  The safety floor in .claude\settings.json (force-push, pushing to main/master, reading
  secret files, sudo, deleting the whole disk or home folder) is blocked at every level.
#>
param([Parameter(Position = 0)][string]$Level = "")
$ErrorActionPreference = 'Continue'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Host "[FAIL] Run this inside your project's git repository folder." -ForegroundColor Red; exit 1 }
Set-Location $root

$levels = [ordered]@{
  'ask-all'       = @{ Letter = 'a'; Mode = 'default';           Text = 'Ask before every file change, command and GitHub/Jira action.' }
  'ask-commands'  = @{ Letter = 'b'; Mode = 'acceptEdits';       Text = 'File edits run freely; ask before other commands and any dangerous action.' }
  'auto-review'   = @{ Letter = 'c'; Mode = 'auto';              Text = "Claude Code's safety reviewer approves routine actions; ask before dangerous ones." }
  'ask-dangerous' = @{ Letter = 'y'; Mode = 'bypassPermissions'; Text = 'Never ask, except before a dangerous action.' }
  'ask-none'      = @{ Letter = 'z'; Mode = 'bypassPermissions'; Text = 'Never ask, not even for dangerous actions.' }
}
$file = Join-Path '.claude' 'permission-level'

function Show-Levels($current) {
  Write-Host ""
  Write-Host "Permission levels:"
  foreach ($k in $levels.Keys) {
    $mark = if ($k -eq $current) { '>' } else { ' ' }
    Write-Host (" {0} {1}) {2,-14} {3}" -f $mark, $levels[$k].Letter, $k, $levels[$k].Text)
  }
  Write-Host ""
  Write-Host "Change it with:  .\scripts\set-permission-level.ps1 <letter or name>"
}

$current = 'ask-dangerous'
if (Test-Path $file) { $saved = (Get-Content $file -Raw).Trim(); if ($levels.Contains($saved)) { $current = $saved } }

if (-not $Level) {
  Write-Host "Current level: $current ($($levels[$current].Letter))"
  Show-Levels $current
  exit 0
}

$wanted = $null
foreach ($k in $levels.Keys) { if ($Level -eq $k -or $Level -eq $levels[$k].Letter) { $wanted = $k } }
if (-not $wanted) { Write-Host "[FAIL] Unknown level '$Level'." -ForegroundColor Red; Show-Levels $current; exit 1 }

Set-Content -Path $file -Value $wanted -NoNewline
Write-Host "[ OK ] Permission level set to $wanted ($($levels[$wanted].Letter)): $($levels[$wanted].Text)" -ForegroundColor Green
if ($wanted -eq 'ask-none') {
  Write-Host "[WARN] Agents will now run every action without asking, including deleting files and running deployment tools. Only the safety floor is still blocked." -ForegroundColor Yellow
}
if ($wanted -in @('ask-dangerous', 'ask-none')) {
  Write-Host "       The first interactive start shows a one-time Claude Code warning about skipping prompts; accept it to continue."
}
if ($wanted -in @('ask-all', 'ask-commands')) {
  Write-Host "       Unattended runs (run-autopilot) cannot ask you anything, so actions that need approval are refused there. Use c, y or z for unattended runs."
}
Write-Host "       Start the team with: .\scripts\start-team.ps1   (restart any open Claude Code session to apply)"
exit 0
