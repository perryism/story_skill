---
name: "storykit-blueprint"
description: "Build the story blueprint from the brief: characters, setting and world rules, plot beats scaled to length, and themes."
argument-hint: "Optional: a structure to follow (three-act, hero's journey, ...) and/or a story name"
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

1. **Find the story and brief.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json --require brief`. If the brief is missing, say so, offer `/storykit-premise`, and stop. If the brief still has open questions, warn the writer and offer `/storykit-clarify`, but continue if they want to.

2. **Read the brief and principles.** Read `brief.md` from disk. Run `bash .storykit/scripts/bash/principles.sh merge` and follow what it prints.

3. **Check for staleness.** Using the STALE list from step 1: if the blueprint exists and is stale because the brief changed, tell the writer what changed and offer to update the blueprint. Apply nothing without their confirmation.

4. **If `blueprint.md` already exists**, tell the writer and ask before replacing it. Offer to revise parts instead.

5. **Choose the structure.** If the writer named one in the input, use it exactly. Otherwise choose a fitting structure and state it with one sentence of reasoning. Scale the number of beats to the target length: flash fiction 3 to 4, short story 5 to 8, novella 10 to 15, novel 15 or more. These are guidance, not a hard rule.

6. **Write `blueprint.md`** in the active story folder with these headings:

   ```text
   # <Title> — Blueprint
   **Built from**: brief <the brief's Last updated date>   **Last updated**: <today>
   ## Structure
   ## Characters        (### C1 Name, ### C2 Name, ... each with Role, Goal, Flaw, Relationships, Voice, Arc)
   ## Setting and World Rules
   ## Plot Beats        (### B1 Name, ### B2 Name, ... each with Summary, Characters, Themes)
   ## Themes
   ```

   Rules:
   - Every character listed under Main Characters in the brief must appear, with the same name.
   - Character names are unique.
   - Every beat must trace to a premise element or a character's goal, and name the characters involved.
   - Beats are numbered B1, B2, ... in story order.
   - Respect the principles (for example point of view and content limits) and the brief's tone and ending.

7. **Report**: the structure chosen, the characters in one line each, the beats in order, and the themes. Offer `/storykit-scenes` next. Mention they can edit the blueprint by hand.

## You may write

Only `blueprint.md` of the active story.
