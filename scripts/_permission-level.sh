#!/usr/bin/env bash
# Shared helper for start-team.sh and run-autopilot.sh: turns a level letter/name (or the
# saved .claude/permission-level, default ask-dangerous) into LEVEL_NAME, LEVEL_MODE, LEVEL_FILE.
resolve_level() {
  local want="${1:-}" name=ask-dangerous
  [ -f .claude/permission-level ] && name="$(tr -d '[:space:]' < .claude/permission-level)"
  case "$want" in
    "") ;;
    a|ask-all) name=ask-all ;;
    b|ask-commands) name=ask-commands ;;
    c|auto-review) name=auto-review ;;
    y|ask-dangerous) name=ask-dangerous ;;
    z|ask-none) name=ask-none ;;
    *) echo "[FAIL] Unknown level '$want'. Use a, b, c, y or z." >&2; return 1 ;;
  esac
  case "$name" in
    ask-all) LEVEL_MODE=default ;;
    ask-commands) LEVEL_MODE=acceptEdits ;;
    auto-review) LEVEL_MODE=auto ;;
    ask-dangerous|ask-none) LEVEL_MODE=bypassPermissions ;;
    *) echo "[FAIL] Saved level '$name' is not valid - run scripts/set-permission-level.sh" >&2; return 1 ;;
  esac
  LEVEL_NAME=$name
  LEVEL_FILE=.claude/permission-levels/$name.json
  [ -f "$LEVEL_FILE" ] || { echo "[FAIL] Missing $LEVEL_FILE - copy it from the kit." >&2; return 1; }
  return 0
}
