#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# set-permission-level.sh - choose how much the agent team asks you before acting.
# Saved for this computer in .claude/permission-level (not committed); used by
# start-team.sh and run-autopilot.sh.
#   scripts/set-permission-level.sh            # show current level and options
#   scripts/set-permission-level.sh y          # or: ask-dangerous
# Levels: a ask-all | b ask-commands | c auto-review | y ask-dangerous (default) | z ask-none
# -----------------------------------------------------------------------------
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "[FAIL] Run inside your project's git repository." >&2; exit 1; }
FILE=.claude/permission-level
NAMES=(ask-all ask-commands auto-review ask-dangerous ask-none)
LETTERS=(a b c y z)
TEXT=("Ask before every file change, command and GitHub/Jira action."
      "File edits run freely; ask before other commands and any dangerous action."
      "Claude Code's safety reviewer approves routine actions; ask before dangerous ones."
      "Never ask, except before a dangerous action."
      "Never ask, not even for dangerous actions.")
current=ask-dangerous
[ -f "$FILE" ] && current="$(tr -d '[:space:]' < "$FILE")"
show() {
  echo; echo "Permission levels:"
  for i in "${!NAMES[@]}"; do
    mark=" "; [ "${NAMES[$i]}" = "$current" ] && mark=">"
    printf " %s %s) %-14s %s\n" "$mark" "${LETTERS[$i]}" "${NAMES[$i]}" "${TEXT[$i]}"
  done
  echo; echo "Change it with:  scripts/set-permission-level.sh <letter or name>"
}
if [ -z "${1:-}" ]; then echo "Current level: $current"; show; exit 0; fi
wanted=""
for i in "${!NAMES[@]}"; do
  if [ "$1" = "${NAMES[$i]}" ] || [ "$1" = "${LETTERS[$i]}" ]; then wanted="${NAMES[$i]}"; idx=$i; fi
done
[ -n "$wanted" ] || { echo "[FAIL] Unknown level '$1'." >&2; show; exit 1; }
printf '%s' "$wanted" > "$FILE"
echo "[ OK ] Permission level set to $wanted (${LETTERS[$idx]}): ${TEXT[$idx]}"
[ "$wanted" = ask-none ] && echo "[WARN] Agents will now run every action without asking, including deleting files and running deployment tools. Only the safety floor is still blocked."
case "$wanted" in ask-all|ask-commands) echo "       Unattended runs cannot ask you, so actions that need approval are refused there. Use c, y or z for unattended runs.";; esac
echo "       Start the team with: scripts/start-team.sh   (restart any open Claude Code session to apply)"
