# Command Contracts

Eight slash commands, each a skill under `.claude/skills/`. Every command: resolves the active story (or accepts an explicit story name), checks prerequisites through `check-prerequisites.sh`, and uses plain creative language in all messages (FR-018). "Writes" lists the only files a command may change.

Common error behavior: missing prerequisite → name the missing stage, offer to run it, change nothing (FR-014). Empty required input → say what is needed, change nothing.

## /storykit-principles
- **Input**: optional free text of rules; optional `--story` to target one story instead of the project.
- **Effects**: records or updates Voice, Point of View, Tone, Themes, Content Limits, Naming.
- **Writes**: `.storykit/memory/principles.md` or `stories/<slug>/principles.md`.
- **Rules**: existing sections the writer did not mention are preserved; shows the merged result for the active story.

## /storykit-premise `<idea>`
- **Input**: required story idea (any length; all stated details preserved).
- **Effects**: creates the story folder, sets it active, writes the brief; ≤ 3 open questions; assumptions listed.
- **Writes**: `stories/<slug>/brief.md`, `.storykit/active-story`.
- **Errors**: empty idea → "an idea is required", nothing created.
- **Non-prose requests** (screenplay, comic, interactive fiction): say plainly that v1 treats the idea as prose fiction, then continue.

## /storykit-clarify
- **Prerequisite**: brief.
- **Effects**: asks up to 5 questions one at a time, each with a recommended answer, suggested options, and a free-form option; writes answers into the brief and removes resolved open questions.
- **Writes**: `brief.md` only.
- **No gaps**: reports "nothing needs clarifying", writes nothing.

## /storykit-blueprint `[structure]`
- **Prerequisite**: brief. Open questions in the brief trigger a warning, not a block.
- **Effects**: produces characters, setting and world rules, beats (scaled to target length), themes; honors the named structure.
- **Writes**: `blueprint.md`. If it exists, asks before replacing.

## /storykit-scenes
- **Prerequisite**: blueprint.
- **Effects**: ordered scene list with purpose, POV, setting, characters, change, beat link, status `not-started`; reports uncovered beats or orphan scenes. On re-run, preserves existing statuses and ids and flags newly uncovered beats.
- **Writes**: `scenes.md`.

## /storykit-draft `[scene-id] [--mode full|outline|feedback]`
- **Prerequisite**: scene list.
- **Scene selection**: named scene, else the first `not-started` scene.
- **Modes**: `full` (default) writes prose; `outline` writes beats only; `feedback` reviews the writer's own text for that scene and returns notes without rewriting it. Also handles revision requests ("make scene S03 tenser") and explicit approval ("approve S03").
- **Writes**: `manuscript.md` (full mode and revisions: only that scene's marker block), `outlines/<id>.md` (outline mode), the scene's status in `scenes.md`.
- **Protection**: approved or hand-edited scene → ask for confirmation before replacing.

## /storykit-review
- **Prerequisite**: brief; richer with blueprint, scenes, manuscript.
- **Effects**: finds contradictions, timeline errors, unresolved threads, tone drift, POV slips, principle violations, coverage gaps, stale artifacts.
- **Writes**: `review.md` only (replaced each run). No other file changes.

## /storykit-status
- **Effects**: shows the active story, which stages are done, stale artifacts, and scene status counts. Optional story name switches the active story.
- **Writes**: `.storykit/active-story` only when switching.
