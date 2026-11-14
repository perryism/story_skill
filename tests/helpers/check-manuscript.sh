#!/usr/bin/env bash
# check-manuscript.sh <story-dir>
d="${1:-}"; m="$d/manuscript.md"; s="$d/scenes.md"
[ -f "$s" ] || { echo "usage: check-manuscript.sh <story-dir> (scenes.md missing)" >&2; exit 2; }
rc=0
if [ -f "$m" ]; then
  st="$(grep -c '^<!-- scene:S[0-9]* start -->$' "$m")"; en="$(grep -c '^<!-- scene:S[0-9]* end -->$' "$m")"
  [ "$st" -eq "$en" ] || { echo "FAIL: unbalanced markers ($st start, $en end)"; rc=1; }
  order_m="$(sed -n -E 's/^<!-- scene:(S[0-9]+) start -->$/\1/p' "$m" | tr '\n' ' ')"
  order_s="$(sed -n -E 's/^## (S[0-9]+) \[.*$/\1/p' "$s" | tr '\n' ' ')"
  # manuscript order must be a subsequence of scene-list order
  pos=0; ok=1
  for id in $order_m; do
    found=0; idx=0
    for sid in $order_s; do
      idx=$((idx + 1))
      if [ "$sid" = "$id" ]; then found=$idx; break; fi
    done
    if [ "$found" -le "$pos" ]; then ok=0; fi
    pos=$found
  done
  [ "$ok" -eq 1 ] || { echo "FAIL: manuscript scene order differs from scenes.md"; rc=1; }
fi
grep -E '^## S[0-9]+ \[(drafted|approved)\]' "$s" | sed -E 's/^## (S[0-9]+) .*/\1/' | while IFS= read -r id; do
  if [ ! -f "$m" ] || ! grep -qF "<!-- scene:$id start -->" "$m"; then echo "FAIL: $id is drafted/approved but has no text in the manuscript"; exit 9; fi
done
[ $? -ne 9 ] || rc=1
for o in "$d"/outlines/*.md; do
  [ -f "$o" ] || continue
  w="$(grep -vE '^(#|[0-9]+\.|- |<!--|$)' "$o" | awk '{ if (NF>40) c++ } END{print c+0}')"
  [ "$w" -eq 0 ] || { echo "FAIL: $o contains a prose paragraph"; rc=1; }
  long="$(grep -E '^[0-9]+\. ' "$o" | awk '{ if (NF>40) c++ } END{print c+0}')"
  [ "$long" -eq 0 ] || { echo "FAIL: $o has a beat longer than 40 words (prose leak)"; rc=1; }
done
[ $rc -eq 0 ] && echo "OK: manuscript"
exit $rc
