#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
export STORYKIT_TODAY=2026-11-13
out="$(bash "$SCRIPTS/new-story.sh" --json "The Lighthouse Signal" "The Lighthouse Signal")"
assert_contains "$out" '"SLUG":"the-lighthouse-signal"' "slug in json"
assert_contains "$out" '"STORY_DIR":"' "dir in json"
assert_contains "$out" '"BRIEF":"' "brief in json"
assert_file_exists "$T/stories/the-lighthouse-signal/brief.md" "brief created"
assert_eq "$(cat "$T/.storykit/active-story")" "the-lighthouse-signal" "active story set"
brief="$(cat "$T/stories/the-lighthouse-signal/brief.md")"
assert_contains "$brief" "# The Lighthouse Signal — Story Brief" "title filled"
assert_contains "$brief" "**Last updated**: 2026-11-13" "date filled"
assert_not_contains "$brief" "[TITLE]" "no leftover placeholder"
out="$(bash "$SCRIPTS/new-story.sh" --json "the lighthouse signal" 2>&1)"; rc=$?
assert_eq "$rc" "1" "duplicate refused"
assert_contains "$out" "the-lighthouse-signal-2" "suffix suggested"
bash "$SCRIPTS/new-story.sh" --json "the-lighthouse-signal-2" >/dev/null
out="$(bash "$SCRIPTS/new-story.sh" --json "the lighthouse signal" 2>&1)"
assert_contains "$out" "the-lighthouse-signal-3" "next free suffix"
assert_exit_nonzero "empty slug" bash "$SCRIPTS/new-story.sh" --json ""
assert_exit_nonzero "only punctuation" bash "$SCRIPTS/new-story.sh" --json "!!!"
rm -rf "$T"; finish
