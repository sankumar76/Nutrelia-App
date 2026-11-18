---
name: housekeeping
description: Tidy the project now - delete temporary files the agents no longer need and sync the local repository with GitHub - through the housekeeper agent.
disable-model-invocation: true
---

# Housekeeping

Delegate to the `housekeeper` agent with this brief:

```
TASK: Housekeeping on request.
READ FIRST: CLAUDE.md §1a, docs/project-state.md
DO: commit stray work on agent branches, preview, then apply scripts/housekeeping.sh
RETURN: the script summary, every warning, and anything that needs a person.
```

Then show the user the summary and the "Needs a person" list. If the housekeeper could not
apply (for example the preview contained files that look like real work), show what it found
and ask the user what to do.
