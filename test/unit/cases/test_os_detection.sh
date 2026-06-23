#!/bin/bash

# Tests get_per_os_parameters OS detection and the per-OS repo/Java routing,
# by mocking the /etc/*release read (via a 'cat' shim) and the package
# managers. This is where the AlmaLinux-2-vs-2023 substring trap, the EL10
# Java list, the Oracle Linux 10 EPEL branch and the Debian trixie routing
# are guarded.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
ROOT="$(cd "${DIR}/../../.." && pwd)";
source "${DIR}/../assert.sh";

cd "${ROOT}/target/unimus";
source ./functions.sh;

# Intercept only the `cat /etc/*release` read; every other cat (e.g. the
# `source <(cat ./os-params/x.sh)` assembly) falls through to the real cat,
# because os-params paths do not contain "release".
function cat {
  case "$*" in
    *release*) printf '%s\n' "${MOCK_OS_RELEASE}" ;;
    *) command cat "$@" ;;
  esac;
}

# Load generic + per-OS params for a given mocked release string.
function load_for {
  MOCK_OS_RELEASE="$1";
  package_install_command='';
  java_package_install_list=();
  dependency_packages=();
  get_generic_parameters;
  get_per_os_parameters;
}

# --- package manager selection per family ---
load_for "AlmaLinux release 10.0 (Purple Lion)";
assert_contains "${package_install_command}" "yum" "AlmaLinux 10 -> yum";
assert_contains " ${java_package_install_list[*]} " " java-17-openjdk " "EL10 family has openjdk 17 in list";

load_for "Rocky Linux release 10.0 (Red Quartz)";
assert_contains "${package_install_command}" "yum" "Rocky 10 -> yum";

load_for "Red Hat Enterprise Linux release 10.0 (Coughlan)";
assert_contains "${package_install_command}" "yum" "RHEL 10 -> yum";

load_for "CentOS Stream release 10";
assert_contains "${package_install_command}" "yum" "CentOS Stream 10 -> yum";

load_for "Ubuntu 26.04 LTS";
assert_contains "${package_install_command}" "apt-get" "Ubuntu 26.04 -> apt-get";

load_for "Debian GNU/Linux 13 (trixie)";
assert_contains "${package_install_command}" "apt-get" "Debian 13 -> apt-get";

# --- Oracle Linux loads oracle-linux.sh (java-17 first), not aws-centos-rhel ---
load_for "Oracle Linux Server 10.0";
assert_contains "${package_install_command}" "yum" "Oracle Linux 10 -> yum";
assert_eq "java-17-openjdk" "${java_package_install_list[0]}" "Oracle Linux uses oracle-linux.sh java list";

# --- Amazon Linux 2023: Corretto, and NOT the 'Amazon Linux 2' fallback ---
load_for "Amazon Linux 2023.5.20240730";
assert_eq "java-17-amazon-corretto" "${java_package_install_list[0]}" "AL2023 -> Corretto java list";
assert_not_contains " ${dependency_packages[*]} " " epel-release " "AL2023 deps drop epel-release";
assert_not_contains " ${dependency_packages[*]} " " haveged " "AL2023 deps drop haveged";

# --- Amazon Linux 2: keeps openjdk + epel-release (distinct from 2023) ---
load_for "Amazon Linux 2";
assert_eq "java-11-openjdk" "${java_package_install_list[0]}" "AL2 keeps openjdk java list";
assert_contains " ${dependency_packages[*]} " " epel-release " "AL2 deps include epel-release";

# --- unsupported OS exits 1 ---
MOCK_OS_RELEASE="Gentoo Base System release 2.15";
assert_exit 1 "unsupported OS exits 1" get_per_os_parameters;

# ============================================================
# Repo-routing behaviour with mocked package managers
# ============================================================

# Oracle Linux 10 enables the el10 EPEL package
load_for "Oracle Linux Server 10.0";
interactive=0;
YUM_LOG='';
function yum { YUM_LOG+="install $* | "; }
pre_dependency_install;
assert_contains "${YUM_LOG}" "oracle-epel-release-el10" "OL10 pre-install enables el10 EPEL";

load_for "Oracle Linux Server 9.3";
YUM_LOG='';
pre_dependency_install;
assert_contains "${YUM_LOG}" "oracle-epel-release-el9" "OL9 pre-install enables el9 EPEL";

# Amazon Linux 2023 pre-install adds NO EPEL (substring guard); AL2 does
load_for "Amazon Linux 2023.5.20240730";
YUM_LOG='';
function yum { YUM_LOG+="$* | "; }
pre_dependency_install;
assert_not_contains "${YUM_LOG}" "epel" "AL2023 pre-install adds no EPEL rpm";

load_for "Amazon Linux 2";
YUM_LOG='';
pre_dependency_install;
assert_contains "${YUM_LOG}" "epel-release-latest-7" "AL2 pre-install adds EL7 EPEL rpm";

# Debian repo routing: trixie + bookworm -> Adoptium, jessie -> backports,
# stretch (no path) -> error exit.
# NB: load_for re-sources the debian os-params, which redefines the repo
# helper functions - so the mocks must be (re)defined AFTER each load_for.
function package_list_update { :; }    # defined in functions.sh, not re-sourced

load_for "Debian GNU/Linux 13 (trixie)";
ADOPTIUM=0; function add_adoptium_repos { ADOPTIUM=1; }
add_java_package_repo;
assert_eq 1 "${ADOPTIUM}" "Debian trixie -> Adoptium repo";

load_for "Debian GNU/Linux 12 (bookworm)";
ADOPTIUM=0; function add_adoptium_repos { ADOPTIUM=1; }
add_java_package_repo;
assert_eq 1 "${ADOPTIUM}" "Debian bookworm -> Adoptium repo";

load_for "Debian GNU/Linux 8 (jessie)";
BACKPORTS=0; function add_debian_backports { BACKPORTS=1; }
add_java_package_repo;
assert_eq 1 "${BACKPORTS}" "Debian jessie -> backports repo";

load_for "Debian GNU/Linux 9 (stretch)";
assert_exit 1 "Debian stretch has no java repo path -> exit 1" add_java_package_repo;

unit_summary;
