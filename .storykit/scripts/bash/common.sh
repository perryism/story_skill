#!/usr/bin/env bash
# Shared helpers for Story Kit scripts. Source this file; do not execute it.
# Bash 3.2 compatible (no associative arrays, no mapfile).

# Project root: $STORYKIT_ROOT if set, else the nearest ancestor containing .storykit
repo_root() {
  if [ -n "${STORYKIT_ROOT:-}" ]; then
    printf '%s\n' "$STORYKIT_ROOT"
    return 0
  fi
  local d
  d="$(pwd)"
  while [ "$d" != "/" ]; do
    if [ -d "$d/.storykit" ]; then printf '%s\n' "$d"; return 0; fi
    d="$(dirname "$d")"
  done
  pwd
}

# lowercase, non-alphanumerics to hyphens, collapse repeats, trim, max 40 chars
slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//' | cut -c1-40 | sed -e 's/-$//'
}

today() { printf '%s\n' "${STORYKIT_TODAY:-$(date +%Y-%m-%d)}"; }

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

stories_dir() { printf '%s/stories\n' "$(repo_root)"; }

# resolve_story [explicit-slug]: prints the slug, or returns 1 with a message on stderr.
# Order: explicit argument -> .storykit/active-story -> the only story -> fail.
resolve_story() {
  local root explicit slug count list
  root="$(repo_root)"
  explicit="${1:-}"
  if [ -n "$explicit" ]; then
    if [ -d "$root/stories/$explicit" ]; then printf '%s\n' "$explicit"; return 0; fi
    echo "No story named '$explicit' exists." >&2
    return 1
  fi
  if [ -f "$root/.storykit/active-story" ]; then
    slug="$(head -n 1 "$root/.storykit/active-story" | tr -d '[:space:]')"
    if [ -n "$slug" ] && [ -d "$root/stories/$slug" ]; then printf '%s\n' "$slug"; return 0; fi
  fi
  count=0; list=""
  if [ -d "$root/stories" ]; then
    for d in "$root/stories"/*/; do
      [ -d "$d" ] || continue
      count=$((count + 1))
      list="$list $(basename "$d")"
    done
  fi
  if [ "$count" -eq 1 ]; then printf '%s\n' "${list# }"; return 0; fi
  if [ "$count" -eq 0 ]; then
    echo "No stories yet. Start one with /storykit-premise." >&2
  else
    echo "Several stories exist and none is active:${list}. Choose one with /storykit-status <story>." >&2
  fi
  return 1
}

# Date after "**Last updated**:" in a file, or empty
get_last_updated() {
  [ -f "$1" ] || return 0
  sed -n -E 's/.*\*\*Last updated\*\*: *([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/p' "$1" | head -n 1
}

# get_built_from file artifact -> date after "**Built from**: <artifact> " or "Built from: <artifact> "
get_built_from() {
  [ -f "$1" ] || return 0
  sed -n -E "s/.*Built from\\*{0,2}: *$2 *([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\\1/p" "$1" | head -n 1
}
