#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
. "$SCRIPTS/common.sh"

assert_eq "$(slugify 'The Lighthouse Keeper!')" "the-lighthouse-keeper" "basic slug"
assert_eq "$(slugify '  --Hello,,, World--  ')" "hello-world" "repeated punctuation and trim"
long="$(slugify 'abcdefghi abcdefghi abcdefghi abcdefghi abcdefghi')"
assert_eq "${#long}" "39" "40-char cap then trailing hyphen trimmed"
assert_eq "$(slugify 'Ünï')" "n" "non-ascii stripped"

# resolve_story branches
out="$(resolve_story 2>&1)"; rc=$?
assert_contains "$out" "No stories yet" "no stories message"
[ "$rc" -ne 0 ] && _ok || _fail "no stories should fail"

mkdir -p "$T/stories/alpha"
assert_eq "$(resolve_story)" "alpha" "only story is used"
mkdir -p "$T/stories/beta"
out="$(resolve_story 2>&1)"; rc=$?
assert_contains "$out" "alpha" "ambiguous lists alpha"
assert_contains "$out" "beta" "ambiguous lists beta"
[ "$rc" -ne 0 ] && _ok || _fail "ambiguous should fail"

echo beta > "$T/.storykit/active-story"
assert_eq "$(resolve_story)" "beta" "active-story file wins"
assert_eq "$(resolve_story alpha)" "alpha" "explicit argument wins"
assert_exit_nonzero "unknown explicit story" resolve_story nope
echo gone > "$T/.storykit/active-story"
out="$(resolve_story 2>&1)"
assert_contains "$out" "Several stories" "stale active pointer falls back to listing"

assert_eq "$(STORYKIT_TODAY=2026-01-02 today)" "2026-01-02" "today override"
assert_eq "$(json_escape 'a"b\c')" 'a\"b\\c' "json escape"
rm -rf "$T"; finish
