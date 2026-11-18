<#
  housekeeping.ps1 - Windows wrapper for housekeeping.sh (runs it with Git Bash).
  (a) Deletes temporary files the agents no longer need.
  (b) Keeps the local repository and its GitHub copy in sync.

  Usage (from the repository folder, in PowerShell):
    .\scripts\housekeeping.ps1                  # preview only
    .\scripts\housekeeping.ps1 --apply          # do it
    .\scripts\housekeeping.ps1 --apply --clean-only
    .\scripts\housekeeping.ps1 --apply --sync-only
    .\scripts\housekeeping.ps1 --apply --keep-logs 20
#>
$ErrorActionPreference = 'Continue'

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Host "[FAIL] Run this inside your project's git repository folder." -ForegroundColor Red; exit 1 }
Set-Location $root

$bash = $null
if ($IsLinux -or $IsMacOS) { $bash = 'bash' }
else {
  $candidates = @()
  if ($env:CLAUDE_CODE_GIT_BASH_PATH) { $candidates += $env:CLAUDE_CODE_GIT_BASH_PATH }
  if ($env:ProgramFiles) { $candidates += (Join-Path $env:ProgramFiles 'Git\bin\bash.exe') }
  if (${env:ProgramFiles(x86)}) { $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe') }
  if ($env:LOCALAPPDATA) { $candidates += (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe') }
  $bash = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}
if (-not $bash) { Write-Host "[FAIL] Git Bash not found. Install Git for Windows: winget install Git.Git" -ForegroundColor Red; exit 1 }

& $bash 'scripts/housekeeping.sh' @args
exit $LASTEXITCODE
