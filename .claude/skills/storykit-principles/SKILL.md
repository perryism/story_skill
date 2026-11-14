---
name: "storykit-principles"
description: "Record your standing creative rules (voice, point of view, tone, themes, content limits, naming) for all your stories or for one story."
argument-hint: "Your rules in plain words. Add --story to apply them to the current story only."
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

1. **Decide the scope.** If the input contains `--story` (or the writer says "just for this story"), the rules apply to the active story only: file `stories/<slug>/principles.md`. Otherwise they apply project-wide: file `.storykit/memory/principles.md`. For the story scope, run `bash .storykit/scripts/bash/check-prerequisites.sh --json` first to find the story; if none exists, say so and offer `/storykit-premise`.

2. **If the input is empty**, show the writer what is currently recorded (run `bash .storykit/scripts/bash/principles.sh merge`), explain the six headings below in one line each, and ask what they would like to set. Change nothing.

3. **Read the target file** if it exists (use `.storykit/templates/principles-template.md` as the starting shape if not).

4. **Map the writer's rules onto these headings**: Voice, Point of View, Tone, Themes, Content Limits, Naming. Write each rule as a short, clear bullet under its heading. Add to or replace only the headings the writer's rules touch; preserve every other heading and bullet exactly as it is. If a new rule contradicts an existing bullet under the same heading, replace that bullet and tell the writer. Set `**Last updated**` to today's date.

5. **Explain precedence** once, briefly, if both levels exist: a heading in the story's own file replaces the same heading from the project-wide file for that story, and other stories keep the project-wide rule.

6. **Show the result.** Run `bash .storykit/scripts/bash/principles.sh merge` (with `--story <slug>` for story scope) and show the merged rules the writer will now get. Mention that existing documents are not rewritten automatically; `/storykit-review` will flag anything that breaks the new rules.

## You may write

Only the principles file for the chosen scope.
