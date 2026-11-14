#!/usr/bin/env bash
# check-clarifications.sh <before.md> <after.md>
b="${1:-}"; a="${2:-}"
[ -f "$b" ] && [ -f "$a" ] || { echo "usage: check-clarifications.sh <before.md> <after.md>" >&2; exit 2; }
rc=0
count_q() { grep -c '^- Q: ' "$1"; }
count_open() { awk '/^## Open Questions$/{on=1;next} /^## /{on=0} on && /^- \[ \]/{c++} END{print c+0}' "$1"; }
new=$(( $(count_q "$a") - $(count_q "$b") ))
[ "$new" -le 5 ] || { echo "FAIL: $new new clarification entries (max 5)"; rc=1; }
[ "$(count_open "$a")" -le "$(count_open "$b")" ] || { echo "FAIL: more open questions after than before"; rc=1; }
norm() { tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 ]//g; s/ +/ /g; s/^ //; s/ $//'; }
awk '/^## Open Questions$/{on=1;next} /^## /{on=0} on && /^- \[ \]/{sub(/^- \[ \] */,""); print}' "$a" | while IFS= read -r q; do
  nq="$(printf '%s' "$q" | norm)"
  [ -n "$nq" ] || continue
  if grep '^- Q: ' "$a" | norm | grep -qF "$nq"; then echo "FAIL: resolved question still listed as open: $q"; exit 9; fi
done
[ $? -ne 9 ] || rc=1
[ $rc -eq 0 ] && echo "OK"
exit $rc
