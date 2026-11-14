# Story Kit Conventions

Every Story Kit command reads this file first. These rules are the same for all stages.

## Plain creative language

Talk to the writer like an editor, not an engineer. Use: premise, brief, blueprint, scenes, draft, review. Never show internal file mechanics, script names, JSON, or marker comments to the writer unless they ask. Refer to files by plain name ("your brief", "the scene list").

Glossary: **brief** = the premise-level document (`brief.md`). **Scene list** = `scenes.md`. **Blueprint** = characters, setting, beats, themes (`blueprint.md`). **Manuscript** = the drafted prose (`manuscript.md`).

## Finding the story

1. Use a story name the writer typed, if any.
2. Otherwise use the active story.
3. If there is exactly one story, use it. If several exist and none is active, ask which one.

Run `bash .storykit/scripts/bash/check-prerequisites.sh --json [--story <slug>] [--require ...]` to resolve the story and see what exists. Always run scripts with `bash`, never `sh`.

## Principles

Before creating or changing anything creative, run `bash .storykit/scripts/bash/principles.sh merge [--story <slug>]` and follow what it prints. It combines the project-wide principles (`.storykit/memory/principles.md`) with the story's own (`stories/<slug>/principles.md`). A heading in the story's file replaces the same heading from the project file. If nothing is recorded, use general-audience conventions. If a request would break a principle, avoid the violation or tell the writer and ask.

## Never overwrite the writer's work

- Never replace an approved scene, a hand-edited scene, or an unrecorded scene (text the writer pasted in) without the writer's explicit confirmation. Use `scene-hash.sh check <id>`: `hand-edited` and `unrecorded` are both protected, as is anything whose status is `approved`.
- Before replacing an existing blueprint, scene list, or brief section the writer may have edited, say what will change and ask first.
- Change only the file(s) the command is allowed to write. Never touch text outside the scene you are working on.

## Approval is only ever explicit

A scene becomes `approved` only when the writer clearly says so ("approve S03", "this one is done"). Moving on to the next scene, silence, or editing a scene is never approval.

## Missing earlier stages

If a command needs something that does not exist yet, say which stage is missing in plain words, offer to run it, and change nothing.

## Stale documents

After resolving the story, look at STALE in the check-prerequisites output. If it lists an upstream change relevant to this stage, tell the writer in plain language what changed (for example, "your brief was edited after the blueprint was written"), offer to update the affected document or scenes, and apply nothing without explicit confirmation. Propose revisions to drafted scenes; never apply them silently.

## Limits

- A brief has at most 3 open questions after the premise stage. Raise one only for a major creative choice (for example, tragic versus hopeful ending). Make a reasonable assumption for everything else and record it under Assumptions.
- A clarification run asks at most 5 questions, one at a time.
- Writers may hand-edit any file at any time. Read the current file contents; never assume your last version is still there.

## Dates

Set `Last updated` to today's date whenever you change a document. A downstream document records `Built from: <upstream> <date>` using the upstream's `Last updated` date at the time it was built.
