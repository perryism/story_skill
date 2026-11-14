# Research: Story Writing Skill

No `NEEDS CLARIFICATION` items remained after `/speckit-clarify`; the items below are design decisions that the spec deferred to planning.

## R1. Delivery format

- **Decision**: A pack of Claude Code skills (`SKILL.md` files, one per stage) plus Markdown templates and Bash helpers, structured like Spec Kit.
- **Rationale**: The user asked for "an AI skill similar to Spec Kit". Spec Kit's own pattern (skill per command, templates, helper scripts, artifacts on disk) is already proven and already installed in this repo, so its conventions can be studied directly.
- **Alternatives considered**: A single monolithic skill with sub-modes (rejected: loses the command-per-stage model and makes each prompt long and fragile); a standalone app or CLI (rejected: out of scope, the assistant is the engine).

## R2. Where files live

- **Decision**: Machinery in `.storykit/` (hidden), writer content in `stories/<slug>/` (visible), project-wide principles in `.storykit/memory/principles.md`.
- **Rationale**: Resolves the deferred file-layout item. Writers browse and edit `stories/`; the hidden folder keeps templates and scripts out of sight. Mirrors Spec Kit's `.specify/` versus `specs/` split.
- **Alternatives considered**: Everything in one `story/` folder (rejected: mixes writer content with tooling); content inside `.storykit` (rejected: hidden folders discourage hand editing).

## R3. Tracking the active story

- **Decision**: A one-line file `.storykit/active-story` holding the slug, set by `new-story.sh` and `use-story.sh`, and overridable by an explicit story name argument on any command. If the file is missing and exactly one story exists, that story is used; if several exist, the assistant asks.
- **Rationale**: Resolves the deferred multi-story item without relying on git branches (this repo is not a git repo, and writers should not need git). Satisfies FR-015.
- **Alternatives considered**: Git branch per story (rejected: requires git); infer from last-modified (rejected: unpredictable); pass story name every time (rejected: tedious).

## R4. Scene status storage

- **Decision**: Status lives inline in `scenes.md` as a bracketed marker per scene heading, e.g. `## S03 [drafted] The Light Flickers`, with values `not-started`, `drafted`, `approved`. `scene-status.sh` reads and sets it.
- **Rationale**: Keeps one source of truth the writer can hand-edit, with no separate state file that can drift (FR-010). Machine-readable via a single regex.
- **Alternatives considered**: JSON/YAML sidecar (rejected: drifts when the writer edits Markdown, not friendly to non-technical writers).

## R5. Protecting approved and hand-edited prose

- **Decision**: The manuscript wraps each scene in markers `<!-- scene:S03 start -->` and `<!-- scene:S03 end -->`. The draft skill (a) never edits text outside the markers of the scene it is working on, (b) refuses to replace a scene whose status is `approved` without explicit confirmation, and (c) treats a scene whose marker block differs from the last assistant-written version as hand-edited. A hash of the last assistant-written text is kept in a trailing marker `<!-- scene:S03 sha:<hash> -->` so edits are detectable.
- **Rationale**: FR-011 requires protection of hand-edited text, so edits must be detectable without version control. Marker blocks also make single-scene revision (FR-016) mechanical. A marker block with no recorded hash (writer-pasted text) is classed `unrecorded` and protected like hand-edited text, so pasting your own scene in is safe.
- **Alternatives considered**: Separate file per scene (rejected: harder to read as one story; the manuscript can be compiled, but the writer reads continuously); relying on git diff (rejected: git is not guaranteed).

## R6. Reporting and the review stage

- **Decision**: Review writes `stories/<slug>/review.md`, replacing the previous file, with findings in a table of ID, severity (high/medium/low), type, locations (file and heading/scene id), and description. It modifies nothing else.
- **Rationale**: Directly implements the clarified FR-012. Stable finding structure lets a seeded test check recall for SC-004.
- **Alternatives considered**: Dated history of reports (rejected by the user's clarification answer).

## R7. Change propagation after upstream edits

- **Decision**: Each artifact carries a `Last updated` date line, and each downstream artifact records the dates of the upstream versions it was built from (`Built from: brief 2026-11-13`). Skills compare these and report staleness, then offer updates with confirmation per change.
- **Rationale**: Implements FR-017 without a database. Works with hand edits since the writer or skill just updates the date.
- **Alternatives considered**: Content hashes of upstream files (rejected: any whitespace edit would trigger false staleness); file modification times (rejected: unreliable across copies and sync tools).

## R8. Principles precedence

- **Decision**: Skills read the project file first, then the per-story file. Principles are Markdown bullets under fixed headings (Voice, Point of View, Tone, Themes, Content Limits, Naming). A heading present in the story file replaces the same heading from the project file.
- **Rationale**: Implements the clarified FR-013 (story rule wins) with an unambiguous merge rule the assistant and a script can both apply.
- **Alternatives considered**: Merging line by line (rejected: ambiguous when two bullets conflict in meaning).

## R9. Testing prompt-driven behavior

- **Decision**: Two layers: deterministic bash tests for scripts, and scripted manual scenarios in `quickstart.md` run against three fixture stories. The seeded-contradictions fixture contains exactly 5 known issues so review recall can be scored against SC-004.
- **Rationale**: Assistant output varies, so exact-match tests are the wrong tool; structural checks (required sections exist, at most 3 open questions, at most 5 clarify questions, no files changed by review except `review.md`) are reliable.
- **Alternatives considered**: LLM-as-judge automation (deferred: valuable later but out of scope for v1).

## R10. Shell portability

- **Decision**: Helpers use `#!/usr/bin/env bash`, avoid Bash 4-only features (no associative arrays, no `mapfile`), and skills invoke them as `bash .storykit/scripts/bash/<name>.sh`.
- **Rationale**: Spec Kit's `common.sh` fails under `sh` on this machine (a syntax error near `<`); invoking explicitly with bash and targeting macOS's Bash 3.2 avoids the same class of failure.
- **Alternatives considered**: Pure POSIX `sh` (rejected: more awkward for JSON output and arrays; bash 3.2 is available everywhere targeted).

## R11. Terminology for non-technical writers

- **Decision**: Command names and prompts use creative terms: premise, brief, blueprint, scenes, draft, review. Spec Kit terms (specify, plan, tasks, implement, analyze, constitution) never appear in user-facing text.
- **Rationale**: FR-018.
- **Alternatives considered**: Reusing Spec Kit's command names (rejected: jargon).
