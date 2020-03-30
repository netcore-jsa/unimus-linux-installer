#!/bin/bash

# Version: 2019-03-03-01

# package manager commands
package_list_update_command='apt-get update';
package_check_available_command='apt-cache show';
package_check_installed_command='dpkg -l';
package_install_command='apt-get install %s -y';
package_utility_quiet_suffix='-qq';
package_show_latest_version_command="apt-cache policy %s | grep 'Candidate'";

# supported Java packages
java_package_install_list=( 'openjdk-11-jre' 'openjdk-8-jre' );

# service management
service_autostart_add_command='update-rc.d %s defaults';
service_autostart_remove_command='update-rc.d -f %s remove';

# FIXME: add supported RPi version checking

function add_java_package_repo {
  case $os_release in
    *"Ubuntu"*)
      add_ubuntu_openjdk_ppa;;
    *"Debian"*|*"Raspbian"*)
      add_debian_oracle_java_repo;;
    *)
      echo_no_java_supported_packages;
      exit 1;;
  esac;
}

function add_ubuntu_openjdk_ppa {
  local apt_repo_file='/etc/apt/sources.list.d/openjdk-r.list';

  echo_java_repo_confirmation 'OpenJDK' "${apt_repo_file}";

  # make sure 'lsb_release' is available
  $(printf "${package_install_command}" 'lsb-release') &> /dev/null;

  # add the Oracle Java repo
  echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu $(lsb_release -cs) main" > ${apt_repo_file};
  echo "deb-src http://ppa.launchpad.net/openjdk-r/ppa/ubuntu $(lsb_release -cs) main " >> ${apt_repo_file};
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A &> /dev/null;

  echo 'Done, OpenJDK APT repo added to the system.';
  echo;
}

function add_debian_oracle_java_repo {
  local apt_repo_file='/etc/apt/sources.list.d/webupd8team-oracle-java.list';

  echo_java_repo_confirmation 'Oracle Java' "${apt_repo_file}";

  # find the Ubuntu equivalent to this Debian
  case $os_release in
    *"jessie"*)
      ubuntu_equivalent='trusty';;
    *"wheezy"*)
      ubuntu_equivalent='precise';;
    *)
      echo_no_java_supported_packages;
      exit 1;;
  esac;

  echo 'Adding Oracle Java APT repo to the system.';

  # add the Oracle Java repo
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu ${ubuntu_equivalent} main" > ${apt_repo_file};
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu ${ubuntu_equivalent} main " >> ${apt_repo_file};
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7B2C3B0889BF5709A105D03AC2518248EEA14886 &> /dev/null;

  # updated Java package install name for the Oracle Java package
  java_package_install_list=( 'oracle-java8-installer' );

  echo 'Done, Oracle Java APT repo added to the system.';
  echo;
}

function echo_java_repo_confirmation {
  echo "Your OS doesn't have the required Java version in its default APT repositories.";
  echo "Would you like the installer to add the latest ${1} APT repo to your system?";
  echo "(will use '${2}')";
  echo;
  echo 'Press ENTER to continue, or Ctrl+C to exit:';
  read -s;
  echo;
}
