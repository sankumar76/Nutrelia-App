---
name: story-cycle
description: Run one Ready story through implementation, four parallel peer reviews (standards, quality, performance, security) and full QA, looping on findings until the story is Done or escalated.
argument-hint: "<story id or Jira key, e.g. STORY-01.02 or PROJ-123> (omit to take the next Ready story)"
disable-model-invocation: true
---

# Story Cycle (Build → Review + QA → Story Gate)

Target story: **$ARGUMENTS**. If empty, take the highest-priority Ready story whose
dependencies are Done — from Jira (`jira+github` mode) or from the story board in
`docs/project-state.md` / `docs/05-backlog/` (`local` and `github` modes).

Act as the orchestrator (`.claude/agents/orchestration/orchestrator.md`). Read
`DELIVERY_PROFILE`, `INTEGRATION_MODE`, `MERGE_POLICY` and `PR_REVIEW_STYLE` from `CLAUDE.md`
§1a. Load the `jira-github-playbook` skill before any GitHub or Jira action (not in `local`
mode). Quality is never reduced: all four reviews and full QA run on every story.

## Lean profile (default)
1. Confirm the story is Ready (or Changes Requested / Rejected for a fix loop).
2. **Start together:** `developer` implements on `feat/<id>-<slug>` **and** `qa-engineer`
   designs test cases (`docs/07-qa/<id>-test-cases.md`, no code).
   - `github` / `jira+github`: developer opens a draft PR early, Dev Record in the PR body.
   - `local`: Dev Record in the story file; no push.
3. **G5 (you):** run the build, lint, type-check and test commands from `CLAUDE.md` on the
   branch. Not green → back to the developer.
4. **One parallel wave:** `reviewer-standards`, `reviewer-quality`, `reviewer-performance`,
   `reviewer-security` (each writes `docs/06-reviews/<id>/<area>.md`) **and** `qa-engineer`
   (automates the designed tests, runs full regression and the security, performance and
   accessibility checks that apply, writes `docs/07-qa/<id>-test-report.md` and defects).
5. **Consolidate** findings and defects into `docs/06-reviews/<id>/consolidated.md` — one fix
   list sorted by severity. With `PR_REVIEW_STYLE = summary`, post it as one PR comment.
6. Anything to fix → status Changes Requested → `developer` fixes the whole list in one pass →
   G5 again → re-run in parallel only the reviewers who requested changes, plus QA
   re-verification and full regression. Loop limit 3, then escalate (Jira comment or
   Activity Log line naming the delivery lead) and continue with independent stories.
7. **Story gate (G6 + G7).** Apply the auto-pass rule in the `lean-delivery` skill §3.6;
   otherwise ask `master`. Record the decision in `docs/00-governance/gate-log.md`.
8. Merge per `MERGE_POLICY` (local `git merge --no-ff` in `local` mode with `all-auto`; PR merge
   in `github` modes), or leave it for a human. Mark the story Done.
9. Update the story board and add one Activity Log line in `docs/project-state.md`.
10. Call `housekeeper` (brief it with the stories still in progress).
In the agile methods, a Done story also waits for its sprint: at the end of the sprint the
orchestrator merges all sprint stories into `sprint/NN` for the sprint review.

## Standard profile
Same as above, except: QA test design starts after the reviews; the four reviewers run
first (G6, decided by `master`), then QA (G7, decided by `master`), each with its own fix loop.

## Report
Final status, loops taken, findings fixed by severity and area, defects found and fixed, PR
link or branch name and merge state, and the next Ready story.
