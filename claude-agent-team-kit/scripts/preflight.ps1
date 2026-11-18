<#
  preflight.ps1 - checks everything the agent team needs before a run, for the tracking
  mode set in CLAUDE.md (local / github / jira+github). Stops at the first blocking problem.

  Usage (from the repository folder, in PowerShell):
    .\scripts\preflight.ps1
#>
$ErrorActionPreference = 'Continue'

function Fail([string]$msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red; exit 1 }
function Ok([string]$msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

# 1. Inside a git repository
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "Git is not installed. Install Git for Windows: winget install Git.Git" }
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Fail "Run this inside your project's git repository folder." }
Set-Location $root

# 2. Settings from CLAUDE.md
if (-not (Test-Path 'CLAUDE.md')) { Fail "CLAUDE.md not found in the repository root - copy the kit first." }
$claudeMd = Get-Content 'CLAUDE.md' -Raw
$mode = 'github'
$m = [regex]::Match($claudeMd, '\|\s*`INTEGRATION_MODE`\s*\|\s*\*\*([^*]+)\*\*')
if ($m.Success) { $mode = $m.Groups[1].Value.Trim() }
$deliveryProfile = 'lean'
$p = [regex]::Match($claudeMd, '\|\s*`DELIVERY_PROFILE`\s*\|\s*\*\*([^*]+)\*\*')
if ($p.Success) { $deliveryProfile = $p.Groups[1].Value.Trim() }
if ($mode -notin @('local', 'github', 'jira+github')) { Fail "INTEGRATION_MODE in CLAUDE.md must be local, github or jira+github (found '$mode')." }
$method = 'ask'
$dm = [regex]::Match($claudeMd, '\|\s*`DELIVERY_METHOD`\s*\|\s*\*\*([^*]+)\*\*')
if ($dm.Success) { $method = $dm.Groups[1].Value.Trim() }
if ($method -notin @('ask', 'waterfall', 'agile', 'agile-customer-review')) { Fail "DELIVERY_METHOD in CLAUDE.md must be ask, waterfall, agile or agile-customer-review (found '$method')." }
Ok "Mode: $mode - profile: $deliveryProfile - delivery method: $method"

# 3. Git Bash (Claude Code uses it on Windows to run the kit's guard hooks)
$bashCandidates = @()
if ($env:CLAUDE_CODE_GIT_BASH_PATH) { $bashCandidates += $env:CLAUDE_CODE_GIT_BASH_PATH }
if ($env:ProgramFiles) { $bashCandidates += (Join-Path $env:ProgramFiles 'Git\bin\bash.exe') }
if (${env:ProgramFiles(x86)}) { $bashCandidates += (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe') }
if ($env:LOCALAPPDATA) { $bashCandidates += (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe') }
$gitBash = $bashCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($IsLinux -or $IsMacOS) { Ok "Not Windows - Git Bash check skipped" }
elseif ($gitBash) { Ok "Git Bash found: $gitBash" }
else { Fail "Git Bash not found. Install Git for Windows (winget install Git.Git). The kit's safety hooks need it." }

# 4. Claude Code
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { Fail "Claude Code not found. Install it with:  irm https://claude.ai/install.ps1 | iex" }
$ver = (claude --version 2>$null | Select-Object -First 1)
Ok "Claude Code: $ver"

# 5. JSON parser for the guard hooks
if ((Get-Command jq -ErrorAction SilentlyContinue) -or (Get-Command python3 -ErrorAction SilentlyContinue)) { Ok "JSON parser available" }
else { Fail "Install jq (needed by the safety hooks):  winget install jqlang.jq   - then open a new PowerShell window." }

# 6. Permission level
$levelName = 'ask-dangerous'
$lvlFile = Join-Path '.claude' 'permission-level'
if (Test-Path $lvlFile) { $levelName = (Get-Content $lvlFile -Raw).Trim() }
if (-not (Test-Path (Join-Path (Join-Path '.claude' 'permission-levels') "$levelName.json"))) { Fail "Permission level '$levelName' has no file in .claude\permission-levels - run .\scripts\set-permission-level.ps1" }
Ok "Permission level: $levelName"

# 7. GitHub (github and jira+github modes)
if ($mode -ne 'local') {
  if (-not $env:GITHUB_PAT) { Fail "GITHUB_PAT is not set. Run:  setx GITHUB_PAT `"your-token`"  then open a new PowerShell window. (Or set INTEGRATION_MODE to local.)" }
  Ok "GITHUB_PAT set"
  $origin = git remote get-url origin 2>$null
  if (-not $origin) { Fail "No 'origin' remote configured for this repository." }
  Ok "origin: $origin"
}

# 8. Clean working tree / placeholders
if (git status --porcelain) { Warn "You have uncommitted changes - commit or stash them first; agents branch from the base branch." }
if ($claudeMd -match '<<') { Warn "CLAUDE.md still contains <<placeholders>> - fill in the ones your mode needs (autopilot lists any that block it)." }

# 9. MCP connections for the chosen mode
if ($mode -ne 'local') {
  $mcp = (claude mcp list 2>&1 | Out-String)
  if ($LASTEXITCODE -eq 0 -and $mcp) {
    if ($mcp -match '(?i)github') { Ok "GitHub MCP configured" } else { Fail "GitHub MCP missing - check .mcp.json." }
    if ($mode -eq 'jira+github') {
      if ($mcp -match '(?i)atlassian') { Ok "Atlassian MCP configured" } else { Fail "Atlassian MCP missing - add `"atlassian`" to enabledMcpjsonServers in .claude\settings.json." }
      $atl = ($mcp -split "`n" | Where-Object { $_ -match '(?i)atlassian' }) -join ' '
      if ($atl -match '(?i)needs auth|not authenticated|failed') {
        Fail "Atlassian MCP needs authentication: run 'claude', type /mcp, choose atlassian, then Authenticate."
      }
    }
  } else {
    Warn "Could not list MCP servers; continuing."
  }
}

Write-Host "Preflight passed." -ForegroundColor Green
exit 0
