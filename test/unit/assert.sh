#!/bin/bash

# Minimal, dependency-free assertion library for the non-docker installer
# unit tests. Each assert increments a pass/fail counter and prints a
# TAP-ish line; call 'unit_summary' at the end of a test file to report and
# set the exit status. Asserts never abort the file, so all checks run.

UNIT_PASS=0;
UNIT_FAIL=0;
LAST_OUTPUT='';

function _pass {
  UNIT_PASS=$((UNIT_PASS + 1));
  printf '  ok   - %s\n' "$1";
}

function _fail {
  UNIT_FAIL=$((UNIT_FAIL + 1));
  printf '  FAIL - %s\n' "$1";
  if [[ -n "$2" ]]; then
    printf '         %s\n' "$2";
  fi;
}

function assert_eq { # expected actual desc
  if [[ "$1" == "$2" ]]; then _pass "$3"; else _fail "$3" "expected [$1] got [$2]"; fi;
}

function assert_contains { # haystack needle desc
  if [[ "$1" == *"$2"* ]]; then _pass "$3"; else _fail "$3" "[$2] not found in [$1]"; fi;
}

function assert_not_contains { # haystack needle desc
  if [[ "$1" != *"$2"* ]]; then _pass "$3"; else _fail "$3" "[$2] unexpectedly found in [$1]"; fi;
}

function assert_nonempty { # value desc
  if [[ -n "$1" ]]; then _pass "$2"; else _fail "$2" "value was empty"; fi;
}

function assert_match { # string regex desc  (PCRE, matches if any line matches)
  if printf '%s' "$1" | grep -qP -- "$2"; then _pass "$3"; else _fail "$3" "[$1] did not match /$2/"; fi;
}

function assert_no_match { # string regex desc
  if printf '%s' "$1" | grep -qP -- "$2"; then _fail "$3" "[$1] unexpectedly matched /$2/"; else _pass "$3"; fi;
}

function assert_func { # function_name desc
  if declare -F "$1" > /dev/null; then _pass "$2"; else _fail "$2" "function '$1' not defined"; fi;
}

function assert_file { # path desc
  if [[ -f "$1" ]]; then _pass "$2"; else _fail "$2" "file '$1' missing"; fi;
}

function assert_executable { # path desc
  if [[ -x "$1" ]]; then _pass "$2"; else _fail "$2" "file '$1' not executable"; fi;
}

# Runs a command in a subshell (so a callee that calls 'exit' can't kill the
# test run) and asserts its exit code. Combined output is stored in
# LAST_OUTPUT for optional follow-up assertions.
function assert_exit { # expected_code desc cmd...
  local expected="$1" desc="$2";
  shift 2;
  LAST_OUTPUT="$("$@" 2>&1)";
  local code=$?;
  if [[ "${code}" == "${expected}" ]]; then _pass "${desc}"; else _fail "${desc}" "expected exit ${expected} got ${code}"; fi;
}

function unit_summary {
  printf '\n%d passed, %d failed\n' "${UNIT_PASS}" "${UNIT_FAIL}";
  # machine-readable line consumed by run-tests.sh
  printf 'SUMMARY %d %d\n' "${UNIT_PASS}" "${UNIT_FAIL}";
  [[ "${UNIT_FAIL}" -eq 0 ]];
}
