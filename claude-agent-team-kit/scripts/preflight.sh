#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# preflight.sh - checks everything the agent team needs before a run, for the tracking
# mode set in CLAUDE.md (local / github / jira+github). Stops at the first blocking problem.
# -----------------------------------------------------------------------------
set -uo pipefail
fail() { echo "[FAIL] $*" >&2; exit 1; }
ok()   { echo "[ OK ] $*"; }
warn() { echo "[WARN] $*"; }

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || fail "Run inside your project's git repository."
[ -f CLAUDE.md ] || fail "CLAUDE.md not found in the repository root - copy the kit first."

MODE="$(sed -n 's/^| *`INTEGRATION_MODE` *| *\*\*\([^*]*\)\*\*.*/\1/p' CLAUDE.md | head -1)"; MODE="${MODE:-github}"
PROFILE="$(sed -n 's/^| *`DELIVERY_PROFILE` *| *\*\*\([^*]*\)\*\*.*/\1/p' CLAUDE.md | head -1)"; PROFILE="${PROFILE:-lean}"
case "$MODE" in local|github|jira+github) ;; *) fail "INTEGRATION_MODE in CLAUDE.md must be local, github or jira+github (found '$MODE').";; esac
METHOD="$(sed -n 's/^| *`DELIVERY_METHOD` *| *\*\*\([^*]*\)\*\*.*/\1/p' CLAUDE.md | head -1)"; METHOD="${METHOD:-ask}"
case "$METHOD" in ask|waterfall|agile|agile-customer-review) ;; *) fail "DELIVERY_METHOD in CLAUDE.md must be ask, waterfall, agile or agile-customer-review (found '$METHOD').";; esac
ok "Mode: $MODE - profile: $PROFILE - delivery method: $METHOD"

command -v claude >/dev/null || fail "Claude Code CLI not found (install: https://code.claude.com/docs)."
ok "Claude Code: $(claude --version 2>/dev/null | head -1)"

command -v jq >/dev/null || command -v python3 >/dev/null || fail "Install jq (needed by the safety hooks)."
ok "JSON parser available"

LEVEL=ask-dangerous
[ -f .claude/permission-level ] && LEVEL="$(tr -d '[:space:]' < .claude/permission-level)"
[ -f ".claude/permission-levels/$LEVEL.json" ] || fail "Permission level '$LEVEL' has no file in .claude/permission-levels - run scripts/set-permission-level.sh"
ok "Permission level: $LEVEL"

if [ "$MODE" != local ]; then
  [ -n "${GITHUB_PAT:-}" ] || fail "GITHUB_PAT is not set (or set INTEGRATION_MODE to local)."
  ok "GITHUB_PAT set"
  git remote get-url origin >/dev/null 2>&1 || fail "No 'origin' remote configured."
  ok "origin: $(git remote get-url origin)"
fi

[ -z "$(git status --porcelain)" ] || warn "You have uncommitted changes - commit or stash them first; agents branch from the base branch."
grep -q '<<' CLAUDE.md && warn "CLAUDE.md still contains <<placeholders>> - fill in the ones your mode needs."

chmod +x .claude/hooks/*.sh scripts/*.sh 2>/dev/null || true
ok "Hooks executable"

if [ "$MODE" != local ]; then
  TMP="$(mktemp)"
  if claude mcp list >"$TMP" 2>&1; then
    grep -qi github "$TMP" && ok "GitHub MCP configured" || fail "GitHub MCP missing - check .mcp.json."
    if [ "$MODE" = jira+github ]; then
      grep -qi atlassian "$TMP" && ok "Atlassian MCP configured" || fail "Atlassian MCP missing - add \"atlassian\" to enabledMcpjsonServers in .claude/settings.json."
      grep -i atlassian "$TMP" | grep -qiE 'needs auth|not authenticated|failed' && \
        fail "Atlassian MCP needs authentication: run 'claude', then '/mcp' -> atlassian -> Authenticate."
    fi
  else
    warn "Could not list MCP servers; continuing."
  fi
  rm -f "$TMP"
fi
echo "Preflight passed."
