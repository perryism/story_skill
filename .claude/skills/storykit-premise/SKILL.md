---
name: "storykit-premise"
description: "Turn a rough story idea into a story brief: premise, genre, tone, audience, length, characters, conflict, and stakes."
argument-hint: "Describe your story idea (one sentence or several pages)"
user-invocable: true
disable-model-invocation: false
---

## The writer's idea

```text
$ARGUMENTS
```

## Before you start

Read `.storykit/conventions.md` and follow it throughout. Talk like an editor: no file paths or script names in what you say to the writer unless they ask.

## Steps

1. **Check the idea.** If the text above is empty, say "I need a story idea to start. Even one sentence works." and stop. Create nothing.

2. **Name the story.** Choose a working title and a short 2 to 4 word name for it (for example "lighthouse-signal"). If the writer asks for a screenplay, comic, or interactive fiction, say plainly that this version of Story Kit treats it as prose fiction, then continue.

3. **Create the story.** Run:

   ```bash
   bash .storykit/scripts/bash/new-story.sh --json "<name>" "<Working Title>"
   ```

   Read `STORY_DIR`, `SLUG` and `BRIEF` from the JSON. If the script says the name is taken, ask the writer whether to continue that existing story or start a new one under the suggested name. Do not overwrite an existing brief.

4. **Check principles.** Run `bash .storykit/scripts/bash/principles.sh merge --story <slug>` and let anything it prints shape your tone and content choices.

5. **Fill in the brief** (edit the file at `BRIEF`, keeping every heading):
   - **Premise**: the writer's idea. Keep every detail they gave you, however long. Do not summarize details away.
   - **Genre and Tone**, **Audience**, **Main Characters** (name, one line each), **Central Conflict**, **Stakes**.
   - **Target Length**: use what the writer said, with a word range and a category (flash, short story, novella, novel). If they did not say, use "Short story, roughly 1,500 to 7,500 words" and note it under Assumptions.
   - **Assumptions**: every minor gap you filled with a reasonable guess, one bullet each. Make the guess; do not ask.
   - **Open Questions**: at most 3, written as `- [ ] question`. Only for major creative choices that change the story (for example, tragic versus hopeful ending, or whose point of view). If nothing major is open, leave the section empty.
   - Set `**Last updated**` to today's date.

6. **Report back** in plain language: the working title, a three-line summary of the brief, the assumptions you made, and any open questions. Offer two next steps: `/storykit-clarify` to settle open questions, or `/storykit-blueprint` to move on. Remind them they can edit the brief by hand at any time.

## You may write

Only the new story's `brief.md` (through the script and your edit) and the active-story pointer (done by the script).
