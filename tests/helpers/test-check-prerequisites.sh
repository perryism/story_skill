#!/usr/bin/env bash
. "$(dirname "$0")/assert.sh"
new_root
S="$T/stories/demo"; mkdir -p "$S"
CP="$SCRIPTS/check-prerequisites.sh"

printf '# Demo\n**Slug**: demo   **Last updated**: 2026-11-13\n' > "$S/brief.md"
out="$(bash "$CP" --json)"; rc=$?
assert_eq "$rc" "0" "brief only, nothing required"
assert_contains "$out" '"brief":true' "has brief"
assert_contains "$out" '"blueprint":false' "no blueprint"
assert_contains "$out" '"MISSING":[]' "nothing missing"

out="$(bash "$CP" --json --require brief,blueprint 2>/dev/null)"; rc=$?
assert_eq "$rc" "1" "missing required exits 1"
assert_contains "$out" '"MISSING":["blueprint"]' "blueprint listed missing"
assert_exit_nonzero "bad artifact name" bash "$CP" --json --require nonsense

printf '# Demo\n**Built from**: brief 2026-11-13   **Last updated**: 2026-11-13\n' > "$S/blueprint.md"
out="$(bash "$CP" --json)"
assert_contains "$out" '"STALE":[]' "fresh blueprint"
printf '# Demo\n**Slug**: demo   **Last updated**: 2026-11-14\n' > "$S/brief.md"
out="$(bash "$CP" --json)"
assert_contains "$out" 'blueprint (brief changed 2026-11-14)' "stale blueprint after brief change"

printf '# Demo\n**Built from**: blueprint 2026-11-13   **Last updated**: 2026-11-13\n' > "$S/scenes.md"
printf '# Demo\n**Built from**: scenes 2026-11-10\n' > "$S/manuscript.md"
out="$(bash "$CP" --json)"
assert_contains "$out" 'manuscript (scenes changed 2026-11-13)' "stale manuscript after scenes change"

mkdir -p "$T/stories/other"; printf '# O\n**Last updated**: 2026-11-13\n' > "$T/stories/other/brief.md"
out="$(bash "$CP" --json --story other 2>&1)"
assert_contains "$out" '"SLUG":"other"' "explicit --story override"
out="$(bash "$CP" --json --story missing 2>&1)"; rc=$?
assert_eq "$rc" "2" "unknown story exits 2"
rm -rf "$T"; finish
