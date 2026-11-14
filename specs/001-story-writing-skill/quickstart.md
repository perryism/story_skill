# Quickstart: Validating Story Kit

Run these in order from the repository root once the skills and helpers are implemented. Fixtures are in `tests/fixtures/`.

## 0. Script tests
```bash
bash tests/helpers/run-all.sh
```
Expected: all assertions pass (slugging, active-story resolution, prerequisite JSON, scene-status get/set, refusal on invalid status). Covers [helper-scripts.md](contracts/helper-scripts.md).

## 1. Premise → brief (US1, SC-001)
```text
/storykit-premise a retired lighthouse keeper discovers the light has been signaling someone
```
Expected: `stories/<slug>/brief.md` has every heading in [artifact-formats.md](contracts/artifact-formats.md), ≤ 3 open questions, and `.storykit/active-story` holds the slug. Re-run with an empty idea: nothing is created.

## 2. Clarify (US2)
```text
/storykit-clarify
```
Expected: at most 5 questions, one at a time, each with a recommendation and a free-form option; the brief gains a Clarifications entry per answer; resolved open questions disappear. On a fully specified brief: "nothing needs clarifying", file unchanged.

## 3. Principles (US7)
```text
/storykit-principles no first-person narration
```
Then run blueprint and draft. Expected: neither output uses first person. Add a conflicting story-level rule and confirm it wins for that story only.

## 4. Blueprint and scenes (US3, US4, SC-002, SC-003)
```text
/storykit-blueprint
/storykit-scenes
```
Expected: blueprint has characters, setting, beats, themes; beat count suits the target length. Scene list covers ≥ 90% of beats on first generation, every scene has a beat, all `not-started`.

## 5. Draft in all three modes (US5)
```text
/storykit-draft
/storykit-draft S02 --mode outline
/storykit-draft S03 --mode feedback        # after pasting your own text into S03's markers
approve S01
/storykit-draft S01                        # must ask for confirmation
```
Expected: S01 drafted then approved only on explicit request; outline mode writes `outlines/S02.md` with no prose; feedback mode leaves your text untouched; redrafting an approved scene asks first; other scenes' text unchanged after a single-scene revision.

Pasted text in S03 has no recorded hash, so it must be treated as hand-edited: asking to redraft S03 must ask for confirmation first.

## 6. Review (US6, SC-004)
```text
/storykit-review        # in tests/fixtures/seeded-contradictions
```
Expected: `review.md` reports ≥ 4 of the 5 seeded issues with both locations. Compare file listings before and after: only `review.md` changed.

## 7. Resume and change propagation (SC-007, FR-017)
Start a new session, run `/storykit-status` (correct stage and scene counts, no re-explaining). Edit the brief's premise, run `/storykit-status` again: blueprint and scenes are reported stale, and an update is offered but not applied without confirmation.

## 8. Multiple stories (FR-015)
Create a second story with `/storykit-premise`, then `/storykit-status <first-slug>`. Expected: active story switches; commands act on the right story.

## 9. Success-criteria measurement protocol (SC-001 to SC-008)

| SC | How to measure | Who |
|----|----------------|-----|
| SC-001 | Stopwatch from typing the premise command to a reviewed brief; repeat 3 times with different ideas; all under 5 minutes of writer time | Author, then 1 outside writer |
| SC-002 | Same, from brief to scene list for a short story; under 20 minutes | Author, then 1 outside writer |
| SC-003 | Run `bash tests/helpers/check-scenes.sh` on 5 freshly generated stories; at least 90% of beats covered on first generation | Automated |
| SC-004 | `bash tests/helpers/score-review.sh` on the seeded fixture; at least 4 of 5 found | Automated |
| SC-005 | 10 first-time writers attempt idea to brief with only command descriptions; 9 succeed unaided | Real writers (cannot be closed by the build) |
| SC-006 | 10 sessions mixing approve, hand-edit, paste, redraft; checksum approved and edited scenes before and after; zero silent changes | Author |
| SC-007 | Close the session after each stage, reopen, run `/storykit-status`; resumes correctly 100% of the time over 5 stage boundaries | Author |
| SC-008 | Review 10 drafted scenes against the story's principles; at least 9 conform | Author |

Record every result in `specs/001-story-writing-skill/validation-notes.md`.
