#!/usr/bin/env bash
# scene-status.sh [--story <slug>] list | get <id> | set <id> <status>
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

story=""
if [ "${1:-}" = "--story" ]; then story="${2:-}"; shift 2; fi
cmd="${1:-}"; shift || true
slug="$(resolve_story "$story")" || exit 2
file="$(repo_root)/stories/$slug/scenes.md"
[ -f "$file" ] || { echo "No scene list yet for '$slug'. Run /storykit-scenes first." >&2; exit 1; }

HEAD_RE='^## (S[0-9]+) \[(not-started|drafted|approved)\] (.+)$'

case "$cmd" in
  list)
    grep -E "$HEAD_RE" "$file" | sed -E 's/^## (S[0-9]+) \[([a-z-]+)\] (.+)$/\1	\2	\3/'
    ;;
  get)
    id="${1:-}"; [ -n "$id" ] || { echo "Usage: get <id>" >&2; exit 2; }
    line="$(grep -E "^## $id \[" "$file" | head -n 1)"
    [ -n "$line" ] || { echo "No scene $id." >&2; exit 1; }
    printf '%s\n' "$line" | sed -E 's/^## S[0-9]+ \[([a-z-]+)\].*$/\1/'
    ;;
  set)
    id="${1:-}"; status="${2:-}"
    [ -n "$id" ] && [ -n "$status" ] || { echo "Usage: set <id> <status>" >&2; exit 2; }
    case "$status" in not-started|drafted|approved) ;; *) echo "Invalid status '$status' (use not-started, drafted, or approved)." >&2; exit 2 ;; esac
    grep -qE "^## $id \[" "$file" || { echo "No scene $id." >&2; exit 1; }
    tmp="$(mktemp "${TMPDIR:-/tmp}/scene-status.XXXXXX")"
    sed -E "s/^(## $id )\[[a-z-]+\]/\1[$status]/" "$file" > "$tmp" && cat "$tmp" > "$file"
    rm -f "$tmp"
    echo "$id is now $status"
    ;;
  *) echo "Usage: scene-status.sh [--story <slug>] list | get <id> | set <id> <status>" >&2; exit 2 ;;
esac
