---
name: lean-delivery
description: How the delivery team right-sizes its work - project sizing, short artefacts, merged gates, continuous flow instead of ceremony, parallel review and QA, local tracking modes - without lowering the quality bar. Preloaded into every delivery agent.
---

# Lean Delivery Rules

These rules apply when `DELIVERY_PROFILE = lean` in `CLAUDE.md` §1a (the default). With
`DELIVERY_PROFILE = standard`, ignore sections 2–5 and follow your agent file as written;
sections 1 and 6 apply in every profile.
Where this skill and your agent file disagree on **how much to write, when to stop or which
gate to call**, this skill wins. Your agent file still decides **what good looks like**.

---

## 1. The quality bar never moves

Lean removes paperwork, waiting and repeat cycles. It never removes checks:

- Every story gets **all four peer reviews** — standards, quality, performance and
  security — and **full QA**: every acceptance criterion verified with evidence, the full
  regression suite, plus the security, performance and accessibility checks that apply.
- Every gate checklist item is still evaluated; lean only evaluates some of them together.
- A Blocker, Critical or Major finding, or a Sev-1/Sev-2 defect, always stops a story.
- Tests are never skipped, weakened or deleted to save time.

If saving time would breach any of the above, do not save the time.

## 2. Work like a senior human team

Experienced people do not write documents nobody reads. Apply these habits:

1. **Size first.** At intake the orchestrator classifies the work and records it in
   `docs/project-state.md`:

   | Size | Rough signal | Planning output |
   |------|--------------|-----------------|
   | **S** | up to ~10 stories, one user group, no new infrastructure | One-page plan, no sprints, no milestones |
   | **M** | ~10–30 stories or several user groups | One-page plan, 2–3 milestones, no formal sprints |
   | **L** | 30+ stories, new platform, regulated data, several teams | Full plan with sprints and milestones |

2. **Write once, link after.** State a fact in one artefact and link to it elsewhere. Never
   restate the brief in the PRD, the PRD in the architecture, or the architecture in stories —
   quote only the lines the reader needs.
3. **Short by default** (S / M sizes; L may double these):

   | Artefact | Target length | Notes |
   |----------|---------------|-------|
   | Project brief + requirements | ≤ 2 pages total | One file: `docs/01-discovery/project-brief.md` with the requirements table inside; stakeholder map only if 3+ stakeholder groups |
   | PRD | ≤ 3 pages | FR/NFR tables are the core; no essay sections |
   | UX spec | Only screens the release touches | Reuse existing design-system components by name |
   | Architecture | 1–3 pages + ADRs | ADR only for decisions that are hard to reverse; test strategy is a section here, not a separate file |
   | Epic | ≤ ½ page | |
   | Story | As long as the developer needs, no longer | Dev Context quotes only the rules that apply |
   | Review report / test report | Findings and evidence only | No narrative restating the story |

   Use the template headings that apply; delete those that do not (no "n/a" padding).
4. **Assume, record, continue.** Missing information that has a sensible default becomes a
   labelled ASSUMPTION and work continues. Only a question that makes the work impossible or
   risky to build stops the flow.
5. **No status theatre.** One line per hand-off in the activity log, not paragraphs.

## 3. The lean flow (orchestrator)

> **Combine with the delivery method** (`delivery-methods` skill). `waterfall`: the
> scrum-master writes **every** story in full at step 4 (no waves) and a system test (ST)
> comes before closing. `agile` and `agile-customer-review`: the waves below run inside
> sprints of `STORIES_PER_SPRINT`, and every sprint ends with the sprint review (and, for
> `agile-customer-review`, the customer review stop). Call `housekeeper` after each story,
> sprint or phase, and at the end of the run.

### Planning — two gates instead of five
1. **Intake (G0, no master call).** You check the intake yourself: problem, outcome, sponsor
   (or "self"), constraints. Record the size class.
2. `business-analyst` → brief with requirements table → `product-manager` → PRD.
   Then **master gate "G2" = G1 + G2 checklists together.**
3. **In parallel:** `ux-expert` (skip entirely if nothing is user-facing) and
   `solution-architect`. Architect reconciles with UX in the same pass if UX finished first;
   otherwise one short reconciliation.
4. `product-owner` → epics + consistency check, then `scrum-master` → the **first wave** of
   stories in full (enough to keep the developer busy: 3–5 stories), the rest as one-line
   entries in the backlog. PO validates the wave against the Definition of Ready.
   Then **master gate "G4" = G3 + G4 checklists together.**
5. The plan is the ordered backlog plus, for M/L, milestones. **No separate phase plan,
   sprint plan or milestone document for S/M** — the story board in `docs/project-state.md`
   is the plan.

### Building — continuous flow, review and QA side by side
For each story, in backlog order:
1. **QA test design starts when the story is Ready**, in parallel with the developer:
   `qa-engineer` writes `docs/07-qa/<id>-test-cases.md` (test conditions per AC, edge cases,
   data) — no code, so it never collides with the developer's work.
2. `developer` implements → **G5** (you run build, lint, type-check and tests yourself).
3. **In parallel, one wave:** `reviewer-standards`, `reviewer-quality`,
   `reviewer-performance`, `reviewer-security` **and** `qa-engineer` (automates the designed
   tests, runs full regression and the non-functional checks). Reviewers are read-only, so
   QA committing tests to the branch does not disturb them.
4. Consolidate all findings and defects into **one fix list** for the developer
   (`docs/06-reviews/<id>/consolidated.md`). The developer fixes everything in one pass.
5. Re-run in parallel **only** the reviewers who requested changes, plus QA re-verification
   and full regression. Repeat until clean (loop limit 3, then escalate).
6. **Story gate (G6 + G7 together).** Auto-pass rule — you may record the gate yourself
   when **all** are true: every reviewer verdict is APPROVE or APPROVE WITH COMMENTS; zero
   open Blocker/Critical/Major findings; QA recommends ACCEPT with every AC passed; full
   regression green; no developer rebuttal pending. Record it in
   `docs/00-governance/gate-log.md` as "auto-pass (lean rule)". **Otherwise call `master`**
   (disputes, accepted-with-conditions findings, Sev-3/4 defects to defer, anything unclear).
7. While a story is in review/QA, the scrum-master prepares the next wave of stories so the
   developer never waits.

### Closing
One short wrap-up: QA release regression, PM release notes, scrum-master retrospective
(5–10 lines: what slowed us, what to change in agents/templates), master **G8**. G8 waits for
a human only if `G8` is listed in `HUMAN_APPROVAL_POINTS`; agents never deploy either way.

### Briefs
Delegation briefs are 5–10 lines. Give paths, not pasted content. Ask for the hand-off
block, not a summary of the work.

## 4. Master in lean mode
- Gates you decide: **G2** (G1+G2 checklists), **G4** (G3+G4 checklists), story gates only
  when the orchestrator calls you (see 3.6), **G8**.
- Your checklists are unchanged; evaluate the combined items in one pass and one record.
- Be decisive: a CONDITIONAL GO with owned conditions is better than a NO-GO that costs a
  full round trip, unless a mandatory item fails.

## 5. Role notes
- **Business analyst:** one file — brief plus requirements table; workshop questions only
  for genuine blockers.
- **Product manager:** do not restate the brief; FR/NFR tables and scope are the PRD.
- **UX expert:** skip if nothing is user-facing; otherwise only affected screens, all states.
- **Solution architect:** brownfield — document only what the release changes or depends on.
- **Product owner / scrum master:** waves of 3–5 ready stories; the board in
  `docs/project-state.md` replaces sprint plans for S/M sizes.
- **Developer:** read only the sections the story cites; fix a whole consolidated list in one
  pass; run the full quality loop once at the end of the pass, not after each finding.
- **Reviewers:** review the diff, not the whole codebase; findings only, no essays.
- **QA:** design tests while the story is being built; automate and execute during the
  review wave; complete coverage is still required.

## 6. Tracking modes (`INTEGRATION_MODE` in `CLAUDE.md` §1a)

| Mode | Stories and status | Conversation trail | Code and reviews | Defects |
|------|--------------------|--------------------|------------------|---------|
| `local` | `docs/05-backlog/stories/*.md` + story board in `docs/project-state.md` | One line per hand-off in the **Activity Log** of `docs/project-state.md` | Local git branches only; no pushes, no GitHub API; reviews in `docs/06-reviews/` | `docs/07-qa/defects/DEF-NNN.md` |
| `github` (default) | Same as `local` | Same as `local` | Feature branches pushed; one GitHub PR per story; reviews posted per `PR_REVIEW_STYLE` | `DEF-NNN.md` **and** a GitHub issue |
| `jira+github` | Jira (as in your agent file) | Jira comments | GitHub PRs | Jira Bug + GitHub issue |

When your agent file lists **Jira & GitHub Duties** and the mode is not `jira+github`:
- Do the GitHub parts only in `github` mode; skip them in `local` mode.
- Replace each Jira step with its local equivalent: create/update the story file instead of
  a Jira story; set the story's `Status` field and the board row instead of a transition;
  write one Activity Log line instead of a comment; write `DEF-NNN.md` instead of a Jira Bug.
- Load the `jira-github-playbook` skill before the first GitHub action (`github` mode) or the
  first Jira/GitHub action (`jira+github` mode). Do not load it in `local` mode.

In `local` mode, merging follows `MERGE_POLICY`: with `all-auto` the orchestrator merges a
story branch into the base branch locally (`git merge --no-ff`) after the story gate;
otherwise the branch waits for a human.
