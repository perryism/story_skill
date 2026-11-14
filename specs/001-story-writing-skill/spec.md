# Feature Specification: Story Writing Skill

**Feature Branch**: `001-story-writing-skill` (no git branch; this is the spec directory name)

**Created**: 2026-11-13

**Status**: Draft

**Input**: User description: "build an AI skill which is similar to spec kit but it's for writing a story"

## Overview

A structured, command-driven workflow that guides a writer and an AI assistant from a rough story idea to a finished manuscript, the way Spec Kit guides a team from a feature idea to working software. Each stage produces a persistent, human-editable document that feeds the next stage, so the story stays coherent across sessions and the writer stays in control of creative decisions.

Stage mapping (Spec Kit → Story Kit): constitution → story principles (voice, tone, themes, rules); specify → story premise & brief; clarify → story clarification; plan → story blueprint (characters, world, plot structure); tasks → scene/chapter list; implement → drafting; analyze → continuity and consistency review.

## Clarifications

### Session 2026-11-13

- Q: When drafting a scene, should the assistant write full prose or work in smaller steps? → A: Writer chooses per scene: full draft, a beat outline to write from, or feedback on their own draft (default: full draft).
- Q: Should story principles apply project-wide, per story, or both? → A: Both: project-wide defaults plus optional per-story principles; where they conflict, the story's own rule wins.
- Q: How does a scene become "approved"? → A: Only when the writer explicitly approves it; moving on to the next scene does not count.
- Q: After an upstream change, should the assistant only warn or also offer updates? → A: Warn, then offer to update affected plan documents and propose scene revisions; every change needs the writer's confirmation.
- Q: How should consistency review findings be reported? → A: Saved as a review report file in the story folder, replacing the previous report; no other story content is changed.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Turn a rough idea into a story brief (Priority: P1)

A writer has a one-line or one-paragraph story idea ("a retired lighthouse keeper discovers the light has been signaling someone"). They invoke the premise command with that idea. The assistant produces a story brief capturing premise, genre, tone, intended audience, target length, main characters, central conflict, and stakes, flagging a small number of open creative questions rather than inventing answers to the ones that matter most.

**Why this priority**: This is the entry point and the smallest slice that delivers value on its own: a writer leaves with a clear, shareable brief instead of a vague idea. Every later stage depends on it.

**Independent Test**: Provide a one-sentence idea and run only this command. Verify a brief document is created containing all required sections, with no more than 3 unresolved questions, and that the writer can read and edit it as plain text.

**Acceptance Scenarios**:

1. **Given** a project with no story yet, **When** the writer submits a one-sentence idea, **Then** a new story folder is created containing a brief with premise, genre, tone, audience, target length, characters, conflict, and stakes filled in.
2. **Given** an idea that leaves a major creative choice open (e.g., whether the ending is tragic or hopeful), **When** the brief is generated, **Then** that choice is listed as an open question instead of being silently decided.
3. **Given** an empty idea, **When** the command runs, **Then** it tells the writer an idea is required and creates nothing.

---

### User Story 2 - Resolve open questions before planning (Priority: P2)

The writer runs a clarification step. The assistant reads the brief, identifies the most impactful gaps or contradictions (e.g., unclear point of view, conflicting tone, undefined stakes), and asks a limited number of targeted questions, offering suggested answers. The writer's answers are written back into the brief.

**Why this priority**: It prevents expensive rewrites later by surfacing weak foundations early, but a writer can still proceed without it.

**Independent Test**: Run the clarification step on a brief containing known gaps. Verify at most 5 questions are asked, each with suggested options, and that answers appear in the brief afterward.

**Acceptance Scenarios**:

1. **Given** a brief with unresolved questions, **When** the writer runs clarification, **Then** the assistant asks no more than 5 prioritized questions, each with suggested answers and a free-form option.
2. **Given** the writer answers, **When** clarification finishes, **Then** the brief is updated with those answers and the resolved questions are removed from the open list.
3. **Given** a brief with no meaningful gaps, **When** clarification runs, **Then** it reports that nothing needs clarifying.

---

### User Story 3 - Build a story blueprint (Priority: P3)

From the brief, the writer generates a blueprint: character profiles (goals, flaws, arcs), setting and world rules, a plot structure with major beats (setup, inciting incident, midpoint, climax, resolution or a writer-chosen structure), and thematic threads.

**Why this priority**: The blueprint is what makes long-form stories coherent; it unlocks scene planning and drafting.

**Independent Test**: With a completed brief, run the blueprint command. Verify character, setting, and beat sections exist and that every beat traces back to a premise element or character goal.

**Acceptance Scenarios**:

1. **Given** a completed brief, **When** the writer runs the blueprint command, **Then** a blueprint is produced with characters, setting, plot beats, and themes consistent with the brief.
2. **Given** the brief specifies a target length, **When** the blueprint is generated, **Then** the beat count and depth are proportionate to that length (e.g., a short story gets fewer beats than a novella).
3. **Given** the writer prefers a specific structure (e.g., three-act, hero's journey), **When** they state it, **Then** the blueprint follows it.

---

### User Story 4 - Break the blueprint into a scene list (Priority: P4)

The writer generates an ordered scene (or chapter) list. Each entry states purpose, point-of-view character, location, characters present, what changes, and which blueprint beat it serves. Scenes are marked so the writer can see what is drafted and what is not.

**Why this priority**: Gives the writer a concrete, trackable work plan; required before guided drafting.

**Independent Test**: With a blueprint, run the scene-list command. Verify every plot beat is covered by at least one scene and every scene maps to a beat.

**Acceptance Scenarios**:

1. **Given** a blueprint, **When** the scene list is generated, **Then** every beat is covered and each scene lists purpose, point of view, setting, characters, and change.
2. **Given** a scene list, **When** the writer reorders or removes a scene and re-runs the command, **Then** the list updates and flags any beat that is now uncovered.

---

### User Story 5 - Draft scenes with guidance and continuity (Priority: P5)

For the next undrafted scene (or a named scene), the writer chooses a drafting mode: a full draft by the assistant (the default), a beat outline the writer writes from, or feedback on prose the writer has written. In full-draft mode the assistant writes it using the story principles, character voices, and prior drafted content, then marks the scene as drafted. The writer can approve, request revisions, or rewrite it themselves; the assistant never overwrites approved prose without being asked.

**Why this priority**: This is the payoff of the workflow, but it only works well once the earlier artifacts exist.

**Independent Test**: With a scene list, run drafting for one scene. Verify prose is saved to the manuscript, the scene is marked drafted, and the content matches the scene's stated purpose, point of view, and characters.

**Acceptance Scenarios**:

1. **Given** a scene list with undrafted scenes, **When** the writer requests the next scene, **Then** the assistant drafts it, appends it to the manuscript in order, and marks it drafted.
2. **Given** a scene already approved by the writer, **When** the writer asks to draft it again, **Then** the assistant asks for confirmation before replacing it.
3. **Given** the writer chooses the outline mode for a scene, **When** the assistant responds, **Then** it produces a beat-by-beat outline and no prose, and the scene stays not started until the writer supplies their own text.
4. **Given** the writer submits their own draft of a scene for feedback, **When** the assistant responds, **Then** it returns feedback against the scene's purpose, point of view, and story principles without rewriting the writer's text.
5. **Given** the writer requests a revision with feedback (e.g., "more tension, shorter sentences"), **When** the assistant revises, **Then** only that scene changes and other scenes are untouched.

---

### User Story 6 - Check the story for consistency (Priority: P6)

The writer runs a consistency review (which never edits story content) across brief, blueprint, scene list, and drafted prose. The assistant reports contradictions (character name or trait changes, timeline errors, unresolved plot threads, tone drift, point-of-view slips, deviations from story principles) with locations and severity, and saves the findings as a review report, without changing any other story content.

**Why this priority**: High value for long or multi-session stories, but only meaningful once a draft exists.

**Independent Test**: Seed a story with a deliberate contradiction (e.g., a character's eye color differs between two scenes). Run the review and verify it is reported with both locations and that only the review report file was written.

**Acceptance Scenarios**:

1. **Given** drafted scenes containing a contradiction, **When** the review runs, **Then** it reports the contradiction with references to both places.
2. **Given** a plot thread opened in the blueprint but never resolved in the scene list or draft, **When** the review runs, **Then** it flags the unresolved thread.
3. **Given** any story state, **When** the review runs, **Then** only the review report is written or replaced, and no other story files are modified.

---

### User Story 7 - Define story principles once and reuse them (Priority: P7)

The writer records standing creative rules for a story or for all their stories: voice and style, point-of-view conventions, tone boundaries, themes to explore or avoid, content limits, naming conventions. Every later stage consults these principles.

**Why this priority**: Improves consistency and reduces repeated instructions, but a story can be written with sensible defaults without it.

**Independent Test**: Set a principle such as "no first-person narration" and generate a blueprint and a drafted scene. Verify both respect it.

**Acceptance Scenarios**:

1. **Given** recorded principles, **When** any later stage runs, **Then** its output follows them.
2. **Given** a project-wide rule and a conflicting rule for one story, **When** a stage runs for that story, **Then** the story's rule is followed, and other stories still follow the project-wide rule.
3. **Given** a stage output that would violate a principle, **When** the stage runs, **Then** the violation is avoided or flagged to the writer.

---

### Edge Cases

- Writer provides a very long or very detailed premise (e.g., several pages): the brief must preserve their stated details rather than summarizing them away.
- Writer runs a later stage before earlier ones (e.g., scene list with no blueprint): the assistant explains which prior stage is missing and offers to run it.
- Writer edits artifacts by hand between stages: later stages must read the edited versions and not overwrite manual changes without confirmation.
- Writer manages multiple stories in one project: each story is isolated and the writer can tell which one is active.
- Writer idea involves sensitive or mature themes: the story principles determine content limits, and the assistant follows them rather than assuming defaults.
- Writer wants to change the premise after drafting has begun: the assistant identifies which downstream artifacts and drafted scenes are affected before applying changes.
- Writer's story is a form other than prose fiction (e.g., screenplay, serialized chapters): out of scope for v1; the assistant treats the request as prose fiction and says so.
- Requested story length is extreme (a single paragraph or a full-length novel): the workflow still functions, with plan depth scaled to the requested length.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a distinct command for each stage: principles, premise/brief, clarification, blueprint, scene list, drafting, and consistency review.
- **FR-002**: Each stage MUST save its output as a plain-text document that the writer can read, edit, and keep under their own version control.
- **FR-003**: Each stage MUST read the documents produced by earlier stages and keep its output consistent with them.
- **FR-004**: The premise stage MUST produce a brief covering premise, genre, tone, audience, target length, main characters, central conflict, and stakes.
- **FR-005**: The system MUST make reasonable creative assumptions for minor gaps, record them as assumptions, and raise at most 3 open questions for major creative choices.
- **FR-006**: The clarification stage MUST ask no more than 5 questions per run, prioritized by impact on the story, each with suggested answers and a free-form option, and MUST write answers back into the brief.
- **FR-007**: The blueprint stage MUST produce character profiles, setting and world rules, plot beats, and themes, scaled to the target length and honoring any structure the writer names.
- **FR-008**: The scene list stage MUST ensure every plot beat is covered by at least one scene and every scene maps to a beat, and MUST report any gaps.
- **FR-009**: The drafting stage MUST work on one scene at a time and let the writer choose per scene between a full assistant draft (default), a beat outline for the writer to write from, or feedback on the writer's own draft; full drafts MUST be consistent with prior drafted scenes, character profiles, and story principles and be placed in manuscript order.
- **FR-010**: The system MUST track scene status (not started, drafted, approved) and present it to the writer on request; a scene becomes approved only when the writer explicitly approves it, never by inference from the writer moving on.
- **FR-011**: The system MUST NOT overwrite writer-edited or approved content without explicit confirmation. A scene the writer has hand-edited but not approved is still protected.
- **FR-012**: The consistency review MUST NOT modify any story content; it MUST report contradictions, unresolved threads, point-of-view slips, and principle violations with locations and severity, saved as a review report file in the story folder that replaces the previous report.
- **FR-013**: The system MUST support recording story principles (voice, style, tone, themes, content limits) at two levels, project-wide defaults and optional per-story principles, and all other stages MUST honor them, with a per-story rule taking priority over a conflicting project-wide rule.
- **FR-014**: The system MUST detect and explain when a stage is run without its prerequisites, and offer to run the missing stage.
- **FR-015**: The system MUST support multiple independent stories in one project, with a clear indication of which is active.
- **FR-016**: Writers MUST be able to revise a single scene using feedback without altering other scenes.
- **FR-017**: When an upstream document changes after downstream work exists, the system MUST tell the writer which downstream documents and scenes may be affected, then offer to update the affected plan documents and propose revisions to affected scenes; no downstream change may be applied without the writer's confirmation.
- **FR-018**: The system MUST be usable by writers with no software or spec-driven development background, using plain creative language rather than technical terms.
- **FR-019**: The workflow MUST work for prose fiction of any length from flash fiction to novel, with planning depth scaled to the length.

### Key Entities

- **Story**: The unit of work; has a name, an active status, and owns all documents below.
- **Principles**: Standing creative rules (voice, tone, themes, content limits) recorded either project-wide (defaults for all stories) or for a single story; a story's own rules override conflicting project-wide ones.
- **Brief**: The premise-level description of the story, including open questions and recorded assumptions.
- **Blueprint**: Characters, setting and world rules, plot beats, and themes derived from the brief.
- **Character**: A person in the story with goals, flaws, relationships, voice, and an arc.
- **Plot Beat**: A major story turning point in the blueprint, linked to the characters and themes it involves.
- **Scene**: An ordered unit of the story with purpose, point-of-view character, setting, characters present, intended change, linked beat, and status.
- **Manuscript**: The accumulated drafted prose, ordered by scene.
- **Review Report**: The saved output of the most recent consistency review; a list of findings with locations and severity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A writer can go from a one-sentence idea to a complete story brief in under 5 minutes of their own time.
- **SC-002**: A writer can go from a brief to a full scene list in under 20 minutes of their own time for a short story.
- **SC-003**: At least 90% of plot beats in a generated blueprint are covered by scenes in the generated scene list on first generation.
- **SC-004**: In a seeded test containing 5 deliberate contradictions, the consistency review identifies at least 4 of them with correct locations.
- **SC-005**: 90% of first-time writers complete the idea-to-brief stage without needing outside help or instructions beyond the command descriptions.
- **SC-006**: In testing across at least 10 sessions, no approved or hand-edited content is overwritten without explicit writer confirmation.
- **SC-007**: A writer who stops mid-project and returns in a new session can resume at the correct stage without re-explaining the story, in 100% of tested cases.
- **SC-008**: Drafted scenes follow the recorded story principles (e.g., point of view, tone limits) in at least 90% of reviewed scenes.

## Assumptions

- Primary users are individual writers (hobbyist to professional) of prose fiction; collaborative multi-author workflows are out of scope for v1.
- Story forms other than prose fiction (screenplays, comics, interactive fiction) are out of scope for v1.
- The writer retains creative control: the assistant proposes and drafts, the writer approves, edits, or rejects.
- The workflow mirrors Spec Kit's command-per-stage model and is delivered as an AI assistant skill used inside the writer's existing project folder.
- Story documents are stored as plain text files in the project, so the writer can edit them with any editor and track them with their own version control.
- Content limits default to general-audience conventions unless the writer's principles state otherwise.
- The assistant operates in the writer's chosen language; the default is English.
- Story length targets default to short story (roughly 1,500 to 7,500 words) if the writer does not specify one.
