#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
S="$T/stories/demo"; mkdir -p "$S"; echo demo > "$T/.storykit/active-story"
cat > "$S/scenes.md" <<'MD'
# Demo — Scenes
**Built from**: blueprint 2026-11-13   **Last updated**: 2026-11-13

## S01 [approved] The Keeper
- Purpose: open

## S02 [not-started] The Light Flickers
- Purpose: inciting

## S10 [drafted] Aftermath
- Purpose: end
MD
SS="$SCRIPTS/scene-status.sh"
list="$(bash "$SS" list)"
assert_eq "$(printf '%s\n' "$list" | wc -l | tr -d ' ')" "3" "three scenes listed"
assert_eq "$(printf '%s\n' "$list" | sed -n 2p)" "$(printf 'S02\tnot-started\tThe Light Flickers')" "tab-separated row"
assert_eq "$(bash "$SS" get S01)" "approved" "get S01"
assert_eq "$(bash "$SS" get S10)" "drafted" "get two-digit id"
cp "$S/scenes.md" "$T/before.md"
bash "$SS" set S02 drafted >/dev/null
assert_eq "$(bash "$SS" get S02)" "drafted" "set worked"
diff "$T/before.md" "$S/scenes.md" | grep '^[<>]' > "$T/diff.txt"
assert_eq "$(wc -l < "$T/diff.txt" | tr -d ' ')" "2" "only one line changed"
assert_contains "$(cat "$T/diff.txt")" "## S02 [drafted] The Light Flickers" "heading rewritten"
assert_exit_nonzero "invalid status" bash "$SS" set S02 finished
assert_exit_nonzero "unknown scene set" bash "$SS" set S99 drafted
assert_exit_nonzero "unknown scene get" bash "$SS" get S99
assert_eq "$(bash "$SS" get S01)" "approved" "S01 untouched (S1 vs S10 prefix safe)"
rm -rf "$T"; finish
