---
name: "storykit-review"
description: "Check the whole story for contradictions, timeline errors, unresolved threads, tone drift, point-of-view slips, and broken rules. Saves a review report and changes nothing else."
argument-hint: "Optional: a story name"
user-invocable: true
disable-model-invocation: false
---

## Input

```text
$ARGUMENTS
```

## Before you start

Read `.storykit/conventions.md` and follow it. Plain creative language only. This command reads everything and edits nothing except the review report.

## Steps

1. **Find the story.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json --require brief`. If there is no brief, say so, offer `/storykit-premise`, and stop. The review works on whatever exists: brief only, plus blueprint, scene list, and manuscript when present.

2. **Read** every artifact that exists, in full, from disk: `brief.md`, `blueprint.md`, `scenes.md`, `manuscript.md`, and the merged principles (`bash .storykit/scripts/bash/principles.sh merge`). Note the STALE list.

3. **Look for these kinds of problems**, using exactly these type names:
   - `contradiction`: a fact that differs between places (a character's name, appearance, age, relationship, or a world rule).
   - `timeline`: events in an impossible or inconsistent order or time.
   - `unresolved-thread`: something set up in the brief or blueprint that no scene or draft pays off.
   - `tone-drift`: prose that breaks the stated tone.
   - `pov-slip`: a scene that does not match its scene-list point of view, or breaks the story's point-of-view principle (for example first person where it is forbidden).
   - `principle-violation`: any other broken principle (voice, themes, content limits, naming).
   - `coverage-gap`: a plot beat with no scene, or a scene tied to no beat.
   - `stale-artifact`: a document built from an older version of the one before it (from the STALE list).

4. **Report each finding** with: an id (`F1`, `F2`, ...), a severity (`high`: breaks the story or a hard rule; `medium`: noticeable to a reader; `low`: polish), its type, every location (file plus scene id or heading, for example `manuscript.md#S02` and `blueprint.md#C1`; a contradiction names both places), and a one-sentence description. Quote the conflicting words when useful. Do not invent problems; only report what you can point to.

5. **Write `review.md`** in the story folder, replacing any previous report, in this shape:

   ```text
   # <Title> — Review
   **Generated**: <today>
   ## Summary
   - High: n
   - Medium: n
   - Low: n
   ## Findings
   | ID | Severity | Type | Locations | Description |
   |----|----------|------|-----------|-------------|
   ```

   If you found nothing, say so in the Summary and leave the table empty.

6. **Report to the writer**: counts by severity, the top findings in plain language, and a note that nothing in their story was changed. Offer to help fix specific findings if they ask (as separate, confirmed edits).

## You may write

Only `review.md` of the active story. Never edit any other file.
