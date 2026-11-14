#!/usr/bin/env bash
# Tiny assertion helpers for Story Kit tests. Bash 3.2 compatible.
PASS=0
FAIL=0
HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_ROOT="$(cd "$HELPERS_DIR/../.." && pwd)"
SCRIPTS="$REAL_ROOT/.storykit/scripts/bash"

_ok()   { PASS=$((PASS + 1)); }
_fail() { FAIL=$((FAIL + 1)); echo "FAIL: $1"; }

assert_eq() { # actual expected message
  if [ "$1" = "$2" ]; then _ok; else _fail "${3:-assert_eq} (expected '$2', got '$1')"; fi
}
assert_contains() { # haystack needle message
  case "$1" in *"$2"*) _ok ;; *) _fail "${3:-assert_contains} ('$2' not found in '$1')" ;; esac
}
assert_not_contains() {
  case "$1" in *"$2"*) _fail "${3:-assert_not_contains} ('$2' found)" ;; *) _ok ;; esac
}
assert_file_exists() { if [ -e "$1" ]; then _ok; else _fail "${2:-file missing}: $1"; fi; }
assert_file_missing() { if [ ! -e "$1" ]; then _ok; else _fail "${2:-file should not exist}: $1"; fi; }
assert_exit_nonzero() { # message cmd args...
  local msg="$1"; shift
  if "$@" >/dev/null 2>&1; then _fail "$msg (expected non-zero exit)"; else _ok; fi
}
assert_exit_zero() {
  local msg="$1"; shift
  if "$@" >/dev/null 2>&1; then _ok; else _fail "$msg (expected zero exit)"; fi
}

# Create an isolated project root with scripts' templates; exports STORYKIT_ROOT.
new_root() {
  T="$(mktemp -d "${TMPDIR:-/tmp}/storykit-test.XXXXXX")"
  mkdir -p "$T/.storykit" "$T/stories"
  [ -d "$REAL_ROOT/.storykit/templates" ] && cp -R "$REAL_ROOT/.storykit/templates" "$T/.storykit/"
  export STORYKIT_ROOT="$T"
}

finish() {
  echo "$(basename "$0"): $PASS passed, $FAIL failed"
  [ "$FAIL" -eq 0 ]
}
