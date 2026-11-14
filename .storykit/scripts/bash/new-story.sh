#!/usr/bin/env bash
# new-story.sh --json "<slug>" ["<title>"]
# Creates stories/<slug>/ from the brief template and makes it the active story.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

[ "${1:-}" = "--json" ] && shift
raw="${1:-}"; title="${2:-}"
[ -n "$raw" ] || { echo "Usage: new-story.sh --json \"<slug>\" [\"<title>\"]" >&2; exit 2; }
slug="$(slugify "$raw")"
[ -n "$slug" ] || { echo "Could not make a name from '$raw'." >&2; exit 2; }
[ -n "$title" ] || title="$raw"

root="$(repo_root)"
dir="$root/stories/$slug"
if [ -e "$dir" ]; then
  n=2
  while [ -e "$root/stories/$slug-$n" ] && [ "$n" -lt 100 ]; do n=$((n + 1)); done
  echo "A story named '$slug' already exists. Try '$slug-$n' instead." >&2
  exit 1
fi
tpl="$root/.storykit/templates/brief-template.md"
[ -f "$tpl" ] || { echo "Missing template: $tpl" >&2; exit 1; }

mkdir -p "$dir"
esc_title="$(printf '%s' "$title" | sed -e 's/[&|\\]/\\&/g')"
sed -e "s|\[TITLE\]|$esc_title|g" -e "s|\[SLUG\]|$slug|g" -e "s|\[DATE\]|$(today)|g" "$tpl" > "$dir/brief.md"
printf '%s\n' "$slug" > "$root/.storykit/active-story"
printf '{"STORY_DIR":"%s","SLUG":"%s","BRIEF":"%s"}\n' "$(json_escape "$dir")" "$slug" "$(json_escape "$dir/brief.md")"
