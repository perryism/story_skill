---
name: "storykit-scenes"
description: "Break the blueprint into an ordered scene list where every plot beat is covered and every scene serves a beat."
argument-hint: "Optional: a story name"
user-invocable: true
disable-model-invocation: false
---

## Input

```text
$ARGUMENTS
```

## Before you start

Read `.storykit/conventions.md` and follow it. Plain creative language only.

## Steps

1. **Find the story and blueprint.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json --require blueprint`. If the blueprint is missing, say so, offer `/storykit-blueprint`, and stop.

2. **Check for staleness.** If STALE says the scene list is out of date because the blueprint changed, tell the writer what changed and offer to update the scene list. Apply nothing without their confirmation.

3. **Read** `blueprint.md`, `brief.md` (for target length), and the merged principles (`bash .storykit/scripts/bash/principles.sh merge`). Read `scenes.md` too if it exists.

4. **If `scenes.md` exists, never rebuild it from scratch.** Preserve every existing scene id, status, title, and the writer's hand edits. Do not renumber. Never reuse the id of a removed scene (gaps are fine). Report any beat that no scene covers and any scene that points to no beat, and offer to add or fix scenes; do not silently add them.

5. **If it does not exist, create it** with scenes in manuscript order, ids `S01`, `S02`, ..., all `not-started`. Scale the count to the target length (a short story usually needs 5 to 10 scenes). Use exactly this heading format, because tools read it:

   ```text
   ## S01 [not-started] Scene title
   - Purpose:
   - POV:
   - Setting:
   - Characters:
   - Change:
   - Beats: B1[, B2]
   ```

   File header: `# <Title> — Scenes` then `**Built from**: blueprint <blueprint's Last updated date>   **Last updated**: <today>`.

6. **Check coverage before saying you are done.** Every beat id in the blueprint must be named by at least one scene, and every scene must name at least one existing beat. Each scene needs a purpose, a point-of-view character, a setting, the characters present, and what changes. Fix any gaps.

7. **Run** `bash .storykit/scripts/bash/scene-status.sh list` to confirm the headings are readable.

8. **Report**: the scene list in order (id, title, beat), any coverage notes, and the next step: `/storykit-draft`.

## You may write

Only `scenes.md` of the active story.
