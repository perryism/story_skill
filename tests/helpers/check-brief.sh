#!/usr/bin/env bash
# check-brief.sh <brief.md>: structural check of a story brief.
f="${1:-}"; [ -f "$f" ] || { echo "usage: check-brief.sh <brief.md>" >&2; exit 2; }
rc=0
for h in "Premise" "Genre and Tone" "Audience" "Target Length" "Main Characters" "Central Conflict" "Stakes" "Assumptions" "Open Questions" "Clarifications"; do
  grep -qE "^## $h\$" "$f" || { echo "FAIL: missing heading '## $h'"; rc=1; }
done
open="$(awk '/^## Open Questions$/{on=1;next} /^## /{on=0} on && /^- \[ \]/{c++} END{print c+0}' "$f")"
[ "$open" -le 3 ] || { echo "FAIL: $open open questions (max 3)"; rc=1; }
grep -qE '\*\*Last updated\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" || { echo "FAIL: no valid 'Last updated' date"; rc=1; }
[ $rc -eq 0 ] && echo "OK: $f"
exit $rc
