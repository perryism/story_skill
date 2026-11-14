# Validation Notes

Date: 2026-11-13. Run by the implementing assistant. Scope: everything that can be verified without a writer driving the slash commands.

## Automated (T046)

`bash tests/helpers/run-all.sh`: 9 test files, 114 assertions, all passing (scripts: common, check-prerequisites, use-story, scene-status, scene-hash, new-story, principles; structural checks and fixtures: brief, blueprint, scenes, manuscript, clarifications, score-review, terminology).

## Quickstart scenarios

| # | Scenario | Result |
|---|----------|--------|
| 0 | Script tests | PASS |
| 1 | Premise → brief | PARTIAL. Script path verified: `new-story.sh` creates the brief from the template, sets the active story, `check-brief.sh` passes. The skill's prose generation (brief content, ≤ 3 open questions, empty-idea refusal) has not been exercised through `/storykit-premise` |
| 2 | Clarify | NOT RUN through the skill. `check-clarifications.sh` verified against fixtures |
| 3 | Principles | Merge logic PASS (project only, story only, conflict, union, none). Whether generated output obeys a rule is NOT RUN |
| 4 | Blueprint and scenes | NOT RUN through the skills. `check-blueprint.sh` and `check-scenes.sh` PASS on `full-story`, and fail correctly on seeded defects |
| 5 | Draft modes | Protection logic PASS (`scene-hash.sh`: assistant-written, hand-edited, unrecorded, missing; `scene-status.sh`). The three drafting modes through `/storykit-draft` NOT RUN |
| 6 | Review | Scoring PASS (`score-review.sh` counts 4 of 5 on a sample report, detects modified files). Actual review recall of `/storykit-review` on `seeded-contradictions` NOT MEASURED |
| 7 | Resume and change propagation | Stale detection PASS in `check-prerequisites.sh` (brief edited → blueprint reported stale). The `/storykit-status` skill and confirm-before-change behaviour NOT RUN |
| 8 | Multiple stories | PASS at script level: two stories, ambiguity reported, `use-story.sh` switches. Skill behaviour NOT RUN |

## Success criteria (SC)

| SC | Status |
|----|--------|
| SC-001, SC-002 | Not measured. Needs timing through the live commands |
| SC-003 | Checker ready (`check-scenes.sh`); not yet measured on freshly generated stories |
| SC-004 | Scorer and fixture ready; recall of `/storykit-review` not yet measured |
| SC-005 | Needs real first-time writers; cannot be closed by the build |
| SC-006 | Protection primitives verified by tests; 10-session run not done |
| SC-007 | Not measured. Stale/status primitives work |
| SC-008 | Not measured. Needs reading drafted scenes against principles |

## Known deviations

- T047 is deliberately left unchecked: the skill-driven scenarios above need a person (or a live session) to run the slash commands.
- `check-terminology.sh` checks Spec Kit command and file names (`speckit`, `constitution`, `.specify`, `/specify`, `tasks.md`, `spec.md`) rather than plain words like "analyze", to avoid false positives (analysis item A1).
