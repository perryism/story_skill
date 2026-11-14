# Implementation Plan: Story Writing Skill ("Story Kit")

**Branch**: `001-story-writing-skill` | **Date**: 2026-11-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-story-writing-skill/spec.md`

## Summary

Story Kit is a Spec Kit-style workflow for writing fiction, delivered as a set of Claude Code skills (one slash command per stage) plus plain-Markdown templates and a few small shell helpers. Each stage reads the previous stage's Markdown artifact and writes its own into a per-story folder, so the writer can edit anything by hand and track it in their own version control. The approach: mirror Spec Kit's proven layout (skills under `.claude/skills/`, templates and scripts under a hidden config folder, artifacts under a visible content folder) so the structure is familiar, and keep all creative judgement in the skill prompts while keeping all file/state logic (active story, prerequisites, scene status) in deterministic scripts.

## Technical Context

**Language/Version**: Markdown (skill prompts and templates) and POSIX-compatible Bash 3.2+ (helpers; macOS default shell is the lowest bar)

**Primary Dependencies**: Claude Code skills mechanism (`SKILL.md` with frontmatter). No third-party libraries. Helpers use only standard Unix tools (`sh`/`bash`, `grep`, `sed`, `awk`)

**Storage**: Plain files in the writer's project: Markdown artifacts under `stories/<slug>/`, project-level principles in `.storykit/memory/principles.md`, active-story pointer in `.storykit/active-story`

**Testing**: Bash script tests (bats-free, plain `assert` helpers) for the helpers against fixture story folders; scripted manual scenarios in `quickstart.md` for the prompt-driven behavior (assistant output cannot be unit tested deterministically); a seeded-contradiction fixture for the review stage

**Target Platform**: Claude Code (CLI, desktop, VS Code) on macOS and Linux. Windows via PowerShell helpers is out of scope for v1

**Project Type**: Skill pack / template bundle (no server, no UI)

**Performance Goals**: Helpers return in under 1 second on a story with 200 scenes. Stage durations are dominated by the assistant and writer, and are measured by the spec's success criteria rather than by engineering targets

**Constraints**: Everything must work offline except the assistant itself; every artifact must be human-editable plain text; helpers must be idempotent and never modify story content except where a command contract says so; the `sh` vs `bash` problem found in Spec Kit's own scripts must not recur (helpers declare `#!/usr/bin/env bash` and are invoked with `bash`)

**Scale/Scope**: One writer, a handful of stories per project, up to roughly 200 scenes (novel scale); 8 skills, 7 templates, 7 helper scripts

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the unfilled template, so it defines no principles or gates. **Result: PASS (no applicable gates).**

Post-design re-check: still PASS. Recommendation: run `/speckit-constitution` before `/speckit-implement` if the project wants standing rules such as "writer approval is never inferred", which this plan already enforces through FR-010 and FR-011.

## Project Structure

### Documentation (this feature)

```text
specs/001-story-writing-skill/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── commands.md      # The 8 slash commands: inputs, effects, errors
│   ├── artifact-formats.md  # Required sections and markers of each story file
│   └── helper-scripts.md    # CLI contract of the shell helpers
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
.claude/skills/
├── storykit-principles/SKILL.md   # set project/story principles
├── storykit-premise/SKILL.md      # idea -> brief
├── storykit-clarify/SKILL.md      # <=5 questions, answers into brief
├── storykit-blueprint/SKILL.md    # characters, setting, beats, themes
├── storykit-scenes/SKILL.md       # ordered scene list with status
├── storykit-draft/SKILL.md        # full draft | beat outline | feedback
├── storykit-review/SKILL.md       # consistency review -> review.md
└── storykit-status/SKILL.md       # active story, stage progress, scene status

.storykit/
├── templates/
│   ├── principles-template.md
│   ├── brief-template.md
│   ├── blueprint-template.md
│   ├── scenes-template.md
│   ├── manuscript-template.md
│   ├── review-template.md
│   └── scene-outline-template.md
├── scripts/bash/
│   ├── common.sh              # path resolution, slugging, active story
│   ├── new-story.sh           # create stories/<slug>/ and set active
│   ├── check-prerequisites.sh # which artifacts exist; JSON output
│   ├── scene-status.sh        # read/set scene status in scenes.md
│   ├── scene-hash.sh          # detect hand-edited manuscript scenes (marker hashes)
│   ├── principles.sh          # merge project + story principles
│   └── use-story.sh           # switch active story
└── memory/
    └── principles.md          # project-wide principles (created by /storykit-principles)

stories/<slug>/                # writer's content (created per story)
├── principles.md              # optional per-story overrides
├── brief.md
├── blueprint.md
├── scenes.md
├── manuscript.md
├── outlines/<scene-id>.md     # beat outlines (outline mode only)
└── review.md

tests/
├── helpers/                   # bash tests and structural checks
└── fixtures/
    ├── minimal-story/         # brief only
    ├── brief-with-gaps/       # brief with open questions, for clarify
    ├── brief-complete/        # brief with no gaps, for clarify
    ├── full-story/            # all artifacts, consistent
    └── seeded-contradictions/ # 5 deliberate contradictions for SC-004 (with answer key)
```

**Structure Decision**: Single skill-pack project mirroring Spec Kit: skills in `.claude/skills/`, deterministic helpers and templates in `.storykit/`, writer content in `stories/`. Content is kept out of the hidden folder so writers see and own their work; machinery is hidden so it stays out of the way. `.specify/` (this repository's own Spec Kit install) is untouched.

## Complexity Tracking

No constitution violations; nothing to justify.
