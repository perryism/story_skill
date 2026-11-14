#!/usr/bin/env bash
# check-scenes.sh <story-dir>: beat coverage and scene-list sanity
d="${1:-}"; s="$d/scenes.md"; b="$d/blueprint.md"
[ -f "$s" ] && [ -f "$b" ] || { echo "usage: check-scenes.sh <story-dir> (needs scenes.md and blueprint.md)" >&2; exit 2; }
rc=0
beats="$(sed -n -E 's/^### (B[0-9]+) .*/\1/p' "$b")"
used="$(grep -E '^- Beats:' "$s" | sed -E 's/^- Beats: *//' | tr ',' '\n' | tr -d ' ' | sort -u)"
for x in $beats; do
  printf '%s\n' "$used" | grep -qx "$x" || { echo "FAIL: beat $x is not covered by any scene"; rc=1; }
done
for x in $used; do
  printf '%s\n' "$beats" | grep -qx "$x" || { echo "FAIL: scene references unknown beat $x"; rc=1; }
done
bad="$(grep -E '^## S[0-9]+ \[' "$s" | grep -vE '^## S[0-9]+ \[(not-started|drafted|approved)\] .+$')"
[ -z "$bad" ] || { echo "FAIL: invalid scene status heading(s): $bad"; rc=1; }
dups="$(grep -oE '^## S[0-9]+' "$s" | sort | uniq -d)"
[ -z "$dups" ] || { echo "FAIL: duplicate scene ids: $dups"; rc=1; }
# every scene has a Beats line
heads=$(grep -cE '^## S[0-9]+ \[' "$s"); blines=$(grep -cE '^- Beats:' "$s")
[ "$heads" -eq "$blines" ] || { echo "FAIL: $heads scenes but $blines Beats lines"; rc=1; }
[ $rc -eq 0 ] && echo "OK: $s"
exit $rc
