# Helper Script Contracts

All scripts live in `.storykit/scripts/bash/`, start with `#!/usr/bin/env bash`, work on Bash 3.2, and are invoked as `bash <script>`. Exit 0 on success, non-zero with a message on stderr on failure. They never write prose or edit story text.

| Script | Arguments | Output | Side effects |
|--------|-----------|--------|--------------|
| `new-story.sh` | `--json "<slug>" ["<title>"]` | `{"STORY_DIR","SLUG","BRIEF"}` | Creates `stories/<slug>/`, copies brief template, sets active story. Fails if slug exists (suffix `-2`, `-3` offered) |
| `use-story.sh` | `<slug>` | `{"SLUG"}` | Sets `.storykit/active-story`; fails if the story does not exist |
| `check-prerequisites.sh` | `--json [--story <slug>] [--require brief,blueprint,scenes,manuscript]` | `{"STORY_DIR","SLUG","HAS":{"brief":bool,...},"MISSING":[...],"STALE":[...]}` (STALE covers blueprint ← brief, scenes ← blueprint, manuscript ← scenes) | None. Fails non-zero when a required artifact is missing; resolves the active story per research R3 |
| `scene-status.sh` | `list` \| `get <id>` \| `set <id> <status>` | list: one `ID<TAB>STATUS<TAB>TITLE` per line; get: status; set: confirmation | `set` rewrites only that scene's heading marker |
| `scene-hash.sh` | `extract <id>` \| `hash <id>` \| `record <id>` \| `check <id>` | extract: scene text; hash: hash; check: `assistant-written` \| `hand-edited` \| `unrecorded` \| `missing` | `record` writes or replaces only that scene's `sha` marker line. `unrecorded` (marker block without a `sha`) must be treated like `hand-edited` |
| `principles.sh` | `merge [--story <slug>]` | merged principles Markdown (story headings replace project headings of the same name) | None |
| `common.sh` | (sourced) | functions: repo root, slug, active-story resolution, date helpers | None |

Slug rule: lowercase, non-alphanumerics to hyphens, collapse repeats, trim, max 40 chars.
