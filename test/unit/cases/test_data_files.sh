#!/bin/bash

# Tests that each product's *-data.sh defines the variables build.sh templates
# into the service/init files and that the installer relies on at runtime.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";

function check_data { # label  (expects the *-data.sh already sourced)
  local label="$1";

  # templated by build.sh into systemd/service and sysv/init
  assert_nonempty "${product_name}" "${label}: product_name set";
  assert_nonempty "${short_description}" "${label}: short_description set";
  assert_nonempty "${long_description}" "${label}: long_description set";
  assert_nonempty "${service_name}" "${label}: service_name set";
  assert_nonempty "${binary_path}" "${label}: binary_path set";

  # used by the installer at runtime
  assert_match "${binary_download_url}" '^https://' "${label}: binary_download_url is https";
  assert_nonempty "${config_file}" "${label}: config_file set";
  assert_nonempty "${log_file}" "${label}: log_file set";
}

# data files reuse the same variable names, so source one, assert, then the
# next overwrites - no isolation needed
source "${ROOT}/target/unimus/unimus-data.sh";
check_data "unimus-data";

source "${ROOT}/target/unimus-core/unimus-core-data.sh";
check_data "unimus-core-data";

unit_summary;
