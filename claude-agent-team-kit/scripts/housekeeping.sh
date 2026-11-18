#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# housekeeping.sh - (a) delete temporary files the agents no longer need and
# (b) keep the local repository and its GitHub copy in sync.
#
#   scripts/housekeeping.sh                # preview only: shows what would happen
#   scripts/housekeeping.sh --apply        # do it
#   scripts/housekeeping.sh --apply --clean-only | --sync-only
#   scripts/housekeeping.sh --apply --keep-logs 20      # keep the 20 newest run logs
#
# Cleaning only ever touches files that git does NOT track and that match the temporary-file
# list below (or sit in .claude/tmp/). It never touches tracked files, .env files,
# node_modules, virtual environments, agent memory or your personal Claude settings.
#
# Syncing never force-pushes, never pushes the base branch, never rewrites history and never
# deletes an unmerged branch. It pushes agent branches (feat/, fix/, docs/, sprint/) that are
# ahead of GitHub, fast-forwards branches that are behind, deletes local agent branches that are
# merged and already deleted on GitHub, and reports anything it will not touch (diverged
# branches, local commits on the base branch, uncommitted changes).
# -----------------------------------------------------------------------------
set -uo pipefail

APPLY=0; DO_CLEAN=1; DO_SYNC=1; KEEP_LOGS=10
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --clean-only) DO_SYNC=0 ;;
    --sync-only) DO_CLEAN=0 ;;
    --keep-logs) shift; KEEP_LOGS="${1:-10}" ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "[FAIL] Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
case "$KEEP_LOGS" in ''|*[!0-9]*) echo "[FAIL] --keep-logs needs a number" >&2; exit 1 ;; esac

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "[FAIL] Run inside your project's git repository." >&2; exit 1; }
cd "$ROOT"

MODE="github"; BASE="main"
if [ -f CLAUDE.md ]; then
  m="$(sed -n 's/^| *`INTEGRATION_MODE` *| *\*\*\([^*]*\)\*\*.*/\1/p' CLAUDE.md | head -1)"; [ -n "$m" ] && MODE="$m"
  b="$(sed -n 's/^| *Base branch *| *\([^|]*\)|.*/\1/p' CLAUDE.md | head -1 | tr -d ' <>')"; [ -n "$b" ] && BASE="$b"
fi
[ "$APPLY" = 1 ] && ACT="" || ACT="(preview) "
echo "Housekeeping ${ACT}- mode: $MODE, base branch: $BASE"

DELETED=0; PUSHED=0; UPDATED=0; PRUNED=0; ISSUES=0
run() { if [ "$APPLY" = 1 ]; then "$@"; else return 0; fi; }

# ----------------------------------------------------------------------------- clean
if [ "$DO_CLEAN" = 1 ]; then
  echo; echo "== Temporary files"
  PROTECT='^(\.git/|node_modules/|.*/node_modules/|\.venv/|venv/|\.env|.*/\.env|\.claude/agent-memory|\.claude/settings\.local\.json$|\.claude/permission-level$|\.claude/tmp/\.gitkeep$)'
  TEMP='(^\.claude/tmp/.+)|((^|/)[^/]*\.(tmp|temp|bak|orig|rej|swp|swo)$)|((^|/)[^/]*~$)|((^|/)(\.DS_Store|Thumbs\.db|desktop\.ini)$)|((^|/)(npm-debug|yarn-error|yarn-debug|pnpm-debug)\.log[^/]*$)|((^|/)(coverage|test-results|playwright-report|blob-report|\.nyc_output|__pycache__|\.pytest_cache|\.mypy_cache|\.ruff_cache)/)'
  CANDIDATES="$( { git ls-files --others --exclude-standard; git ls-files --others --ignored --directory --exclude-standard; } 2>/dev/null | sort -u )"
  LIST=""
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    printf '%s\n' "$p" | grep -Eq "$PROTECT" && continue
    printf '%s\n' "$p" | grep -Eq "$TEMP" && LIST="${LIST}${p}"$'\n'
  done <<< "$CANDIDATES"
  # Run logs: keep the newest $KEEP_LOGS
  if [ -d .claude/runs ]; then
    OLD_LOGS="$(ls -1t .claude/runs/*.log 2>/dev/null | tail -n +"$((KEEP_LOGS + 1))")"
    [ -n "$OLD_LOGS" ] && LIST="${LIST}${OLD_LOGS}"$'\n'
  fi
  if [ -z "$(printf '%s' "$LIST" | tr -d '[:space:]')" ]; then
    echo "[ OK ] Nothing to clean."
  else
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      echo "${ACT}delete  $p"
      run rm -rf -- "$p" && DELETED=$((DELETED + 1))
    done <<< "$(printf '%s' "$LIST" | sort -u)"
  fi
fi

# ----------------------------------------------------------------------------- sync
if [ "$DO_SYNC" = 1 ]; then
  echo; echo "== Local and GitHub sync"
  DIRTY="$(git status --porcelain --untracked-files=no)"
  if [ -n "$DIRTY" ]; then
    echo "[WARN] Uncommitted changes (not synced; commit them on the right branch first):"
    printf '%s\n' "$DIRTY" | sed 's/^/        /'; ISSUES=$((ISSUES + 1))
  fi
  run git worktree prune
  if [ "$MODE" = local ]; then
    echo "[ OK ] local mode: no GitHub sync."
  elif ! git remote get-url origin >/dev/null 2>&1; then
    echo "[WARN] No 'origin' remote; GitHub sync skipped."; ISSUES=$((ISSUES + 1))
  elif ! git fetch --prune origin >/dev/null 2>&1; then
    echo "[WARN] Could not reach GitHub (git fetch failed); sync skipped."; ISSUES=$((ISSUES + 1))
  else
    CUR="$(git rev-parse --abbrev-ref HEAD)"
    # Base branch: fast-forward only, never push
    if git show-ref --verify --quiet "refs/remotes/origin/$BASE" && git show-ref --verify --quiet "refs/heads/$BASE"; then
      read -r A B <<< "$(git rev-list --left-right --count "$BASE...origin/$BASE")"
      if [ "$A" -gt 0 ]; then
        echo "[WARN] $BASE has $A local commit(s) not on GitHub - push them through a pull request (agents never push $BASE)."; ISSUES=$((ISSUES + 1))
      elif [ "$B" -gt 0 ]; then
        if [ "$CUR" = "$BASE" ]; then
          if [ -z "$DIRTY" ]; then echo "${ACT}update  $BASE (+$B from GitHub)"; run git merge --ff-only -q "origin/$BASE" && UPDATED=$((UPDATED + 1))
          else echo "[WARN] $BASE is $B behind GitHub but has uncommitted changes; not updated."; ISSUES=$((ISSUES + 1)); fi
        else
          echo "${ACT}update  $BASE (+$B from GitHub)"; run git fetch -q origin "$BASE:$BASE" && UPDATED=$((UPDATED + 1))
        fi
      else
        echo "[ OK ] $BASE is in sync with GitHub."
      fi
    fi
    # Agent branches
    for br in $(git for-each-ref --format='%(refname:short)' refs/heads | grep -E '^(feat|fix|docs|sprint)/' || true); do
      [ "$br" = "$BASE" ] && continue
      if git show-ref --verify --quiet "refs/remotes/origin/$br"; then
        read -r A B <<< "$(git rev-list --left-right --count "$br...origin/$br")"
        if [ "$A" -gt 0 ] && [ "$B" -gt 0 ]; then
          echo "[WARN] $br has diverged from GitHub ($A local, $B remote commits) - needs a person."; ISSUES=$((ISSUES + 1))
        elif [ "$A" -gt 0 ]; then
          echo "${ACT}push    $br (+$A)"; run git push -q origin "$br" && PUSHED=$((PUSHED + 1))
        elif [ "$B" -gt 0 ]; then
          if [ "$br" = "$CUR" ]; then
            if [ -z "$DIRTY" ]; then echo "${ACT}update  $br (+$B from GitHub)"; run git merge --ff-only -q "origin/$br" && UPDATED=$((UPDATED + 1))
            else echo "[WARN] $br is behind GitHub but has uncommitted changes; not updated."; ISSUES=$((ISSUES + 1)); fi
          else
            echo "${ACT}update  $br (+$B from GitHub)"; run git fetch -q origin "$br:$br" && UPDATED=$((UPDATED + 1))
          fi
        fi
      else
        UPSTREAM="$(git config --get "branch.$br.merge" || true)"
        MERGED=1; git merge-base --is-ancestor "$br" "origin/$BASE" 2>/dev/null || MERGED=0
        if [ -n "$UPSTREAM" ] && [ "$MERGED" = 1 ] && [ "$br" != "$CUR" ]; then
          echo "${ACT}remove  $br (merged and deleted on GitHub)"; run git branch -d -q "$br" && PRUNED=$((PRUNED + 1))
        elif [ -n "$UPSTREAM" ]; then
          echo "[WARN] $br was deleted on GitHub but is not merged into $BASE - kept."; ISSUES=$((ISSUES + 1))
        else
          echo "${ACT}push    $br (new on GitHub)"; run git push -q -u origin "$br" && PUSHED=$((PUSHED + 1))
        fi
      fi
    done
  fi
fi

echo
SUMMARY="deleted $DELETED, pushed $PUSHED, updated $UPDATED, removed branches $PRUNED, issues $ISSUES"
echo "Summary ${ACT}- $SUMMARY"
if [ "$APPLY" = 1 ]; then
  LOG=docs/00-governance/housekeeping-log.md
  if [ ! -f "$LOG" ]; then
    mkdir -p docs/00-governance
    printf '# Housekeeping Log\n\n| Date | Deleted | Pushed | Updated | Branches removed | Issues |\n|------|---------|--------|---------|------------------|--------|\n' > "$LOG"
  fi
  printf '| %s | %s | %s | %s | %s | %s |\n' "$(date '+%Y-%m-%d %H:%M')" "$DELETED" "$PUSHED" "$UPDATED" "$PRUNED" "$ISSUES" >> "$LOG"
else
  echo "Nothing was changed. Run again with --apply to do it."
fi
exit 0
