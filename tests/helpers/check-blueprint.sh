#!/usr/bin/env bash
# check-blueprint.sh <story-dir>
d="${1:-}"; f="$d/blueprint.md"; br="$d/brief.md"
[ -f "$f" ] || { echo "usage: check-blueprint.sh <story-dir> (blueprint.md missing)" >&2; exit 2; }
rc=0
for h in "Structure" "Characters" "Setting and World Rules" "Plot Beats" "Themes"; do
  grep -qE "^## $h\$" "$f" || { echo "FAIL: missing heading '## $h'"; rc=1; }
done
grep -qE 'Built from\*{0,2}: *brief [0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" || { echo "FAIL: no 'Built from: brief <date>' line"; rc=1; }
names="$(sed -n -E 's/^### C[0-9]+ (.+)$/\1/p' "$f")"
[ -n "$names" ] || { echo "FAIL: no characters"; rc=1; }
dups="$(printf '%s\n' "$names" | sort | uniq -d)"
[ -z "$dups" ] || { echo "FAIL: duplicate character names: $dups"; rc=1; }
if [ -f "$br" ]; then
  awk '/^## Main Characters$/{on=1;next} /^## /{on=0} on && /^- /{print}' "$br" | sed -E 's/^- ([^—-]+)[—-].*$/\1/; s/ +$//' | while IFS= read -r n; do
    [ -n "$n" ] || continue
    printf '%s\n' "$names" | grep -qxF "$n" || { echo "FAIL: brief character '$n' missing from blueprint"; exit 9; }
  done
  [ $? -ne 9 ] || rc=1
fi
i=1
for id in $(sed -n -E 's/^### B([0-9]+) .*/\1/p' "$f"); do
  [ "$id" -eq "$i" ] || { echo "FAIL: beat ids not sequential (expected B$i, found B$id)"; rc=1; break; }
  i=$((i + 1))
done
[ "$i" -gt 1 ] || { echo "FAIL: no plot beats"; rc=1; }
[ $rc -eq 0 ] && echo "OK: $f"
exit $rc
