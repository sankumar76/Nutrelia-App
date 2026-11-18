---
name: delivery-methods
description: The three delivery methods a project can run under - waterfall, agile, and agile with customer validation after every sprint - how the method is chosen before a project starts, and what each changes in planning, sprints, reviews, gates and release. Preloaded into every delivery agent.
---

# Delivery Methods

Every project runs under exactly **one** delivery method, chosen **before planning starts**
and recorded in `docs/project-state.md` (`Delivery method` row). The method decides *when*
work is planned, delivered and shown to the customer. It never changes the quality bar:
every story still gets four peer reviews and full QA (see the `lean-delivery` skill §1).

| | 1 · `waterfall` | 2 · `agile` | 3 · `agile-customer-review` |
|---|---|---|---|
| Planning | All requirements, design and **every** story detailed before building starts | First sprint detailed; later stories refined sprint by sprint | Same as `agile` |
| Delivery | Build all stories, then a **system test** of the whole product, then one release | Sprints of `STORIES_PER_SPRINT` stories; a working increment each sprint | Same sprints as `agile` |
| Sprint review | — | Internal: the product owner accepts the increment on the customer's behalf; work continues automatically | **Customer validates** the increment; the team **pauses** until the customer approves or asks for changes |
| Customer sees the product | At the end (acceptance testing) | At the end, or whenever you choose to show it | After **every** sprint |
| Customer feedback | Change requests after release | Product owner adjusts the backlog | Feedback is triaged into the next sprint before it starts |
| Best for | Fixed, well-understood scope; contracts with fixed deliverables | Evolving scope with a trusted product owner | Customers who want to steer the product as it grows |

## 1. Choosing the method (orchestrator)
1. Read `DELIVERY_METHOD` in `CLAUDE.md` §1a. If it names a method, use it.
2. If it is `ask` (the default), use the method given in the request
   (`run-autopilot -Method …` passes it as "Delivery method: …"). Otherwise, for a **new**
   project, ask the user before any planning (AskUserQuestion with the three options and the
   "Best for" line of each). In an unattended run with no method given, **stop** before
   planning and say: "Choose a delivery method: rerun with -Method waterfall | agile |
   agile-customer-review".
3. Record the method in `docs/project-state.md` and in the intake Activity Log line. A
   resumed project always keeps its recorded method; changing it mid-project needs the
   user's explicit instruction and a decision-log entry by `master`.

## 2. Waterfall
- **Planning:** product-manager writes the full PRD; ux-expert and solution-architect design
  the complete scope; product-owner creates every epic; scrum-master writes **every** story in
  full (no waves). Gates G2 and G4 (lean) or G1–G4 (standard) cover the whole scope.
- **Building:** stories run through the normal story cycle in backlog order. No sprints;
  the story board shows overall progress.
- **System test (gate ST, before G8):** after the last story, `qa-engineer` runs a system test
  on the integrated base branch: end-to-end journeys across all stories, full regression,
  system-level performance, security and accessibility checks, and data migration checks.
  Report: `docs/07-qa/system-test-report.md`. `master` decides **ST** with the G7 checklist
  applied to the whole product.
- **Release:** release notes and G8. If `CUSTOMER_REVIEWERS` is set, the release package doubles
  as the customer's acceptance-test (UAT) package (section 4).

## 3. Agile (no customer validation per sprint)
- **Sprint planning:** scrum-master plans `docs/05-backlog/sprint-NN-plan.md`: sprint goal and
  `STORIES_PER_SPRINT` stories (fewer if dependencies require), all Ready.
- **During the sprint:** the normal story cycle per story (lean: waves within the sprint).
- **Sprint increment:** when every sprint story is Done, the orchestrator integrates them on
  `sprint/NN` (section 5) and QA runs the full regression on it.
- **Internal sprint review:** product-owner checks the increment against the sprint goal and
  acceptance criteria and writes a short sprint review (`docs/08-sprint-reviews/sprint-NN-review.md`,
  internal section only). Unmet goals become backlog items. Then the next sprint starts
  automatically.
- **Release:** after the last sprint, QA release regression, release notes, G8.

## 4. Agile with customer validation after every sprint
Everything in section 3, plus:
1. **Review package.** product-owner writes `docs/08-sprint-reviews/sprint-NN-review.md` from
   `docs/templates/sprint-review-package.md`, in plain language for the customer: what is new,
   how to try it (how to run the `sprint/NN` build locally, or the preview link if your CI
   publishes one — agents never deploy), what to check for each story (its acceptance
   criteria as simple steps), known issues, and how to give feedback. QA attaches the test
   evidence. The orchestrator copies `docs/templates/customer-feedback.md` to
   `docs/08-sprint-reviews/sprint-NN-feedback.md` for the customer's answers.
2. **Customer review gate (CR).** The orchestrator records the request (Activity Log line;
   GitHub issue labelled `customer-review` in `github` mode; Jira comment in `jira+github` mode,
   mentioning `CUSTOMER_REVIEWERS`) and **stops**. No new sprint starts until the customer
   answers.
3. **Customer answer** — any of these, read on the next run:
   - `docs/08-sprint-reviews/sprint-NN-feedback.md` filled in (overall decision **APPROVED** or
     **CHANGES**, and per-story Accept / Change / Reject with comments);
   - a comment on the `customer-review` GitHub issue or Jira ticket starting `APPROVED` or
     `CHANGES:`;
   - the user telling the orchestrator in an interactive session.
4. **Triage.** product-owner turns each feedback item into: a defect (bug report linked to the
   story), a change request (new or updated story with acceptance criteria), or a new idea
   (backlog item for product-manager to prioritise). `master` records the CR decision in the
   gate log. Accepted stories are marked **Customer-accepted** on the story board.
5. **Next sprint** plans the changes and defects first, then new stories.
6. With `MERGE_POLICY = all-auto`, the orchestrator merges `sprint/NN` into the base branch after
   **APPROVED**; otherwise the delivery lead merges it.

## 5. Sprint integration branch (agile methods)
- After the last story of a sprint passes its story gate, the orchestrator creates
  `sprint/NN` from the base branch and merges each sprint story branch into it
  (`git merge --no-ff`), runs the build and tests, and pushes it in `github` modes.
- This gives the customer one complete build to try even when code merges into the base
  branch wait for a human. Conflicts go back to the developer as a fix item.
- Stories in the next sprint branch from `sprint/NN` (the previous increment) until it is
  merged into the base branch, so later stories build on earlier ones.

## 6. Who does what differently
| Agent | Waterfall | Agile | Agile + customer review |
|---|---|---|---|
| Orchestrator | No sprints; ST gate before G8 | Sprint loop; `sprint/NN` branches | Sprint loop + CR gate stop and resume |
| Master | Decides ST | Records sprint reviews | Records CR decisions; change-of-method decisions |
| Product owner | Full backlog up front | Internal sprint review | Review package; feedback triage |
| Scrum master | All stories in full up front | Sprint plans | Sprint plans; changes first |
| QA | System test report | Sprint regression on `sprint/NN` | Sprint regression + evidence for the customer |
| Product manager | One release plan | Release plan by sprint | Re-prioritises new ideas from feedback |
