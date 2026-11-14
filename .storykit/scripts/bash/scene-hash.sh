#!/usr/bin/env bash
# scene-hash.sh [--story <slug>] extract|hash|record|check <id>
# Detects hand-edited manuscript scenes using a recorded hash (research R5).
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

story=""
if [ "${1:-}" = "--story" ]; then story="${2:-}"; shift 2; fi
cmd="${1:-}"; id="${2:-}"
[ -n "$cmd" ] && [ -n "$id" ] || { echo "Usage: scene-hash.sh [--story <slug>] extract|hash|record|check <id>" >&2; exit 2; }
slug="$(resolve_story "$story")" || exit 2
file="$(repo_root)/stories/$slug/manuscript.md"
[ -f "$file" ] || { echo "No manuscript yet for '$slug'." >&2; exit 1; }

START="<!-- scene:$id start -->"; END="<!-- scene:$id end -->"

has_block() { grep -qF "$START" "$file" && grep -qF "$END" "$file"; }

extract() {
  awk -v s="$START" -v e="$END" '$0==s{on=1;next} $0==e{on=0} on{print}' "$file"
}
sha() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 | cut -d' ' -f1; else sha256sum | cut -d' ' -f1; fi; }
recorded() { sed -n -E "s/^<!-- scene:$id sha:([0-9a-f]+) -->\$/\\1/p" "$file" | head -n 1; }

case "$cmd" in
  extract) has_block || { echo "missing" >&2; exit 1; }; extract ;;
  hash) has_block || { echo "missing" >&2; exit 1; }; extract | sha ;;
  record)
    has_block || { echo "Scene $id has no marker block." >&2; exit 1; }
    h="$(extract | sha)"
    tmp="$(mktemp "${TMPDIR:-/tmp}/scene-hash.XXXXXX")"
    awk -v id="$id" -v e="$END" -v h="$h" '
      $0 ~ "^<!-- scene:" id " sha:[0-9a-f]+ -->$" {next}
      {print}
      $0==e {print "<!-- scene:" id " sha:" h " -->"}
    ' "$file" > "$tmp" && cat "$tmp" > "$file"
    rm -f "$tmp"
    echo "$h"
    ;;
  check)
    if ! has_block; then echo "missing"; exit 0; fi
    r="$(recorded)"
    if [ -z "$r" ]; then echo "unrecorded"; exit 0; fi
    h="$(extract | sha)"
    if [ "$h" = "$r" ]; then echo "assistant-written"; else echo "hand-edited"; fi
    ;;
  *) echo "Unknown command: $cmd" >&2; exit 2 ;;
esac
