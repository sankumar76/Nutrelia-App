---
name: kickoff
description: Start a new project or major feature and run planning only - discovery, PRD, UX, architecture, backlog and the first ready stories - through the agent team with gate decisions.
argument-hint: "<project or feature request, or path to an intake document>"
disable-model-invocation: true
---

# Project Kickoff (Planning)

Request from the user: **$ARGUMENTS**

Act as the orchestrator (`.claude/agents/orchestration/orchestrator.md`): delegate, never
author other roles' artefacts. Read `DELIVERY_PROFILE` and `INTEGRATION_MODE` from
`CLAUDE.md` §1a. In `jira+github` mode, also create or find the Jira Intake issue and record
briefs, hand-offs and gate decisions there (load the `jira-github-playbook` skill first).

## Lean profile (default)
1. **Intake + size (G0, you).** Record the request in `docs/project-state.md` (problem,
   sponsor, outcome, constraints, inputs) and classify it S / M / L. Ask the user only for a
   missing fact that has no sensible default. **Settle the delivery method** (waterfall /
   agile / agile-customer-review) per the `delivery-methods` skill and record it.
2. `business-analyst` → one brief with the requirements table inside.
3. `product-manager` → PRD (FR/NFR tables, scope). `master` → **G2** (G1 + G2 checklists).
4. In parallel: `ux-expert` (skip if nothing is user-facing) and `solution-architect`
   (architecture with test-strategy section, ADRs only for hard-to-reverse decisions).
5. `product-owner` → epics + consistency check; `scrum-master` → first wave of 3–5 stories in
   full, the rest as one-line backlog entries (**waterfall: every story in full**; agile
   methods: the sprint-01 plan); `product-owner` → Definition of Ready check.
   `master` → **G4** (G3 + G4 checklists).
6. Stop at any gate listed in `HUMAN_APPROVAL_POINTS`.

## Standard profile
G0 → `business-analyst` (brief, requirements catalogue, stakeholder map) → G1 →
`product-manager` (PRD, release plan) → G2 → `ux-expert` ∥ `solution-architect` → G3 →
`product-owner` (epics, consistency report, backlog) → `scrum-master` (sprint-01 plan and
stories) → DoR validation → G4.

On NO-GO, route the remediation to its owner and re-gate (two attempts, then escalate).
Update `docs/project-state.md` after each step (one Activity Log line per hand-off).

Finish with: gates passed, artefacts (paths), assumptions made, open questions needing a
human, top risks, and the next command (`/story-cycle` or `/autopilot`).
