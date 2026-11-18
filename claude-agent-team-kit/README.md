# Claude Code Agent Team Kit v4.1 — Requirement to Release

A drop-in configuration that gives a repository a complete AI delivery team in
[Claude Code](https://code.claude.com/docs/en/sub-agents): **Orchestrator, Master, Business
Analyst, Product Manager, UX Expert, Solution Architect, Product Owner, Scrum Master,
Developer, four Peer Reviewers (Standards, Quality, Performance, Security), QA and a Housekeeper**.

Give the team a requirement once. It plans, builds every story on its own branch, runs four
independent reviews and full QA on each, and prepares the release. The plain-language
**Complete Guide** and **File Reference** documents explain everything in this README in
more depth.

## What changed in v4.1
| Area | v4 | v4.1 |
|------|----|------|
| How the project runs | One flow | **Choose a delivery method before the project starts:** `waterfall`, `agile` (no customer check per sprint) or `agile-customer-review` (the customer validates every sprint). `DELIVERY_METHOD = ask` (default) makes the orchestrator ask; `run-autopilot -Method …` answers in advance |
| Customer validation | Only at release (G8) | `agile-customer-review`: after every sprint a review package (`docs/08-sprint-reviews/`) and gate **CR** - the team waits for APPROVED or CHANGES, and changes go first into the next sprint. `waterfall`: whole-product **System Test (ST)** before release |
| UI | Architect's choice | **shadcn/ui** used when it suits the project (`UI_LIBRARY`); optional shadcn MCP server |
| Tidiness | Manual | **Housekeeper agent** + `/housekeeping` + `scripts/housekeeping`: deletes temporary files no longer needed and keeps local branches and GitHub in sync (never force-pushes, never touches the base branch) |
| Temporary files | Anywhere | Only in `.claude/tmp/` (rule 8 in `CLAUDE.md`) |

## What changed in v4
| Area | v3.1 | v4 |
|------|------|----|
| Speed | Every gate and document separately; Jira comment for every step | `DELIVERY_PROFILE = lean` (default): size-based planning, short documents, 2 planning gates, waves of stories, QA test design during development, reviews and QA in one parallel wave, story-gate auto-pass rule |
| Tracking | Jira + GitHub | `INTEGRATION_MODE`: `local` (all in `docs/`), `github` (default: `docs/` + GitHub PRs, no Jira), `jira+github` |
| Reviews | Standards, quality, performance | **+ Security reviewer** (OWASP Top 10 / ASVS, secrets and dependency scans) |
| Approvals | Fixed permissions | **Permission levels a / b / c / y / z**, switchable per computer |
| Waiting | Approval at G8 by default | `HUMAN_APPROVAL_POINTS = none` by default; agents never deploy |

The quality bar is unchanged in every setting: four reviews and full QA on every story.

## 1. What's in the box
```
CLAUDE.md                          Operating model + Project and Delivery & Integration Profile (edit first)
README.md                          This file
.mcp.json                          GitHub (and Atlassian, for jira+github mode) connections
.gitattributes                     Keeps .sh files in Unix line endings (needed on Windows)
.gitignore.claude-kit              Lines to append to your .gitignore
.github/pull_request_template.md   PR body incl. Dev Record and gate checklist
.claude/
  settings.json                    Safety floor (always blocked) + safe pre-approved commands
  permission-levels/*.json         The five permission levels (ask rules per level)
  hooks/restrict-writes.sh         Each role writes only its own artefacts
  hooks/block-git-writes.sh        Read-only roles cannot commit/push
  agents/                          15 agents (orchestration incl. housekeeper, discovery, design, delivery, review, quality)
  tmp/                             Scratch files only - cleaned by the housekeeper (git-ignored)
  skills/
    lean-delivery/                 Right-sizing rules, preloaded into every agent
    delivery-methods/              Waterfall / agile / agile + customer review, preloaded into every agent
    jira-github-playbook/          Jira & GitHub rulebook, loaded only when needed
    autopilot/  kickoff/  story-cycle/  gate-check/  project-status/  housekeeping/   Commands
scripts/                           .ps1 = Windows PowerShell, .sh = Mac/Linux
  set-permission-level             Choose a / b / c / y / z
  start-team                       Open an interactive session as the Orchestrator
  run-autopilot                    Unattended run from a requirement
  preflight                        Setup check for your tracking mode
  setup-github-labels              Creates the 26 GitHub labels the agents use
  housekeeping                     Preview / delete temporary files and sync branches with GitHub
  _permission-level.sh             Helper used by the .sh scripts
docs/                              project-state.md, governance logs, artefact folders (incl.
                                   08-sprint-reviews), standards (coding standards, DoR, DoD),
                                   17 templates (incl. sprint-review-package, customer-feedback)
```

## 2. Settings (`CLAUDE.md` §1a)
| Setting | Default | Options |
|---------|---------|---------|
| `DELIVERY_METHOD` | `ask` | `waterfall`, `agile`, `agile-customer-review` |
| `STORIES_PER_SPRINT` | `5` | any number (agile methods) |
| `CUSTOMER_REVIEWERS` | placeholder | names / emails / GitHub handles, or "delivery lead" |
| `UI_LIBRARY` | `shadcn/ui when suitable` | `none` |
| `DELIVERY_PROFILE` | `lean` | `standard` |
| `INTEGRATION_MODE` | `github` | `local`, `jira+github` |
| `AUTOMATION_LEVEL` | `full` | `gated` |
| `HUMAN_APPROVAL_POINTS` | `none` | e.g. `G2,G4,G8` |
| `MERGE_POLICY` | `docs-auto, code-human` | `all-auto` |
| `PR_REVIEW_STYLE` | `summary` (one consolidated PR comment) | `inline` |
| `REVIEW_IDENTITY` | `single-token` | `reviewer-bot` |

For `jira+github`, also add `"atlassian"` to `enabledMcpjsonServers` in `.claude/settings.json`.
To let agents browse the shadcn/ui component registry, move `"shadcn"` from
`disabledMcpjsonServers` to `enabledMcpjsonServers` (needs Node.js; optional - agents can use
`npx shadcn@latest add …` without it).

## 2a. Delivery methods
| | Waterfall | Agile | Agile + customer review |
|---|---|---|---|
| Planning | Every story written up front | Sprint by sprint | Sprint by sprint |
| Build | Stories in order, each with 4 reviews + QA | Sprints of `STORIES_PER_SPRINT` stories | Same |
| Customer sees it | At the end (System Test, then G8) | At the end (internal sprint reviews by the PO) | **After every sprint** - review package + feedback form |
| Team waits for customer | Only at release | Only at release | After every sprint (gate CR) |

The customer answers in `docs/08-sprint-reviews/sprint-NN-feedback.md` (APPROVED or CHANGES),
or - in github / jira+github modes - with a comment starting `APPROVED:` / `CHANGES:` on the
`customer-review` issue. Then run `.\scripts\run-autopilot.ps1` again to continue.

## 3. Permission levels
| Level | Name | Claude Code mode | Asks you before… |
|-------|------|------------------|------------------|
| a | `ask-all` | `default` | every file change, command and GitHub/Jira action |
| b | `ask-commands` | `acceptEdits` | commands that are not pre-approved, and dangerous actions |
| c | `auto-review` | `auto` | dangerous actions (a built-in safety reviewer handles the rest) |
| y | `ask-dangerous` *(default)* | `bypassPermissions` | dangerous actions only |
| z | `ask-none` | `bypassPermissions` | nothing |

- **Dangerous** = deleting files or folders recursively, hard resets, deleting branches,
  rebasing, publishing packages, docker/kubernetes/terraform/cloud CLIs, global installs,
  merging PRs on GitHub, and editing the kit's own settings, hooks or permission files.
  The list is the `ask` array in `.claude/permission-levels/*.json`.
- **Safety floor (blocked at every level, including z):** force-push, pushing to
  main/master/develop/release, history rewriting, `sudo`, piping downloads into a shell,
  deleting the whole disk or home folder, deleting files or repositories through GitHub,
  reading `.env`, key and secret files. Edit `deny` in `.claude/settings.json` to change it.
- Set: `.\scripts\set-permission-level.ps1 y`; start: `.\scripts\start-team.ps1`.
  `PERMISSION_LEVEL=z` (environment) or `-Level z` overrides for one run.
- Unattended runs (`run-autopilot`) cannot ask, so any action that would ask is **refused and
  reported**, never waited on. Levels a and b are meant for watched sessions.
- Levels y and z show a one-time Claude Code warning on the first interactive start.
- The VS Code **Claude Code panel** does not use these scripts: run `start-team` in the VS Code
  terminal instead, or set the panel's starting mode with `claudeCode.initialPermissionMode`.

## 4. Install (Windows PowerShell)
Prerequisites: Claude Code (`irm https://claude.ai/install.ps1 | iex`), Git for Windows
(`winget install Git.Git`), jq (`winget install jqlang.jq`); GitHub CLI optional
(`winget install GitHub.cli`).
```powershell
cd C:\path\to\your-repository
$kit = "C:\path\to\claude-agent-team-kit"
robocopy $kit . /E /XF README.md .gitignore.claude-kit
Get-Content "$kit\.gitignore.claude-kit" | Add-Content .gitignore
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
Get-ChildItem .\scripts\*.ps1 | Unblock-File
```
Then fill in `CLAUDE.md` §1 and §1a and `docs/standards/coding-standards.md`, and:
```powershell
setx GITHUB_PAT "your-token"           # github / jira+github modes; open a new window after
.\scripts\setup-github-labels.ps1 owner/repo   # github modes, once (after gh auth login)
.\scripts\set-permission-level.ps1 y
.\scripts\preflight.ps1
```
Commit `.claude .github docs scripts .mcp.json CLAUDE.md .gitignore .gitattributes`.
Mac/Linux: same steps with the `.sh` scripts.

**Upgrading from v4:** copy the kit over your repository as above, re-add the four new §1a rows
(`DELIVERY_METHOD`, `STORIES_PER_SPRINT`, `CUSTOMER_REVIEWERS`, `UI_LIBRARY`) to your `CLAUDE.md`,
append the two new `.claude/tmp` lines from `.gitignore.claude-kit`, and re-run `setup-github-labels`.

**Upgrading from v3.x:** copy the kit over your repository as above, then re-apply your edits
to `CLAUDE.md` (the §1a table changed) and `docs/standards/coding-standards.md`. Remove
`.claude/agents/review/` files you did not change only if you want a clean copy.

## 5. Run
```powershell
.\scripts\run-autopilot.ps1 -File requirements\my-project.md   # unattended (asks nothing; method from CLAUDE.md)
.\scripts\run-autopilot.ps1 -File requirements\my-project.md -Method agile-customer-review
.\scripts\run-autopilot.ps1                                    # resume
.\scripts\start-team.ps1                                       # interactive, then e.g.:
#   /autopilot requirements/my-project.md   /kickoff …   /story-cycle STORY-01.02
#   /gate-check G4   /project-status   /housekeeping
.\scripts\housekeeping.ps1                                     # preview clean-up and sync
.\scripts\housekeeping.ps1 --apply                             # do it
```
Progress: `docs/project-state.md` (story board and one-line Activity Log), story files in
`docs/05-backlog/stories/`, reviews in `docs/06-reviews/`, QA in `docs/07-qa/`, and PRs on
GitHub in `github` modes.

## 6. Why lean is faster without lowering quality
| Time sink | Lean answer |
|-----------|-------------|
| Long documents re-stating each other | Size class S/M/L, page targets, write once and link |
| Five planning gates | Two (G2, G4) with the same checklists |
| Sprint ceremonies on small projects | Continuous flow; the story board is the plan |
| Developer waits for stories | Waves of 3–5 ready stories; next wave prepared during review |
| QA starts after review | QA designs tests during development and executes in the review wave |
| Several fix loops | One consolidated fix list per round |
| Master call per story gate | Objective auto-pass rule; master only for disputes |
| Jira comment per step | Local Activity Log (`github`/`local` modes) |
| Waiting for approval prompts | Permission levels c / y / z; no approval points by default |

Models: Opus for the judgement-heavy roles (orchestrator, master, architect, quality and
security reviewers); Sonnet elsewhere. Effort is `medium` for document roles and the orchestrator,
`high` for architect, developer, reviewers, QA and master.

## 7. Safety notes
- Humans own code merges (unless `all-auto`), deployments and scope.
- Use GitHub branch protection on your base branch; the kit's rules are an extra layer.
- Never put secrets or personal data in requirements, docs, Jira or GitHub.
- Level z runs dangerous actions without asking; use it only on a machine and repository
  you can restore.

## 8. Troubleshooting
| Symptom | Fix |
|---------|-----|
| "running scripts is disabled" | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`; `Get-ChildItem .\scripts\*.ps1 \| Unblock-File` |
| Level y/z starts in Manual mode | Your organization disabled bypass/auto mode; use b or c |
| Unattended run reports refused actions | Expected for actions that would ask; raise the level or do them yourself |
| Hooks fail with `$'\r'` | Keep `.gitattributes`; delete `.claude\hooks\*.sh`; `git checkout -- .claude/hooks` |
| Git Bash not found | `winget install Git.Git` or set `CLAUDE_CODE_GIT_BASH_PATH` in settings `env` |
| Unattended run stops with "rerun with -Method" | `DELIVERY_METHOD` is `ask` and nobody could answer: add `-Method waterfall`, `agile` or `agile-customer-review` |
| Team stopped at gate CR | Waiting for the customer: fill `docs/08-sprint-reviews/sprint-NN-feedback.md` (or comment APPROVED:/CHANGES: on the issue), then resume |
| Housekeeping lists a file you need | Run without `--apply` first; move the file out of `.claude/tmp/` or rename it (temp patterns: `*.tmp`, `*.bak`, `*.orig`, …) |
| Housekeeping warns "diverged" | Someone changed the branch on GitHub too; merge it yourself - the housekeeper never force-pushes |
| Atlassian errors in github/local mode | Expected only in `jira+github`; leave `atlassian` out of `enabledMcpjsonServers` |
