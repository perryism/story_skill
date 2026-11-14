# Artifact Formats

Required headings and markers. Skills and scripts depend on these exact strings; the writer may add any other content.

## brief.md
```markdown
# <Title> — Story Brief
**Slug**: <slug>   **Last updated**: YYYY-MM-DD
## Premise
## Genre and Tone
## Audience
## Target Length        (words and category; default short story)
## Main Characters      (name — one line)
## Central Conflict
## Stakes
## Assumptions
## Open Questions       (0-3 items, each prefixed "- [ ]")
## Clarifications       (### Session YYYY-MM-DD, "- Q: ... → A: ...")
```

## principles.md (project and story)
```markdown
# Story Principles
**Last updated**: YYYY-MM-DD
## Voice
## Point of View
## Tone
## Themes
## Content Limits
## Naming
```
Any heading may be omitted. A story-level heading replaces the project-level heading of the same name.

## blueprint.md
```markdown
# <Title> — Blueprint
**Built from**: brief YYYY-MM-DD   **Last updated**: YYYY-MM-DD
## Structure
## Characters           (### C1 Name; Role, Goal, Flaw, Relationships, Voice, Arc)
## Setting and World Rules
## Plot Beats           (### B1 Name; Summary, Characters, Themes)
## Themes
```

## scenes.md
```markdown
# <Title> — Scenes
**Built from**: blueprint YYYY-MM-DD   **Last updated**: YYYY-MM-DD
## S01 [not-started] Scene title
- Purpose:
- POV:
- Setting:
- Characters:
- Change:
- Beats: B1[, B2]
```
Heading regex: `^## (S[0-9]+) \[(not-started|drafted|approved)\] (.+)$`.

## manuscript.md
```markdown
# <Title>
**Built from**: scenes YYYY-MM-DD
<!-- scene:S01 start -->
...prose...
<!-- scene:S01 end -->
<!-- scene:S01 sha:<hash of text between start and end as last written by the assistant> -->
```
Scenes appear in scene-list order. A scene whose current text hash differs from its recorded `sha` is "hand-edited". A scene with a marker block but no `sha` line (for example text the writer pasted in) is "unrecorded" and is protected exactly like a hand-edited scene.

## outlines/<scene-id>.md
```markdown
# S03 Beat Outline
1. Beat ...
2. Beat ...
```
No prose paragraphs.

## review.md
```markdown
# <Title> — Review
**Generated**: YYYY-MM-DD
## Summary              (counts by severity)
## Findings
| ID | Severity | Type | Locations | Description |
```
Severity: high | medium | low. Type: contradiction | timeline | unresolved-thread | tone-drift | pov-slip | principle-violation | coverage-gap | stale-artifact.
