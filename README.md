# Story Kit

Story Kit is a Spec Kit-style workflow for writing fiction with an AI assistant in Claude Code. Each stage is a slash command that reads the previous stage's Markdown file and writes its own, so your story stays coherent across sessions and you stay in control of every creative decision.

## Install

Copy these into your project folder:

- `.claude/skills/storykit-*` (the eight commands)
- `.storykit/` (templates, helper scripts, shared rules)

Your stories appear in `stories/<name>/` as plain Markdown files you can open in any editor and keep under your own version control. Helper scripts need `bash` (macOS and Linux). Always run them as `bash <script>`, never `sh`.

## Commands

Usual order: principles (optional) → premise → clarify (optional) → blueprint → scenes → draft → review.

| Command | What it does |
|---|---|
| `/storykit-principles [rules]` | Record standing rules: voice, point of view, tone, themes, content limits, naming. Project-wide, or `--story` for one story (the story's own rule wins). |
| `/storykit-premise <idea>` | Turn an idea into a story brief (max 3 open questions) and make it the active story. |
| `/storykit-clarify` | Up to 5 targeted questions, one at a time; answers go into the brief. |
| `/storykit-blueprint [structure]` | Characters, setting and world rules, plot beats scaled to length, themes. |
| `/storykit-scenes` | Ordered scene list; every beat covered, every scene tied to a beat. |
| `/storykit-draft [scene] [--mode full\|outline\|feedback]` | One scene at a time: a full draft, a beat outline to write from, or feedback on your own text. Also revisions, and `approve S03`. |
| `/storykit-review` | Finds contradictions, timeline errors, unresolved threads, tone drift, point-of-view slips and broken rules. Saves `review.md`; changes nothing else. |
| `/storykit-status [story]` | Where you are, what is out of date, scene progress. Name a story to switch to it. |

## Your files

```text
stories/<name>/
  brief.md  blueprint.md  scenes.md  manuscript.md  review.md
  principles.md        (optional, this story only)
  outlines/S03.md      (beat outlines, outline mode)
.storykit/memory/principles.md   (project-wide rules)
```

## Editing by hand

You can edit any file at any time. Story Kit re-reads what is on disk and:

- never replaces an approved scene, a scene you edited, or text you pasted in without asking you first;
- approves a scene only when you say so, never because you moved on;
- tells you when a document was built from an older version of the one before it, and offers updates (nothing changes without your confirmation).

In `manuscript.md`, each drafted scene sits between `<!-- scene:S03 start -->` and `<!-- scene:S03 end -->` lines. Edit inside those lines and leave the marker lines alone.

## Developing Story Kit

`bash tests/helpers/run-all.sh` runs the script tests and structural checks. The design lives in `specs/001-story-writing-skill/`.
