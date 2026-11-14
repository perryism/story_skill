---
name: "storykit-status"
description: "See where you are: the active story, which stages are done, anything out of date, and scene progress. Name a story to switch to it."
argument-hint: "Optional: a story name to switch to"
user-invocable: true
disable-model-invocation: false
---

## Input

```text
$ARGUMENTS
```

## Before you start

Read `.storykit/conventions.md` and follow it. Plain creative language only. Keep the answer short and scannable so a writer returning after a break can pick up immediately.

## Steps

1. **Switch if asked.** If the input names a story, run `bash .storykit/scripts/bash/use-story.sh <slug>`. If it fails, list the stories that exist (`ls stories/`) and ask which one they meant. Then continue with that story.

2. **List the stories.** If more than one exists, show them and mark the active one. If none exists, say "No stories yet. Start one with /storykit-premise <your idea>." and stop.

3. **Inspect the active story.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json`. If it cannot pick a story, ask which one to use.

4. **Show a progress summary**:
   - Story title and name.
   - Stages: brief, blueprint, scene list, manuscript, review. Mark each done or not yet. Mention open questions still in the brief and whether principles are set (`HAS.principles`, and the project-wide file at `.storykit/memory/principles.md`).
   - **Out of date** items from STALE, in plain words (for example "Your blueprint was written before you last edited your brief"), with an offer to update them. Apply nothing without confirmation.
   - Scene progress if a scene list exists: run `bash .storykit/scripts/bash/scene-status.sh list` and report counts of not started, drafted, and approved, plus the next scene to work on.

5. **Suggest the next step** as one command, chosen from where the story is: no blueprint → `/storykit-blueprint`; no scene list → `/storykit-scenes`; scenes not started → `/storykit-draft`; all drafted → `/storykit-review`; open questions → `/storykit-clarify`.

## You may write

Only the active-story pointer, and only when the writer asks to switch (done by the script).
