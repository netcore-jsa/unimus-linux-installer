#!/bin/bash

# Non-docker unit test runner for the installer.
#
# Unlike test/run-test-container.sh (which performs real installs inside
# distro containers), this suite exercises the installer's bash logic in
# isolation: build/assembly, argument parsing, the Java-version regex, the
# os-params contracts, and OS detection / repo routing (with mocked package
# managers). It needs only bash - no docker, no root, no network.
#
# Usage: ./test/unit/run-tests.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../.." && pwd)";
cd "${ROOT}" || exit 1;

total_pass=0;
total_fail=0;
files_failed=0;

echo 'Assembling test profile for unit tests...';
if ! ./build.sh test > /dev/null 2>&1; then
  echo 'ERROR: ./build.sh test failed; cannot run unit tests';
  exit 1;
fi;

for f in "${DIR}"/cases/test_*.sh; do
  echo;
  echo "=== $(basename "${f}") ===";

  # rebuild a clean test profile before each case so a case that re-runs
  # build.sh (e.g. test_build.sh exercising the prod profile) can't affect
  # the others
  ./build.sh test > /dev/null 2>&1;

  out="$(bash "${f}" 2>&1)";
  status=$?;

  # print everything except the machine-readable SUMMARY line
  echo "${out}" | grep -v '^SUMMARY ';

  read p fail < <(echo "${out}" | sed -n 's/^SUMMARY //p');
  total_pass=$((total_pass + ${p:-0}));
  total_fail=$((total_fail + ${fail:-0}));

  if [[ ${status} -ne 0 ]]; then
    files_failed=$((files_failed + 1));
  fi;
done;

# leave a clean test build behind
./build.sh test > /dev/null 2>&1;

echo;
echo '==================================';
echo "TOTAL: ${total_pass} passed, ${total_fail} failed";
echo '==================================';

if [[ ${total_fail} -eq 0 && ${files_failed} -eq 0 ]]; then
  exit 0;
else
  exit 1;
fi;
