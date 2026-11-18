#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# start-team.sh - open an interactive Claude Code session as the Orchestrator with the
# saved permission level (default ask-dangerous).
#   scripts/start-team.sh          # saved level
#   scripts/start-team.sh z        # another level for this session only
# -----------------------------------------------------------------------------
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "[FAIL] Run inside your project's git repository." >&2; exit 1; }
source "$(dirname "$0")/_permission-level.sh"
resolve_level "${1:-${PERMISSION_LEVEL:-}}" || exit 1
echo "Starting the delivery team (permission level: $LEVEL_NAME, mode: $LEVEL_MODE)"
exec claude --agent orchestrator --permission-mode "$LEVEL_MODE" --settings "$LEVEL_FILE"
