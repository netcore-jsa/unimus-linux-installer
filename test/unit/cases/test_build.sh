#!/bin/bash

# Tests build.sh assembly: placeholder substitution, service/init templating,
# the test/prod profile differences, and executable bits.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";
cd "${ROOT}" || exit 1;

# the runner has already assembled the test profile

# --- test profile: outputs exist ---
assert_file "target/unimus/install.sh" "test: unimus install.sh assembled";
assert_file "target/unimus-core/install.sh" "test: unimus-core install.sh assembled";
assert_file "target/unimus/functions.sh" "test: shared functions.sh copied";
assert_file "target/unimus/os-params/generic.sh" "test: os-params copied";

# --- no leftover placeholders anywhere in target/ ---
leftovers="$(grep -rEl '<source-replace\||<get-replace\||<\|[a-z_]+\|>' target/ 2>/dev/null)";
assert_eq "" "${leftovers}" "test: no leftover placeholders in target/";

# --- test profile uses local source/get (cat / cp) ---
fn_test="$(cat target/unimus/functions.sh)";
assert_contains "${fn_test}" "source <(cat ./os-params/generic.sh)" "test: source-replace -> local cat";
assert_contains "${fn_test}" "cp " "test: get-replace -> cp";

# --- systemd unit templating (<|var|> -> data values) ---
svc="$(cat target/unimus/systemd/service)";
assert_contains "${svc}" "Description=Unimus Server" "test: systemd short_description filled";
assert_contains "${svc}" "/opt/unimus/Unimus.jar" "test: systemd binary_path filled";
assert_contains "${svc}" "WorkingDirectory=/opt/unimus" "test: systemd service_name filled";
assert_not_contains "${svc}" "<|" "test: no token left in systemd unit";

# --- sysv init templating ---
ini="$(cat target/unimus-core/sysv/init)";
assert_contains "${ini}" 'APP_JAR="/opt/unimus-core/Unimus-Core.jar"' "test: sysv binary_path filled";
assert_contains "${ini}" "Unimus Core" "test: sysv product_name filled";
assert_not_contains "${ini}" "<|" "test: no token left in sysv init";

# --- test profile makes scripts executable ---
assert_executable "target/unimus/install.sh" "test: install.sh is executable";

# --- prod profile: remote source/get + hardened curl ---
./build.sh prod > /dev/null 2>&1;
fn_prod="$(cat target/unimus/functions.sh)";
assert_contains "${fn_prod}" "download.unimus.net" "prod: source-replace -> CDN URL";
assert_contains "${fn_prod}" "curl -fL '" "prod: get-replace uses 'curl -fL'";
prod_leftovers="$(grep -rEl '<source-replace\||<get-replace\||<\|[a-z_]+\|>' target/ 2>/dev/null)";
assert_eq "" "${prod_leftovers}" "prod: no leftover placeholders in target/";

# restore a test profile for the next case (runner also does this)
./build.sh test > /dev/null 2>&1;

unit_summary;
