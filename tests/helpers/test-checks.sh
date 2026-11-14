#!/usr/bin/env bash
# Runs the structural check scripts against the fixtures (positive and negative cases).
. "$(dirname "$0")/assert.sh"
FX="$REAL_ROOT/tests/fixtures"; H="$HELPERS_DIR"
new_root

# check-blueprint / check-scenes / check-manuscript on the consistent fixture
assert_exit_zero "blueprint ok" bash "$H/check-blueprint.sh" "$FX/full-story"
assert_exit_zero "scenes ok" bash "$H/check-scenes.sh" "$FX/full-story"
assert_exit_zero "manuscript ok" bash "$H/check-manuscript.sh" "$FX/full-story"

# negative: remove a scene covering B5
cp -R "$FX/full-story" "$T/bad"
awk '/^## S06 /{skip=1} !skip{print}' "$FX/full-story/scenes.md" > "$T/bad/scenes.md"
out="$(bash "$H/check-scenes.sh" "$T/bad" 2>&1)"; rc=$?
assert_eq "$rc" "1" "uncovered beat fails"
assert_contains "$out" "beat B5 is not covered" "names the uncovered beat"
# negative: invalid status
sed 's/S02 \[drafted\]/S02 [finished]/' "$FX/full-story/scenes.md" > "$T/bad/scenes.md"
assert_exit_nonzero "invalid status fails" bash "$H/check-scenes.sh" "$T/bad"
# negative: duplicate character / missing brief character
sed 's/^### C2 Tobias Vane/### C2 Maren Holt/' "$FX/full-story/blueprint.md" > "$T/bad/blueprint.md"
assert_exit_nonzero "duplicate character names fail" bash "$H/check-blueprint.sh" "$T/bad"
sed 's/^### C2 Tobias Vane/### C2 Someone Else/' "$FX/full-story/blueprint.md" > "$T/bad/blueprint.md"
assert_exit_nonzero "missing brief character fails" bash "$H/check-blueprint.sh" "$T/bad"
cp "$FX/full-story/blueprint.md" "$T/bad/blueprint.md"
# negative: drafted scene without text
grep -v 'scene:S03' "$FX/full-story/manuscript.md" > "$T/bad/manuscript.md"
assert_exit_nonzero "unbalanced/missing scene text fails" bash "$H/check-manuscript.sh" "$T/bad"
# negative: outline with prose
cp "$FX/full-story/manuscript.md" "$T/bad/manuscript.md"; mkdir -p "$T/bad/outlines"
printf '# S04 Beat Outline\n\n1. Maren opens the logbook.\n\nThis is a long paragraph of prose that goes on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on and on.\n' > "$T/bad/outlines/S04.md"
assert_exit_nonzero "prose in outline fails" bash "$H/check-manuscript.sh" "$T/bad"
printf '# S04 Beat Outline\n\n1. Maren opens the logbook.\n2. She finds the old pattern.\n' > "$T/bad/outlines/S04.md"
assert_exit_zero "short beat outline ok" bash "$H/check-manuscript.sh" "$T/bad"

# fixture hashes are intact
mkdir -p "$T/.storykit" "$T/stories/f"; cp "$FX/full-story/manuscript.md" "$T/stories/f/"
for id in S01 S02 S03; do assert_eq "$(bash "$SCRIPTS/scene-hash.sh" --story f check $id)" "assistant-written" "fixture $id hash intact"; done
mkdir -p "$T/stories/x"; cp "$FX/seeded-contradictions/manuscript.md" "$T/stories/x/"
for id in S01 S02 S03; do assert_eq "$(bash "$SCRIPTS/scene-hash.sh" --story x check $id)" "assistant-written" "seeded $id hash intact"; done

# check-clarifications
cp "$FX/brief-with-gaps/brief.md" "$T/before.md"
cp "$T/before.md" "$T/after.md"
assert_exit_zero "unchanged brief ok" bash "$H/check-clarifications.sh" "$T/before.md" "$T/after.md"
printf -- '- Q: Whose point of view tells the story? → A: Maren\n' >> "$T/after.md"
sed -i.bak '/Whose point of view tells the story/{/^- \[ \]/d;}' "$T/after.md"; rm -f "$T/after.md.bak"
assert_exit_zero "resolved question removed ok" bash "$H/check-clarifications.sh" "$T/before.md" "$T/after.md"
cp "$T/before.md" "$T/after.md"; printf -- '- Q: Whose point of view tells the story? → A: Maren\n' >> "$T/after.md"
assert_exit_nonzero "resolved question still open fails" bash "$H/check-clarifications.sh" "$T/before.md" "$T/after.md"
cp "$T/before.md" "$T/after.md"; for i in 1 2 3 4 5 6; do printf -- "- Q: q$i → A: a$i\n" >> "$T/after.md"; done
assert_exit_nonzero "6 new entries fails" bash "$H/check-clarifications.sh" "$T/before.md" "$T/after.md"

# score-review on the seeded fixture
cp -R "$FX/seeded-contradictions" "$T/seed"
bash "$H/score-review.sh" snapshot "$T/seed" "$T/snap" >/dev/null
cat > "$T/seed/review.md" <<'MD'
# Review
| ID | Severity | Type | Locations | Description |
|----|----------|------|-----------|-------------|
| F1 | high | contradiction | manuscript.md#S01, manuscript.md#S03 | eyes |
| F2 | medium | timeline | manuscript.md#S02, manuscript.md#S03 | time |
| F3 | high | pov-slip | manuscript.md#S02, principles.md | first person |
| F4 | medium | pov-slip | manuscript.md#S03, scenes.md#S03 | head-hop |
MD
out="$(bash "$H/score-review.sh" score "$T/seed" "$FX/seeded-contradictions/answer-key.md" "$T/snap" 2>&1)"; rc=$?
assert_eq "$rc" "0" "4 of 5 passes"; assert_contains "$out" "recall: 4 of 5" "recall counted"
assert_contains "$out" "no files changed except review.md" "read-only verified"
echo changed >> "$T/seed/brief.md"
assert_exit_nonzero "modified file detected" bash "$H/score-review.sh" score "$T/seed" "$FX/seeded-contradictions/answer-key.md" "$T/snap"
head -n 5 "$T/seed/review.md" > "$T/seed/review.md.new" && mv "$T/seed/review.md.new" "$T/seed/review.md"
assert_exit_nonzero "recall under 4 fails" bash "$H/score-review.sh" score "$T/seed" "$FX/seeded-contradictions/answer-key.md"

assert_exit_zero "terminology clean" bash "$H/check-terminology.sh"
rm -rf "$T"; finish
