#!/usr/bin/env bash
# score-review.sh snapshot <story-dir> <snapshot-file>
# score-review.sh score <story-dir> <answer-key.md> [<snapshot-file>]
# Answer key rows: "N | location-a | location-b | note". An issue counts as found when a single
# line of review.md contains both locations. With a snapshot, also verifies nothing but review.md changed.
mode="${1:-}"; d="${2:-}"
sums() { (cd "$1" && find . -type f ! -name review.md | LC_ALL=C sort | while IFS= read -r f; do printf '%s  ' "$f"; (shasum -a 256 "$f" 2>/dev/null || sha256sum "$f") | cut -d' ' -f1; done); }
case "$mode" in
  snapshot) sums "$d" > "${3:?snapshot file}"; echo "snapshot saved" ;;
  score)
    key="${3:?answer key}"; r="$d/review.md"
    [ -f "$r" ] || { echo "FAIL: no review.md"; exit 1; }
    total=0; found=0
    while IFS='|' read -r n a b _; do
      n="$(echo "$n" | tr -d ' ')"; a="$(echo "$a" | sed 's/^ *//; s/ *$//')"; b="$(echo "$b" | sed 's/^ *//; s/ *$//')"
      case "$n" in ''|*[!0-9]*) continue ;; esac
      total=$((total + 1))
      if grep -F -- "$a" "$r" | grep -qF -- "$b"; then found=$((found + 1)); else echo "missed issue $n ($a, $b)"; fi
    done < "$key"
    echo "recall: $found of $total"
    rc=0
    [ "$found" -ge 4 ] || { echo "FAIL: recall below 4 of 5"; rc=1; }
    if [ -n "${4:-}" ]; then
      sums "$d" > "${4}.after"
      if diff -q "$4" "${4}.after" >/dev/null; then echo "OK: no files changed except review.md"; else echo "FAIL: files other than review.md changed"; rc=1; fi
      rm -f "${4}.after"
    fi
    exit $rc ;;
  *) echo "usage: score-review.sh snapshot|score ..." >&2; exit 2 ;;
esac
