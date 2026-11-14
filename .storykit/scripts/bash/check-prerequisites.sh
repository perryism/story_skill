#!/usr/bin/env bash
# check-prerequisites.sh --json [--story <slug>] [--require brief,blueprint,scenes,manuscript]
# Reports which artifacts exist, which required ones are missing, and which are stale.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

story=""; require=""
while [ $# -gt 0 ]; do
  case "$1" in
    --json) shift ;;
    --story) story="${2:-}"; shift 2 ;;
    --require) require="${2:-}"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

slug="$(resolve_story "$story")" || exit 2
root="$(repo_root)"
dir="$root/stories/$slug"

has() { [ -f "$dir/$1" ] && echo true || echo false; }
h_brief="$(has brief.md)"; h_blue="$(has blueprint.md)"; h_scenes="$(has scenes.md)"
h_ms="$(has manuscript.md)"; h_rev="$(has review.md)"; h_pr="$(has principles.md)"

missing=""
for a in $(printf '%s' "$require" | tr ',' ' '); do
  case "$a" in
    brief) f=brief.md ;; blueprint) f=blueprint.md ;; scenes) f=scenes.md ;;
    manuscript) f=manuscript.md ;; *) echo "Unknown artifact: $a" >&2; exit 2 ;;
  esac
  [ -f "$dir/$f" ] || missing="$missing\"$a\","
done
missing="[${missing%,}]"

stale=""
check_stale() { # downstream-file downstream-name upstream-file upstream-name
  local b u
  [ -f "$dir/$1" ] && [ -f "$dir/$3" ] || return 0
  b="$(get_built_from "$dir/$1" "$4")"
  u="$(get_last_updated "$dir/$3")"
  [ -n "$b" ] && [ -n "$u" ] || return 0
  if [[ "$u" > "$b" ]]; then stale="$stale\"$2 ($4 changed $u)\","; fi
}
check_stale blueprint.md blueprint brief.md brief
check_stale scenes.md scenes blueprint.md blueprint
check_stale manuscript.md manuscript scenes.md scenes
stale="[${stale%,}]"

printf '{"STORY_DIR":"%s","SLUG":"%s","HAS":{"brief":%s,"blueprint":%s,"scenes":%s,"manuscript":%s,"review":%s,"principles":%s},"MISSING":%s,"STALE":%s}\n' \
  "$(json_escape "$dir")" "$(json_escape "$slug")" "$h_brief" "$h_blue" "$h_scenes" "$h_ms" "$h_rev" "$h_pr" "$missing" "$stale"

if [ "$missing" != "[]" ]; then
  echo "Missing required stage(s): $missing" >&2
  exit 1
fi
exit 0
