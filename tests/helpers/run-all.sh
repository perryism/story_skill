#!/usr/bin/env bash
# Run every tests/helpers/test-*.sh; non-zero exit if any fail.
cd "$(dirname "$0")" || exit 1
status=0
for t in test-*.sh; do
  [ -e "$t" ] || continue
  bash "$t" || status=1
done
[ "$status" -eq 0 ] && echo "ALL TESTS PASSED" || echo "SOME TESTS FAILED"
exit $status
