---

description: "Task list for the Story Writing Skill (Story Kit)"
---

# Tasks: Story Writing Skill ("Story Kit")

**Input**: Design documents from `/specs/001-story-writing-skill/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: The plan's testing strategy (research R9) calls for deterministic Bash tests of the helper scripts and structural checks of assistant output, so test tasks are included. Prompt behavior itself is validated by the scripted scenarios in quickstart.md (T047).

**Organization**: Tasks are grouped by user story so each story can be built and tested independently. Each story's "skill" is a `SKILL.md` file under `.claude/skills/`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story the task belongs to (US1 to US7)
- Every task names the exact file path

## Path Conventions

Skill pack layout from plan.md: skills in `.claude/skills/storykit-*/SKILL.md`; templates in `.storykit/templates/`; scripts in `.storykit/scripts/bash/`; tests in `tests/helpers/`; fixtures in `tests/fixtures/`; writer content in `stories/<slug>/`.

**Conventions for every skill file** (copy the frontmatter shape of `.claude/skills/speckit-specify/SKILL.md`: `name`, `description`, `argument-hint`, `user-invocable: true`):
- Resolve the story and check prerequisites with `bash .storykit/scripts/bash/check-prerequisites.sh --json`.
- Read and follow `.storykit/conventions.md` (T014).
- Use creative language only; never use Spec Kit terms (specify, plan, tasks, implement, analyze, constitution) in user-facing text (FR-018).
- Write only the files listed for that command in `contracts/commands.md`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Directory skeleton and test harness

- [x] T001 Create the directory skeleton from plan.md: `.storykit/templates/`, `.storykit/scripts/bash/`, `.storykit/memory/`, `tests/helpers/`, `tests/fixtures/`, `stories/` (with a `stories/.gitkeep`)
- [x] T002 [P] Create the Bash test harness in `tests/helpers/assert.sh` (functions `assert_eq`, `assert_contains`, `assert_file_exists`, `assert_exit_nonzero`, each printing PASS/FAIL and counting failures) and `tests/helpers/run-all.sh` (runs every `tests/helpers/test-*.sh`, exits non-zero if any fail). Bash 3.2 compatible, no associative arrays, no `mapfile`
- [x] T003 [P] Create an initial `README.md` at the repository root describing Story Kit in one paragraph and listing the planned command names from `specs/001-story-writing-skill/contracts/commands.md` (final version in T048)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared scripts, rules, and fixtures that every story depends on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Implement `.storykit/scripts/bash/common.sh` (sourced, `#!/usr/bin/env bash`, Bash 3.2): functions `repo_root`, `slugify` (lowercase, non-alphanumerics to hyphens, collapse repeats, trim, max 40 chars), `resolve_story` (explicit argument → contents of `.storykit/active-story` → the only story in `stories/` if exactly one → otherwise fail with a message listing the slugs), `today` (YYYY-MM-DD), `json_escape`
- [x] T005 [P] Write `tests/helpers/test-common.sh` covering slug rules (including 40-character cap and repeated punctuation), and all four `resolve_story` branches, using a temporary directory
- [x] T006 Implement `.storykit/scripts/bash/check-prerequisites.sh` per `contracts/helper-scripts.md`: `--json [--story <slug>] [--require brief,blueprint,scenes,manuscript]`, output `{"STORY_DIR","SLUG","HAS":{...},"MISSING":[...],"STALE":[...]}`; exit non-zero when a required artifact is missing; compute STALE by comparing each downstream file's `Built from: <artifact> YYYY-MM-DD` line to the upstream file's `Last updated:` date (research R7), for all three links: blueprint ← brief, scenes ← blueprint, manuscript ← scenes (the manuscript carries a `**Built from**: scenes YYYY-MM-DD` header line); STALE entries are strings like `blueprint (brief changed 2026-11-14)`. Depends on T004
- [x] T007 [P] Write `tests/helpers/test-check-prerequisites.sh` covering: all artifacts present, brief only, missing required artifact (non-zero exit, correct MISSING list), stale blueprint after the brief's date changes, explicit `--story` override
- [x] T008 Implement `.storykit/scripts/bash/use-story.sh <slug>`: sets `.storykit/active-story`, prints `{"SLUG":"..."}`, fails with a clear message if `stories/<slug>/` does not exist. Depends on T004
- [x] T009 [P] Write `tests/helpers/test-use-story.sh` covering success, unknown slug, and that the active-story file contains exactly the slug and a newline
- [x] T010 Implement `.storykit/scripts/bash/scene-status.sh` with subcommands `list` (one `ID<TAB>STATUS<TAB>TITLE` per line), `get <id>`, and `set <id> <status>` per `contracts/artifact-formats.md`. Heading regex: `^## (S[0-9]+) \[(not-started|drafted|approved)\] (.+)$`. Valid statuses are exactly `not-started`, `drafted`, `approved`; any other value exits non-zero. `set` rewrites only that scene's heading line. Depends on T004
- [x] T011 [P] Write `tests/helpers/test-scene-status.sh` covering list, get, set, invalid status rejected, unknown scene id rejected, and that all other lines of `scenes.md` are byte-identical after `set`
- [x] T012 [P] Implement `.storykit/scripts/bash/scene-hash.sh` with subcommands `extract <id>` (prints text between a scene's start and end markers), `hash <id>` (hash of that text), `record <id>` (writes or replaces the `sha` marker line for the scene), and `check <id>` (prints `assistant-written` when the current hash equals the recorded `sha`, `hand-edited` when a `sha` exists but differs, `unrecorded` when the scene has a marker block but no `sha` line (for example text the writer pasted in), or `missing` when the scene has no marker block; `unrecorded` MUST be treated by callers exactly like `hand-edited`). Uses `shasum` (macOS) with `sha256sum` fallback. Never modifies text outside the `sha` line. Depends on T004
- [x] T013 [P] Write `tests/helpers/test-scene-hash.sh` covering extract, hash stability, record then check yields `assistant-written`, editing one character yields `hand-edited`, a marker block with no `sha` line yields `unrecorded`, a scene with no marker block yields `missing`, and text outside the scene is byte-identical after `record`
- [x] T014 [P] Write `.storykit/conventions.md`, the shared rules every skill reads: (a) principles precedence per research R8, reading `.storykit/memory/principles.md` then `stories/<slug>/principles.md` and applying the merged result, defaulting to general-audience conventions when none exist; (b) never overwrite approved or hand-edited content without explicit confirmation (FR-011); (c) approval is only ever explicit (FR-010); (d) prerequisite-missing behavior: name the missing stage, offer to run it, change nothing (FR-014); (e) stale-artifact reporting and confirmation-before-change rule (FR-017); (f) creative-language-only rule (FR-018); (g) at most 3 open questions in a brief and at most 5 clarification questions per run; (h) the stale-artifact procedure used by every skill: run `check-prerequisites.sh --json`, list STALE entries in plain language, offer updates, and apply none without explicit confirmation; (i) a one-line glossary: brief = the premise-level document, scene list = `scenes.md`
- [x] T015 [P] Create fixture `tests/fixtures/minimal-story/brief.md` for the premise "a retired lighthouse keeper discovers the light has been signaling someone", using the headings in `contracts/artifact-formats.md` (brief.md) and 2 open questions
- [x] T016 Create fixture `tests/fixtures/full-story/` with a fully consistent story (`brief.md`, `blueprint.md`, `scenes.md` with 6 scenes across statuses `not-started`, `drafted`, `approved`, `manuscript.md` with a `**Built from**: scenes YYYY-MM-DD` header, marker blocks, and `sha` lines generated by running `scene-hash.sh record` (T012) rather than computed by hand, `principles.md` forbidding first person) following `contracts/artifact-formats.md` exactly. Every beat is covered by a scene. Depends on T012

**Checkpoint**: Foundation ready. Run `bash tests/helpers/run-all.sh`, and user story work can begin.

---

## Phase 3: User Story 1 - Turn a rough idea into a story brief (Priority: P1) 🎯 MVP

**Goal**: A one-sentence idea becomes a complete, editable brief with at most 3 open questions, and the story becomes the active story.

**Independent Test**: Run `/storykit-premise a retired lighthouse keeper discovers the light has been signaling someone`; verify `stories/<slug>/brief.md` has every required heading, at most 3 open questions, and `.storykit/active-story` holds the slug. Run with an empty idea and verify nothing is created.

### Implementation for User Story 1

- [x] T017 [P] [US1] Implement `.storykit/scripts/bash/new-story.sh --json "<slug>" ["<title>"]`: creates `stories/<slug>/`, copies `.storykit/templates/brief-template.md` to `brief.md`, sets the active story, prints `{"STORY_DIR","SLUG","BRIEF"}`; if the slug exists, exits non-zero suggesting `<slug>-2`, `<slug>-3`
- [x] T018 [P] [US1] Write `tests/helpers/test-new-story.sh` covering creation, active-story update, duplicate slug refusal with suffix suggestion, and JSON fields
- [x] T019 [P] [US1] Create `.storykit/templates/brief-template.md` with exactly the headings in `contracts/artifact-formats.md` (brief.md): Premise, Genre and Tone, Audience, Target Length, Main Characters, Central Conflict, Stakes, Assumptions, Open Questions, Clarifications; plus the `**Slug**` and `**Last updated**` header line
- [x] T020 [US1] Write `.claude/skills/storykit-premise/SKILL.md` per `contracts/commands.md` (/storykit-premise): require a non-empty idea (else say an idea is required and create nothing); derive a 2-4 word slug; call `new-story.sh`; fill the brief preserving every detail the writer stated; apply the target-length default (short story, roughly 1,500 to 7,500 words); record minor gaps under Assumptions; list at most 3 open questions, only for major creative choices (such as tragic versus hopeful ending); if the writer asks for a non-prose form such as a screenplay, comic, or interactive fiction, say plainly that v1 treats it as prose fiction and continue. Depends on T017, T019, T014
- [x] T021 [P] [US1] Write `tests/helpers/check-brief.sh <brief.md>`: fails unless all required headings exist, Open Questions has at most 3 `- [ ]` items, and `Last updated` is a valid date; run it against `tests/fixtures/minimal-story/brief.md`

**Checkpoint**: User Story 1 works on its own. This is the MVP.

---

## Phase 4: User Story 2 - Resolve open questions before planning (Priority: P2)

**Goal**: Up to 5 targeted questions, each with a recommendation and a free-form option, with answers written back into the brief.

**Independent Test**: Run `/storykit-clarify` on a brief with known gaps; verify at most 5 questions were asked one at a time, the brief gains one Clarifications entry per answer, and resolved open questions are removed. On a brief with no gaps, verify "nothing needs clarifying" and an unchanged file.

### Implementation for User Story 2

- [x] T022 [P] [US2] Create fixture `tests/fixtures/brief-with-gaps/brief.md`: a brief with 3 open questions (point of view, ending tone, stakes) and a deliberately conflicting tone line, plus `tests/fixtures/brief-complete/brief.md` with none
- [x] T023 [US2] Write `.claude/skills/storykit-clarify/SKILL.md` per `contracts/commands.md` (/storykit-clarify): prerequisite brief; scan for gaps and contradictions (point of view, tone conflicts, undefined stakes, unclear ending); ask at most 5 questions, exactly one at a time, each with a recommended answer and reasoning, 2 to 4 lettered options, and a free-form option; accept "yes"/"recommended"; after each answer append `- Q: <question> → A: <answer>` under `## Clarifications` / `### Session YYYY-MM-DD` and update the affected brief section and remove the resolved open question; if nothing needs clarifying, say so and write nothing. Depends on T014
- [x] T024 [P] [US2] Write `tests/helpers/check-clarifications.sh <before.md> <after.md>`: fails if more than 5 new Clarifications entries were added, if any resolved open-question line remains, or if `after.md` has more open questions than `before.md`

**Checkpoint**: User Stories 1 and 2 both work independently.

---

## Phase 5: User Story 3 - Build a story blueprint (Priority: P3)

**Goal**: A blueprint with characters, setting and world rules, plot beats scaled to the target length, and themes, all traceable to the brief.

**Independent Test**: With `tests/fixtures/minimal-story/brief.md` copied into a story folder, run `/storykit-blueprint`; verify characters, setting, beats, and themes exist, the beat count suits the target length, and each beat links to a premise element or character goal. Re-run naming a structure ("hero's journey") and verify it is followed.

### Implementation for User Story 3

- [x] T025 [P] [US3] Create `.storykit/templates/blueprint-template.md` with the headings and `Built from` / `Last updated` header in `contracts/artifact-formats.md` (blueprint.md): Structure, Characters (`### C1 Name` with Role, Goal, Flaw, Relationships, Voice, Arc), Setting and World Rules, Plot Beats (`### B1 Name` with Summary, Characters, Themes), Themes
- [x] T026 [US3] Write `.claude/skills/storykit-blueprint/SKILL.md` per `contracts/commands.md` (/storykit-blueprint): prerequisite brief (warn but do not block on open questions); honor a named structure, else choose and state one; scale beat count to target length (flash 3-4, short story 5-8, novella 10-15, novel 15+); every brief character must appear; every beat traces to a premise element or character goal; apply merged principles; set `Built from: brief <date>`; if `blueprint.md` exists, ask before replacing. First run `check-prerequisites.sh --json`; if STALE lists an upstream artifact of this stage, tell the writer what changed upstream and offer to update this stage's output, applying nothing without explicit confirmation (FR-017, conventions.md). Depends on T025, T014
- [x] T027 [P] [US3] Write `tests/helpers/check-blueprint.sh <story-dir>`: fails unless required headings exist, character names are unique, every name under the brief's Main Characters appears in the blueprint, beat ids are sequential from B1, and `Built from: brief` is present

**Checkpoint**: User Stories 1 to 3 work independently.

---

## Phase 6: User Story 4 - Break the blueprint into a scene list (Priority: P4)

**Goal**: An ordered scene list where every beat is covered and every scene maps to a beat, with all scenes `not-started`.

**Independent Test**: With `tests/fixtures/full-story/blueprint.md`, run `/storykit-scenes`; verify every beat has at least one scene, every scene has purpose, POV, setting, characters, change, and a beat link. Remove a scene, re-run, and verify the uncovered beat is flagged and existing statuses are preserved.

### Implementation for User Story 4

- [x] T028 [P] [US4] Create `.storykit/templates/scenes-template.md` per `contracts/artifact-formats.md` (scenes.md): header with `Built from: blueprint` and `Last updated`, and a scene block `## S01 [not-started] Scene title` with Purpose, POV, Setting, Characters, Change, Beats
- [x] T029 [US4] Write `.claude/skills/storykit-scenes/SKILL.md` per `contracts/commands.md` (/storykit-scenes): prerequisite blueprint; ordered scenes with ids `S01`, `S02`, ...; ids are never reused and gaps are allowed; all new scenes `not-started`; report uncovered beats and orphan scenes; on re-run preserve existing ids, statuses and hand edits, and flag newly uncovered beats rather than silently adding scenes; scene count scaled to target length. First run `check-prerequisites.sh --json`; if STALE lists an upstream artifact of this stage, tell the writer what changed upstream and offer to update this stage's output, applying nothing without explicit confirmation (FR-017, conventions.md). Depends on T028, T010, T014
- [x] T030 [P] [US4] Write `tests/helpers/check-scenes.sh <story-dir>`: fails if any beat id in `blueprint.md` is referenced by no scene, if any scene references an unknown beat, if any status is invalid, or if scene ids are duplicated. Run it against `tests/fixtures/full-story`

**Checkpoint**: User Stories 1 to 4 work independently.

---

## Phase 7: User Story 5 - Draft scenes with guidance and continuity (Priority: P5)

**Goal**: Per-scene drafting in three writer-chosen modes with protection of approved and hand-edited prose.

**Independent Test**: With `tests/fixtures/full-story`, run `/storykit-draft` (full mode, next not-started scene), `/storykit-draft S0X --mode outline`, and `/storykit-draft S0Y --mode feedback`; verify prose lands only inside that scene's markers, outline mode writes beats and no prose, feedback mode leaves the writer's text untouched, and redrafting an approved scene asks for confirmation.

### Implementation for User Story 5

- [x] T031 [P] [US5] Create `.storykit/templates/manuscript-template.md` with the title line, a `**Built from**: scenes YYYY-MM-DD` header line, and a commented example of the marker block `<!-- scene:S01 start -->`, prose, `<!-- scene:S01 end -->`, `<!-- scene:S01 sha:<hash> -->` per research R5
- [x] T032 [P] [US5] Create `.storykit/templates/scene-outline-template.md`: heading `# S03 Beat Outline` and a numbered list of beats, with a note that outlines contain no prose paragraphs
- [x] T033 [US5] Write `.claude/skills/storykit-draft/SKILL.md` per `contracts/commands.md` (/storykit-draft): choose the named scene, else the first `not-started`; modes `full` (default), `outline` (beats only, saved to `outlines/<id>.md`, status unchanged), `feedback` (critique the writer's own text against purpose, POV, and principles without rewriting it; changes no status unless the writer asks for the scene to be marked `drafted`); full mode writes prose consistent with prior drafted scenes, character profiles and merged principles, inside that scene's markers in scene-list order, then runs `scene-hash.sh record` and `scene-status.sh set <id> drafted`; "approve <id>" is the only way to set `approved`; before replacing a scene that is `approved` or reported `hand-edited` or `unrecorded` by `scene-hash.sh check`, ask for explicit confirmation; revision requests change only that scene's block. First run `check-prerequisites.sh --json`; if STALE lists an upstream artifact of this stage, tell the writer what changed upstream and offer to update this stage's output, applying nothing without explicit confirmation (FR-017, conventions.md). Depends on T031, T032, T012, T010, T014
- [x] T034 [P] [US5] Write `tests/helpers/check-manuscript.sh <story-dir>`: fails if start/end markers are unbalanced, if scene order differs from `scenes.md`, if any `drafted` or `approved` scene has no marker block, or if any `outlines/*.md` contains a paragraph of more than 40 words (prose leak)

**Checkpoint**: User Stories 1 to 5 work independently.

---

## Phase 8: User Story 6 - Check the story for consistency (Priority: P6)

**Goal**: A review that reports contradictions and gaps with locations and severity, writing only `review.md`.

**Independent Test**: Run `/storykit-review` in `tests/fixtures/seeded-contradictions`; verify at least 4 of the 5 seeded issues are reported with both locations, and that no file other than `review.md` changed.

### Implementation for User Story 6

- [x] T035 [P] [US6] Create `.storykit/templates/review-template.md` per `contracts/artifact-formats.md` (review.md): title, `Generated` date, Summary with counts by severity, and the findings table `| ID | Severity | Type | Locations | Description |`
- [x] T036 [P] [US6] Create fixture `tests/fixtures/seeded-contradictions/` (copy `tests/fixtures/full-story/` first, then alter) containing exactly 5 deliberate issues: a character's eye colour that differs between two scenes, a timeline error, a plot thread opened in the blueprint and never resolved, a first-person slip that violates the story's principles, and a scene whose POV differs from its scene-list entry. Add `tests/fixtures/seeded-contradictions/answer-key.md` listing each issue with its two locations
- [x] T037 [US6] Write `.claude/skills/storykit-review/SKILL.md` per `contracts/commands.md` (/storykit-review): prerequisite brief, richer with blueprint, scenes, manuscript; check contradiction, timeline, unresolved-thread, tone-drift, pov-slip, principle-violation, coverage-gap, stale-artifact (types from `contracts/artifact-formats.md`); each finding has severity high, medium, or low and file plus heading or scene-id locations; write only `stories/<slug>/review.md`, replacing the previous report; never edit any other file. First run `check-prerequisites.sh --json`; if STALE lists an upstream artifact of this stage, tell the writer what changed upstream and offer to update this stage's output, applying nothing without explicit confirmation (FR-017, conventions.md). Depends on T035, T014
- [x] T038 [P] [US6] Write `tests/helpers/score-review.sh <story-dir> <answer-key.md>`: counts how many seeded issues appear in `review.md` (matching both locations) and prints recall; also takes a checksum snapshot of all other story files before and after and fails if any changed. Target: recall of at least 4 of 5 (SC-004)

**Checkpoint**: User Stories 1 to 6 work independently.

---

## Phase 9: User Story 7 - Define story principles once and reuse them (Priority: P7)

**Goal**: Project-wide defaults plus per-story overrides, merged deterministically and honored by every stage.

**Independent Test**: Run `/storykit-principles no first-person narration`, then `/storykit-blueprint` and `/storykit-draft`; verify neither output uses first person. Add a conflicting story-level rule and verify it wins for that story only.

### Implementation for User Story 7

- [x] T039 [P] [US7] Create `.storykit/templates/principles-template.md` with the headings Voice, Point of View, Tone, Themes, Content Limits, Naming and the `Last updated` line per `contracts/artifact-formats.md`
- [x] T040 [P] [US7] Implement `.storykit/scripts/bash/principles.sh merge [--story <slug>]`: prints the merged principles, where a heading present in `stories/<slug>/principles.md` replaces the same heading from `.storykit/memory/principles.md` (research R8) and headings present in only one file are kept; prints nothing and exits 0 when neither file exists. Depends on T004
- [x] T041 [P] [US7] Write `tests/helpers/test-principles.sh` covering project only, story only, both with a conflicting heading (story wins), both with different headings (union), and neither file present
- [x] T042 [US7] Write `.claude/skills/storykit-principles/SKILL.md` per `contracts/commands.md` (/storykit-principles): free-text input is mapped onto the six headings; without `--story` write `.storykit/memory/principles.md`, with it write `stories/<slug>/principles.md`; preserve headings the writer did not mention; show the merged result via `principles.sh merge`; the other skills' principle-reading rule is already defined in `.storykit/conventions.md` (T014). Depends on T039, T040

**Checkpoint**: All seven user stories work independently.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Status command, documentation sync, and end-to-end validation

- [x] T043 Write `.claude/skills/storykit-status/SKILL.md` per `contracts/commands.md` (/storykit-status): show the active story, which stages exist, stale artifacts from `check-prerequisites.sh`, scene counts by status from `scene-status.sh list`, and the suggested next command; with a story name argument, switch via `use-story.sh`; allow the writer to resume in a new session without re-explaining (SC-007) and make multi-story use clear (FR-015). Depends on T006, T008, T010
- [x] T044 [P] Write `tests/helpers/check-terminology.sh`: greps all `.claude/skills/storykit-*/SKILL.md` and `.storykit/templates/*.md` for the Spec Kit terms `specify`, `constitution`, `speckit`, `analyze`, and `tasks.md`, ignoring `.specify/` and `specs/`; fails if any are found in user-facing text (FR-018)
- [x] T045 Sync the design documents with additions made during task planning: add `scene-hash.sh` and `principles.sh` to the Source Code tree in `specs/001-story-writing-skill/plan.md` (changing "5 helper scripts" to 7 and the script count line accordingly) and to the table in `specs/001-story-writing-skill/contracts/helper-scripts.md` (applied during analysis remediation)
- [x] T046 Run `bash tests/helpers/run-all.sh` and fix any failures in the scripts or tests
- [ ] T047 Run all eight scenarios in `specs/001-story-writing-skill/quickstart.md` against the fixtures and record pass/fail, review recall from `score-review.sh`, and any deviations in `specs/001-story-writing-skill/validation-notes.md`. Then follow quickstart.md section 9 (success-criteria measurement protocol) and record in the same file, for each of SC-001 to SC-008, one of: measured (with the number), checked by hand, or needs real writers (SC-005 always; SC-001 and SC-002 when timed by someone other than the author)
- [x] T048 [P] Finalize `README.md`: install steps (copy `.claude/skills/storykit-*`, `.storykit/`), the 8 commands in recommended order, folder layout, how to hand-edit files safely, and the note that scripts must be run with `bash`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup; blocks all user stories
- **User Stories (Phases 3 to 9)**: Depend on Foundational only. They share no files, so they can run in parallel or in priority order P1 → P7
- **Polish (Phase 10)**: Depends on all desired stories; T043 needs T006, T008, T010; T046 and T047 run last

### Within Foundational

- T004 first; then T006, T008, T010 (each depends on T004); tests T005, T007, T009, T011, T013 follow their scripts; T012 depends on T004 and must precede T016; T014 and T015 are independent

### User Story Dependencies

- **US1 (P1)**: independent
- **US2 (P2)**: needs a brief only (fixture T015 or T022 supplies one)
- **US3 (P3)**: needs a brief (fixture)
- **US4 (P4)**: needs a blueprint (fixture T016)
- **US5 (P5)**: needs a scene list and uses `scene-status.sh` and `scene-hash.sh` from Phase 2 (fixture T016)
- **US6 (P6)**: needs fixtures T016 and T036
- **US7 (P7)**: independent; every other skill already reads principles through T014 and degrades to defaults

### Parallel Opportunities

- Setup: T002 and T003 together
- Foundational: after T004, run T006, T008, T010 together, then T012, T005, T007, T009, T011, T013, T014, T015 together, then T016 (needs T012)
- Per story, tasks marked [P] touch different files and can run together, for example in US5: T031, T032, T034 in parallel, then T033

### Parallel Example: User Story 5

```text
Task: "Create .storykit/templates/manuscript-template.md"            (T031)
Task: "Create .storykit/templates/scene-outline-template.md"         (T032)
# then:
Task: "Write .claude/skills/storykit-draft/SKILL.md"                 (T033)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup (T001 to T003)
2. Phase 2: Foundational (T004 to T016)
3. Phase 3: User Story 1 (T017 to T021)
4. **Stop and validate**: run quickstart scenario 1; a writer can already turn an idea into a brief
5. Demo or share

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. US1 → idea to brief (MVP)
3. US2 → clarified brief
4. US3 and US4 → blueprint and scene list (a full plan the writer can write from)
5. US5 → guided drafting
6. US6 and US7 → review and standing principles
7. Polish → status command, docs, end-to-end validation

---

## Notes

- [P] tasks touch different files and have no unfinished dependencies
- [Story] labels map each task to its user story for traceability
- Skills are prompt files, so "done" for a skill task means the file exists, follows the command contract, and passes the matching structural check where one exists; behavior is confirmed in T047
- Run scripts as `bash <script>`, never `sh` (research R10)
- Commit after each task or logical group, if the project is under version control
