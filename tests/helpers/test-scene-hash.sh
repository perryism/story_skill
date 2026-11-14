#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
S="$T/stories/demo"; mkdir -p "$S"; echo demo > "$T/.storykit/active-story"
cat > "$S/manuscript.md" <<'MD'
# Demo
**Built from**: scenes 2026-11-13
Intro text outside any scene.
<!-- scene:S01 start -->
The keeper climbed the stairs.
He did not look back.
<!-- scene:S01 end -->
Between scenes note.
<!-- scene:S02 start -->
Pasted by the writer.
<!-- scene:S02 end -->
MD
SH="$SCRIPTS/scene-hash.sh"
assert_eq "$(bash "$SH" extract S01)" "$(printf 'The keeper climbed the stairs.\nHe did not look back.')" "extract"
h1="$(bash "$SH" hash S01)"; h2="$(bash "$SH" hash S01)"
assert_eq "$h1" "$h2" "hash stable"
assert_eq "${#h1}" "64" "sha256 length"
assert_eq "$(bash "$SH" check S01)" "unrecorded" "no sha line yet"
cp "$S/manuscript.md" "$T/before.md"
bash "$SH" record S01 >/dev/null
assert_eq "$(bash "$SH" check S01)" "assistant-written" "after record"
diff "$T/before.md" "$S/manuscript.md" | grep '^[<>]' > "$T/diff.txt"
assert_eq "$(wc -l < "$T/diff.txt" | tr -d ' ')" "1" "record adds exactly one line"
bash "$SH" record S01 >/dev/null
assert_eq "$(grep -c 'scene:S01 sha:' "$S/manuscript.md")" "1" "re-record replaces, not duplicates"
sed -i.bak 's/climbed/climbs/' "$S/manuscript.md"; rm -f "$S/manuscript.md.bak"
assert_eq "$(bash "$SH" check S01)" "hand-edited" "edit detected"
assert_eq "$(bash "$SH" check S02)" "unrecorded" "pasted scene is unrecorded"
assert_eq "$(bash "$SH" check S09)" "missing" "no block"
assert_exit_nonzero "extract missing" bash "$SH" extract S09
assert_exit_nonzero "record missing" bash "$SH" record S09
rm -rf "$T"; finish
