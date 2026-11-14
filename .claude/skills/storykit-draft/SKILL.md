---
name: "storykit-draft"
description: "Work on one scene at a time: write a full draft, a beat outline to write from, or feedback on your own draft. Also revise a scene or approve it."
argument-hint: "Optional: a scene id (S03) and a mode: full, outline, or feedback. Or: approve S03, or revision notes."
user-invocable: true
disable-model-invocation: false
---

## Input

```text
$ARGUMENTS
```

## Before you start

Read `.storykit/conventions.md` and follow it. Plain creative language only. The writer's words are never overwritten without their say-so.

## Steps

1. **Find the story and scene list.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json --require scenes`. If the scene list is missing, say so, offer `/storykit-scenes`, and stop.

2. **Check for staleness.** If STALE says the manuscript is out of date because the scene list changed, tell the writer what changed and offer to update affected scenes. Apply nothing without their confirmation.

3. **Work out what the writer wants** from the input:
   - **Approve**: "approve S03", "S03 is done" → go to step 8.
   - **Revise**: notes about an existing scene ("make S03 tenser") → go to step 7.
   - **Otherwise** choose the scene: the named one, or the first `not-started` scene (`bash .storykit/scripts/bash/scene-status.sh list`).
   - **Mode**: `full` (default), `outline`, or `feedback`. If the writer's wording does not make the mode clear and the scene already has text, ask which they want.

4. **Gather context.** Read the scene's entry in `scenes.md`, the beats it serves and the characters in `blueprint.md`, the brief, all earlier drafted scenes in `manuscript.md`, and the merged principles (`bash .storykit/scripts/bash/principles.sh merge`). Stay consistent with all of it: names, appearances, timeline, voice, point of view.

5. **Protect existing work.** Run `bash .storykit/scripts/bash/scene-hash.sh check <id>`. If the scene's status is `approved`, or the check says `hand-edited` or `unrecorded`, tell the writer plainly that this scene contains their own or approved text, and ask for explicit confirmation before replacing it. Offer feedback mode or a revision instead. If they do not clearly confirm, change nothing.

6. **Do the work in the chosen mode.**

   **Full draft.** Write the scene's prose in line with its purpose, POV, setting, characters, and change. Put it in `manuscript.md` between these markers, in scene-list order (create `manuscript.md` with the header `# <Title>` and `**Built from**: scenes <scenes.md Last updated date>` if it does not exist):

   ```text
   <!-- scene:S03 start -->
   ...prose...
   <!-- scene:S03 end -->
   ```

   Never touch text outside that scene's markers. Then run `bash .storykit/scripts/bash/scene-hash.sh record <id>` and `bash .storykit/scripts/bash/scene-status.sh set <id> drafted`. Show the writer the scene and invite changes or approval.

   **Outline.** Write only a numbered list of beats for the scene to `outlines/<id>.md` in the story folder (no prose paragraphs; short lines). Do not change the manuscript or the status. Tell the writer the scene stays not started until they write their own text.

   **Feedback.** The writer supplies their own text (pasted in the message, or already inside the scene's markers). If pasted, put it between the scene's markers in the manuscript without changing a word, and do not record a hash. Respond with notes against the scene's purpose, point of view, characters, and the principles: what works, what drifts, specific suggestions. Do not rewrite their text. Change no status unless they ask to mark the scene drafted.

7. **Revise.** Change only the named scene's text between its markers, following the writer's notes. Re-record its hash (`scene-hash.sh record <id>`). Never alter any other scene. If the scene is approved or protected (step 5), confirm first.

8. **Approve.** Only when the writer clearly says so. Run `bash .storykit/scripts/bash/scene-status.sh set <id> approved`. Never approve a scene because the writer moved on or asked for the next one.

9. **Report** in plain language: what you did, the scene's status, how many scenes are drafted or approved out of the total, and the likely next step.

## You may write

`manuscript.md` (only the targeted scene's block, plus its header on first use), `outlines/<id>.md`, and the scene's status in `scenes.md` (through the script). Nothing else.
