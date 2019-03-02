#!/bin/bash

# Version: 2019-03-02-01

# package manager commands
package_list_update_command='apt-get update';
package_check_available_command='apt-cache show';
package_check_installed_command='dpkg -l';
package_install_command='apt-get install %s -y';

# supported Java packages
java_package_install_list=( 'openjdk-11-jre' 'openjdk-8-jre' );

# service management
service_autostart_add_command='update-rc.d %s defaults';
service_autostart_remove_command='update-rc.d -f %s remove';

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
  echo_java_repo_confirmation 'OpenJDK';

  # make sure we have 'add-apt-repository'
  $(printf "${package_install_command}" 'software-properties-common') &> /dev/null;

  # add OpenJDK repo
  add-apt-repository ppa:openjdk-r/ppa;

  echo 'Done, OpenJDK APT repo added to the system.';
  echo;
}

function add_debian_oracle_java_repo {
  echo_java_repo_confirmation 'Oracle Java';

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

  # add the Oracle Java repo
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu ${ubuntu_equivalent} main" > /etc/apt/sources.list.d/webupd8team-oracle-java.list;
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu ${ubuntu_equivalent} main " >> /etc/apt/sources.list.d/webupd8team-oracle-java.list;
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7B2C3B0889BF5709A105D03AC2518248EEA14886 &> /dev/null;

  echo 'Done, Oracle Java APT repo added to the system.';
  echo;
}

function echo_java_repo_confirmation {
  echo "You OS doesn't have the required Java version in its default APT repositories.";
  echo "Would you like the installer to add the latest ${1} APT repo to your system?";
  echo;
  echo 'Press ENTER to continue, or Ctrl+C to exit:';
  read -s;
  echo;
}
