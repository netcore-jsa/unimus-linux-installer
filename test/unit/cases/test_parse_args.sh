#!/bin/bash

# Tests parse_args: flag handling (-u/-d/-m) and the legacy run_args path.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";

cd "${ROOT}/target/unimus" || exit 1;
source ./functions.sh;

# install.sh sets these defaults before calling main/parse_args
function reset_defaults { interactive=1; debug=0; minimal=0; unset run_args; }

reset_defaults;
parse_args;
assert_eq 1 "${interactive}" "no flags: interactive stays 1";
assert_eq 0 "${debug}" "no flags: debug stays 0";
assert_eq 0 "${minimal}" "no flags: minimal stays 0";

reset_defaults;
parse_args -u;
assert_eq 0 "${interactive}" "-u: unattended sets interactive=0";

reset_defaults;
parse_args -d;
assert_eq 1 "${debug}" "-d: debug=1";

reset_defaults;
parse_args -m;
assert_eq 1 "${minimal}" "-m: minimal=1";

reset_defaults;
parse_args -u -d -m;
assert_eq 0 "${interactive}" "combined: interactive=0";
assert_eq 1 "${debug}" "combined: debug=1";
assert_eq 1 "${minimal}" "combined: minimal=1";

# legacy install.sh stored args in run_args and called parse_args with none
reset_defaults;
run_args=( -u -m );
parse_args;
assert_eq 0 "${interactive}" "legacy run_args: interactive=0";
assert_eq 1 "${minimal}" "legacy run_args: minimal=1";

unit_summary;
