#!/usr/bin/env bash
# use-story.sh <slug>: make a story the active one.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"
slug="${1:-}"
[ -n "$slug" ] || { echo "Usage: use-story.sh <slug>" >&2; exit 2; }
root="$(repo_root)"
if [ ! -d "$root/stories/$slug" ]; then
  echo "No story named '$slug' exists." >&2
  exit 1
fi
mkdir -p "$root/.storykit"
printf '%s\n' "$slug" > "$root/.storykit/active-story"
printf '{"SLUG":"%s"}\n' "$(json_escape "$slug")"
