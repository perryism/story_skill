# Data Model: Story Writing Skill

All entities are stored as Markdown files (see [contracts/artifact-formats.md](contracts/artifact-formats.md)). "Field" below means a labeled line or section in those files.

## Entities

### Story
| Field | Rules |
|-------|-------|
| slug | Lowercase, hyphenated, 2-4 words, unique within `stories/`; derived from the idea |
| title | Free text; may change; slug does not |
| active | Exactly one story is active per project (stored in `.storykit/active-story`) |

Owns: Brief, Blueprint, Scene list, Manuscript, Review Report, optional story Principles. Folder: `stories/<slug>/`.

### Principles
| Field | Rules |
|-------|-------|
| level | `project` (in `.storykit/memory/principles.md`) or `story` (in `stories/<slug>/principles.md`) |
| sections | Voice, Point of View, Tone, Themes, Content Limits, Naming (each optional) |

Merge rule: a section present in the story file replaces the same section from the project file (FR-013). Absent principles fall back to general-audience defaults.

### Brief
Fields: premise, genre, tone, audience, target length (words and category), main characters (name + one line), central conflict, stakes, open questions (0 to 3), assumptions, clarifications log, last updated.

Rules: at most 3 open questions after the premise stage (FR-005); the clarify stage may remove them but never adds more than 5 questions per run (FR-006). Target length defaults to short story, 1,500 to 7,500 words.

### Blueprint
Fields: built-from (brief date), structure (name, e.g. three-act), characters, setting and world rules, plot beats, themes, last updated.

Relationships: Blueprint 1—* Character; Blueprint 1—* Plot Beat; Plot Beat *—* Character; Plot Beat *—* Theme.

### Character
Fields: id (C1..), name, role, goal, flaw, relationships, voice notes, arc. Rules: names unique within a story; the brief's main characters must all appear.

### Plot Beat
Fields: id (B1..), name, summary, characters involved, themes served. Rules: ordered; count scales with target length (flash 3-4, short story 5-8, novella 10-15, novel 15+, as guidance not a hard limit); each traces to a premise element or character goal.

### Scene
Fields: id (S01..), title, status, purpose, point-of-view character, setting, characters present, intended change, beat id(s). Stored as a section in `scenes.md`.

Rules:
- Every beat is covered by at least one scene and every scene references at least one beat (FR-008).
- Order in the file is manuscript order.
- Ids are never reused; removing a scene leaves a gap.

State transitions:

```text
not-started --(full draft written)--> drafted
drafted --(writer explicitly approves)--> approved
drafted --(revision)--> drafted
approved --(replace, only after explicit confirmation)--> drafted
any --(writer hand-edits text)--> status unchanged, scene flagged hand-edited
any --(writer pastes text with no recorded hash)--> status unchanged, scene flagged unrecorded (protected like hand-edited)
```

Approval is never inferred (FR-010). Outline mode and feedback mode do not change status except that feedback on the writer's own text may set `drafted` only if the writer asks.

### Manuscript
One file, scenes wrapped in marker comments (`scene:<id> start/end/sha`). Contains only scenes with prose, in scene-list order. Header: `Built from: scenes <date>`, used for staleness. Rules: text outside a scene's markers is never modified by the assistant.

### Beat Outline
Optional file `outlines/<scene-id>.md` produced in outline mode: ordered beats for the scene, no prose.

### Review Report
Fields: story, generated date, findings (id, severity, type, locations, description), summary counts. Rules: one file per story; each run replaces it (clarified FR-012); finding types: contradiction, timeline, unresolved-thread, tone-drift, pov-slip, principle-violation, coverage-gap, stale-artifact.

## Relationship summary

```text
Project Principles ──┐
                     ├─> (merged) ─> used by every stage
Story Principles ────┘
Story 1—1 Brief 1—1 Blueprint 1—1 Scene list 1—1 Manuscript
Blueprint 1—* Beat ; Blueprint 1—* Character
Scene *—* Beat ; Scene *—1 POV Character
Story 1—1 Review Report (latest)
```
