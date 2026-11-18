---
name: autopilot
description: Run the whole delivery lifecycle unattended from a requirement - planning, backlog, every story through build, four peer reviews and full QA, and release preparation - stopping only at configured human approval points. Re-run with no argument to resume.
argument-hint: "<requirement text or path to a requirement document> (omit to resume)"
disable-model-invocation: true
---

# Autopilot — Requirement to Release

Input: **$ARGUMENTS**

Act as the `orchestrator` (`.claude/agents/orchestration/orchestrator.md`) with
`AUTOMATION_LEVEL = full` behaviour unless `CLAUDE.md` sets `gated`. Follow the
`lean-delivery` skill when `DELIVERY_PROFILE = lean` (the default). Load the
`jira-github-playbook` skill before the first GitHub or Jira action (not in `local` mode).

## 0. Preflight (fail fast)
1. Read `CLAUDE.md` §1 and §1a. Stop and list missing values if any `<<...>>` placeholder
   remains in a setting that the chosen `INTEGRATION_MODE` needs (Jira rows only matter in
   `jira+github`; GitHub rows in `github` and `jira+github`).
2. Check access for the chosen mode only: GitHub (read the repository) in `github` and
   `jira+github`; Jira (fetch the project) in `jira+github`. On failure, stop with the exact
   error and the fix.
3. `git fetch` (not in `local` mode); confirm a clean working tree on the base branch.

## 1. New run or resume
- **Argument given** → new project/feature. Record the intake in `docs/project-state.md`
  (and create the Jira Intake issue in `jira+github` mode). Classify the size (S/M/L).
  **Settle the delivery method before planning** (`delivery-methods` skill §1): from
  `CLAUDE.md`, from "Delivery method: …" in the input, or by asking the user. Unattended with
  no method → stop: "Choose a delivery method: rerun with -Method waterfall | agile |
  agile-customer-review".
- **No argument** → resume from `docs/project-state.md` (and the Intake issue in Jira mode).
  If waiting on a human approval, look for `APPROVED` or `CHANGES: …` from the delivery lead
  in the Activity Log notes or, in Jira mode, the Intake comments; act on it or stop again.
  If waiting on a **customer review**, read `docs/08-sprint-reviews/sprint-NN-feedback.md`, the
  `customer-review` issue or ticket; with an answer, triage it and continue; without one,
  remind and stop again.

## 2. Planning
Lean: the flow in `lean-delivery` §3 (G0 self-check → BA + PM → **G2** → UX ∥ architect →
PO + scrum-master first wave → **G4**). Standard: the `/kickoff` procedure (G0–G4).
Stop at any gate listed in `HUMAN_APPROVAL_POINTS`.

## 3. Building (by delivery method)
- **waterfall:** run every story through `/story-cycle` in backlog order; then QA system test
  and master gate **ST**.
- **agile / agile-customer-review:** sprint by sprint — plan the sprint, run its stories through
  `/story-cycle`, build `sprint/NN`, run the sprint regression, product-owner sprint review.
  In `agile-customer-review`, prepare the review package and feedback form, request the
  customer review and **stop** until the customer answers (gate **CR**).
- After each story and each sprint, call `housekeeper`.

Within this, while Ready stories exist: run the `/story-cycle` procedure for the next one (backlog order,
dependencies done or merged). The scrum-master prepares the next wave while the current
story is in review and QA. After each story add one Activity Log line
(`▶ <id> Done · <n>/<total>`). Stop on: no more stories, or a systemic failure (tooling,
access). A story that hits its loop limit is escalated and skipped; independent stories
continue.

## 4. Closing (G8)
QA release regression, PM release notes, scrum-master retrospective (short), master **G8**.
Wait for a human only if `G8` is in `HUMAN_APPROVAL_POINTS`. Agents never deploy.

Before stopping for any reason, call `housekeeper` so the local copy and GitHub match.

## 5. Final report
Delivery method, stories done / escalated, sprint and customer-review status, PRs or branches and merge state, open findings or defects, gate
decisions, assumptions made, open questions, and exactly what the human needs to do next.
