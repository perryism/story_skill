#!/usr/bin/env bash
# check-terminology.sh: Story Kit user-facing files must not use Spec Kit jargon (FR-018).
root="$(cd "$(dirname "$0")/../.." && pwd)"
rc=0
files="$(ls "$root"/.claude/skills/storykit-*/SKILL.md "$root"/.storykit/templates/*.md "$root"/.storykit/conventions.md 2>/dev/null)"
for pat in 'speckit' 'constitution' '\.specify' '/specify' 'tasks\.md' 'spec\.md'; do
  hits="$(grep -nE -- "$pat" $files 2>/dev/null)"
  [ -z "$hits" ] || { echo "FAIL: found '$pat':"; echo "$hits"; rc=1; }
done
[ $rc -eq 0 ] && echo "OK: no Spec Kit terms in user-facing files"
exit $rc
