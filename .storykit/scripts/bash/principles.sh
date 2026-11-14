#!/usr/bin/env bash
# principles.sh merge [--story <slug>]
# Prints merged principles: a "## Heading" in the story file replaces the same heading from the project file.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

cmd="${1:-}"; shift || true
[ "$cmd" = "merge" ] || { echo "Usage: principles.sh merge [--story <slug>]" >&2; exit 2; }
story=""
if [ "${1:-}" = "--story" ]; then story="${2:-}"; fi

root="$(repo_root)"
files=""
[ -f "$root/.storykit/memory/principles.md" ] && files="$root/.storykit/memory/principles.md"
slug=""
if [ -n "$story" ]; then slug="$story"; else slug="$(resolve_story 2>/dev/null || true)"; fi
if [ -n "$slug" ] && [ -f "$root/stories/$slug/principles.md" ]; then
  files="$files $root/stories/$slug/principles.md"
fi
[ -n "${files# }" ] || exit 0

# shellcheck disable=SC2086
awk '
  FNR==1 {cur=""}
  /^## / {cur=$0; if (!(cur in seen)) {order[++n]=cur; seen[cur]=1} body[cur]=""; next}
  cur!="" {body[cur]=body[cur] $0 "\n"}
  END {for (i=1;i<=n;i++) printf "%s\n%s", order[i], body[order[i]]}
' $files
