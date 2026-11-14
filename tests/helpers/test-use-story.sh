#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
mkdir -p "$T/stories/alpha"
out="$(bash "$SCRIPTS/use-story.sh" alpha)"
assert_eq "$out" '{"SLUG":"alpha"}' "json output"
assert_eq "$(cat "$T/.storykit/active-story")" "alpha" "active-story content"
assert_eq "$(wc -c < "$T/.storykit/active-story" | tr -d ' ')" "6" "slug plus single newline"
assert_exit_nonzero "unknown slug" bash "$SCRIPTS/use-story.sh" nope
assert_eq "$(cat "$T/.storykit/active-story")" "alpha" "unchanged after failure"
assert_exit_nonzero "no argument" bash "$SCRIPTS/use-story.sh"
rm -rf "$T"; finish
