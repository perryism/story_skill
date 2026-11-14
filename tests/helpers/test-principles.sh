#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
mkdir -p "$T/stories/demo" "$T/.storykit/memory"; echo demo > "$T/.storykit/active-story"
P="$SCRIPTS/principles.sh"

assert_eq "$(bash "$P" merge)" "" "neither file present prints nothing"
assert_exit_zero "neither file present exits 0" bash "$P" merge

printf '# Story Principles\n\n## Voice\nSpare.\n\n## Tone\nDark.\n' > "$T/.storykit/memory/principles.md"
out="$(bash "$P" merge)"
assert_contains "$out" "Spare." "project only: voice"
assert_contains "$out" "Dark." "project only: tone"

rm "$T/.storykit/memory/principles.md"
printf '# Story Principles\n\n## Point of View\nThird person.\n' > "$T/stories/demo/principles.md"
out="$(bash "$P" merge)"
assert_contains "$out" "Third person." "story only"

printf '# Story Principles\n\n## Voice\nSpare.\n\n## Tone\nDark.\n' > "$T/.storykit/memory/principles.md"
printf '# Story Principles\n\n## Tone\nWarm.\n' > "$T/stories/demo/principles.md"
out="$(bash "$P" merge)"
assert_contains "$out" "Warm." "story wins on conflict"
assert_not_contains "$out" "Dark." "project tone replaced"
assert_contains "$out" "Spare." "project-only heading kept"
assert_eq "$(printf '%s\n' "$out" | grep -c '^## Tone')" "1" "no duplicate heading"

printf '# Story Principles\n\n## Naming\nShort names.\n' > "$T/stories/demo/principles.md"
out="$(bash "$P" merge)"
assert_contains "$out" "Short names." "union: story heading"
assert_contains "$out" "Dark." "union: project heading"

mkdir -p "$T/stories/other"
out="$(bash "$P" merge --story other)"
assert_contains "$out" "Dark." "other story gets project defaults only"
assert_not_contains "$out" "Short names." "other story does not get demo's rules"
rm -rf "$T"; finish
