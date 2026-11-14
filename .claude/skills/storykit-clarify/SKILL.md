---
name: "storykit-clarify"
description: "Ask up to 5 targeted questions to settle gaps and contradictions in the story brief, and write the answers back."
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

1. **Find the story and its brief.** Run `bash .storykit/scripts/bash/check-prerequisites.sh --json --require brief` (add `--story <name>` if the writer named one). If the brief is missing, say so in plain words, offer `/storykit-premise`, and stop without changing anything.

2. **Read the current brief** from disk (the writer may have edited it). Also run `bash .storykit/scripts/bash/principles.sh merge` for context.

3. **Look for what matters.** Check the open questions, plus anything vague or contradictory: unclear point of view, tone that conflicts with the premise, stakes that are undefined, an unclear ending, characters without a clear want. Rank gaps by how much they would change the story.

4. **If nothing needs clarifying**, say "Your brief is clear. Nothing needs clarifying." and stop. Write nothing.

5. **Ask questions, one at a time, at most 5 in this run.** Wait for the answer before showing the next question. For each question:
   - Start with `**Question:**` and a full question ending in `?`.
   - One plain sentence on why it matters to the story.
   - `**Recommended:** Option X - <one or two sentences why>`.
   - 2 to 4 lettered options in a table, plus a free-form row ("Your own answer").
   - Tell the writer they can answer with a letter, say "yes" to accept the recommendation, or write their own answer.
   If an answer is unclear, ask a quick follow-up without counting it as a new question.

6. **After each answer, update the brief immediately.**
   - Under `## Clarifications`, make sure a `### Session YYYY-MM-DD` heading for today exists, then add `- Q: <question> → A: <answer>`.
   - Change the affected section (Genre and Tone, Stakes, Main Characters, and so on) so it reflects the answer, replacing any contradicted text instead of adding beside it.
   - Remove the resolved item from `## Open Questions`.
   - Set `**Last updated**` to today's date.

7. **Stop** when the writer says they are done, when nothing important remains, or after 5 questions. If important gaps remain, list them as "Still open" and say they can run this again.

8. **Report**: how many questions were answered, what changed in the brief, and the next step (`/storykit-blueprint`). Remind the writer that a blueprint made earlier may now be out of date.

## You may write

Only `brief.md` of the active story.
