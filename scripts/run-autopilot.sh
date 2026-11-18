#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# run-autopilot.sh - run the AI delivery team unattended (Mac / Linux).
#   scripts/run-autopilot.sh "Customers need a portal to view invoices..."
#   scripts/run-autopilot.sh --file requirements/invoice-portal.md
#   scripts/run-autopilot.sh                 # resume where the last run stopped
#   scripts/run-autopilot.sh --file req.md --method agile-customer-review   # method for a new project
# Permission level: the one saved with set-permission-level.sh (default ask-dangerous);
# PERMISSION_LEVEL=a|b|c|y|z overrides it for one run. Nobody can answer questions during an
# unattended run, so any action that would ask is refused and reported instead of waiting.
# Env: GITHUB_PAT (github / jira+github modes), MAX_BUDGET_NOTE (written to the log).
# Logs: .claude/runs/<timestamp>.log (git-ignored).
# -----------------------------------------------------------------------------
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

REQ=""; METHOD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --file) [ -f "${2:-}" ] || { echo "[FAIL] File not found: ${2:-}" >&2; exit 1; }
            REQ="the requirement document at ${2}"; shift ;;
    --method) METHOD="${2:-}"; shift ;;
    *) REQ="$1" ;;
  esac
  shift
done
if [ -n "$METHOD" ]; then
  case "$METHOD" in waterfall|agile|agile-customer-review) ;; *) echo "[FAIL] --method must be waterfall, agile or agile-customer-review." >&2; exit 1 ;; esac
  if [ -z "$REQ" ]; then echo "[WARN] --method only applies when starting a new project; a resumed project keeps its recorded method."
  else REQ="$REQ (Delivery method: $METHOD)"; fi
fi

bash scripts/preflight.sh

source "$(dirname "$0")/_permission-level.sh"
resolve_level "${PERMISSION_LEVEL:-}" || exit 1
case "$LEVEL_NAME" in ask-all|ask-commands)
  echo "[WARN] Level '$LEVEL_NAME' asks before acting, but nobody can answer during an unattended run: those actions will be refused. Consider c, y or z.";; esac

mkdir -p .claude/runs
LOG=".claude/runs/$(date +%Y%m%d-%H%M%S).log"
echo "Autopilot starting (permission level: $LEVEL_NAME, mode: $LEVEL_MODE) - log: $LOG"
echo "note: ${MAX_BUDGET_NOTE:-none} | level: $LEVEL_NAME" | tee -a "$LOG"

PROMPT="/autopilot ${REQ}"
claude -p --agent orchestrator --permission-mode "$LEVEL_MODE" --permission-prompts none \
  --settings "$LEVEL_FILE" "${PROMPT% }" 2>&1 | tee -a "$LOG"

echo "Autopilot run finished. Results: docs/project-state.md (story board and activity log), and GitHub pull requests in github mode."
