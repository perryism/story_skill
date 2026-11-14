#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
CB="$HELPERS_DIR/check-brief.sh"
assert_exit_zero "minimal fixture passes" bash "$CB" "$REAL_ROOT/tests/fixtures/minimal-story/brief.md"
assert_exit_zero "full fixture passes" bash "$CB" "$REAL_ROOT/tests/fixtures/full-story/brief.md"
new_root
sed '/^## Stakes$/d' "$REAL_ROOT/tests/fixtures/minimal-story/brief.md" > "$T/bad.md"
assert_exit_nonzero "missing heading fails" bash "$CB" "$T/bad.md"
{ cat "$REAL_ROOT/tests/fixtures/minimal-story/brief.md"; printf -- '- [ ] third\n- [ ] fourth\n'; } > "$T/many.md"
awk '/^## Clarifications$/{print "- [ ] third"; print "- [ ] fourth"} {print}' "$REAL_ROOT/tests/fixtures/minimal-story/brief.md" > "$T/many.md"
assert_exit_nonzero "4 open questions fails" bash "$CB" "$T/many.md"
rm -rf "$T"; finish
