#!/bin/bash

# Tests that each os-params file fulfils the contract declared in generic.sh:
# it must set the package-manager commands, a non-empty Java package list,
# the service autostart commands, and define add_java_package_repo.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";

cd "${ROOT}/target/unimus" || exit 1;

# re-source generic before each os-params file to reset the contract vars
function load_params {
  source ./os-params/generic.sh;
  local p;
  for p in "$@"; do source "./os-params/${p}"; done;
}

function check_contract { # label
  local label="$1";
  assert_nonempty "${package_list_update_command}" "${label}: package_list_update_command set";
  assert_nonempty "${package_check_available_command}" "${label}: package_check_available_command set";
  assert_nonempty "${package_check_installed_command}" "${label}: package_check_installed_command set";
  assert_contains "${package_install_command}" '%s' "${label}: package_install_command has %s";
  assert_contains "${package_show_latest_version_command}" '%s' "${label}: package_show_latest_version_command has %s";
  assert_contains "${service_autostart_add_command}" '%s' "${label}: service_autostart_add_command has %s";
  assert_contains "${service_autostart_remove_command}" '%s' "${label}: service_autostart_remove_command has %s";
  assert_nonempty "${java_package_install_list[*]}" "${label}: java_package_install_list non-empty";
  assert_func add_java_package_repo "${label}: add_java_package_repo defined";
}

load_params aws-centos-rhel.sh;
check_contract "aws-centos-rhel";

load_params debian-raspbian-ubuntu.sh;
check_contract "debian-raspbian-ubuntu";

load_params oracle-linux.sh;
check_contract "oracle-linux";

# aws.sh is supplemental (sourced after aws-centos-rhel for Amazon Linux)
load_params aws-centos-rhel.sh aws.sh;
check_contract "amazon (aws-centos-rhel + aws)";

unit_summary;
