#!/bin/bash

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

# add https transport for APT
dependency_packages+=( 'apt-transport-https' );

function add_java_package_repo {
  case $os_release in
    *"Ubuntu"*)
      add_ubuntu_openjdk_ppa;;
    *"Debian"*|*"Raspbian"*)
      add_debian_backports;;
    *)
      echo_no_java_supported_packages;
      exit 1;;
  esac;

  package_list_update;
}

function add_ubuntu_openjdk_ppa {
  local openjdk_apt_repo_file='/etc/apt/sources.list.d/openjdk-r.list';

  # make sure 'lsb_release' is available, it should be default be on all Debian-based systems
  $(printf "${package_install_command}" 'lsb-release') &> /dev/null;

  # confirm repo addition
  echo "Your OS doesn't have the required Java version in it's default APT repositories.";
  echo "Would you like the installer to add the OpenJDK APT repo to your system?";
  echo "(will use '${openjdk_apt_repo_file}')";
  echo;

  if [[ $interactive == 1 ]]; then
    echo 'Press ENTER to continue, or Ctrl+C to exit:';
    read -s;
    echo;
  fi;

  debug "Adding OpenJDK repo, '$(lsb_release -cs)', '${openjdk_apt_repo_file}'";

  # add the openjdk-r ppa
  echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu $(lsb_release -cs) main" > ${openjdk_apt_repo_file};
  echo "deb-src http://ppa.launchpad.net/openjdk-r/ppa/ubuntu $(lsb_release -cs) main " >> ${openjdk_apt_repo_file};
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A &> /dev/null;

  echo 'Done, OpenJDK APT repo added to the system.';
  echo;
}

function add_debian_backports {
  case $os_release in
    *"jessie"*)
      os_name='jessie';;
    *)
      echo_no_java_supported_packages;
      exit 1;;
  esac;

  local backports_repo_file="/etc/apt/sources.list.d/${os_name}-backports.list";

  # confirm backports addition
  echo "Your OS doesn't have the required Java version in it's default APT repositories.";
  echo "Would you like the installer to add the 'backports' APT repo to your system?";
  echo "(will use '${backports_repo_file}')";
  echo;

  if [[ $interactive == 1 ]]; then
    echo 'Press ENTER to continue, or Ctrl+C to exit:';
    read -s;
    echo;
  fi;

  debug "Adding 'backports' repo, '${os_name}', '${backports_repo_file}'";

  # add the backports repo
  echo "deb http://archive.debian.org/debian ${os_name}-backports main" > ${backports_repo_file};
  echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/10-nocheckvalid;
  echo -e "Package: ca-certificates-java\nPin: origin \"archive.debian.org\"\nPin-Priority: 500" > /etc/apt/preferences.d/10-archive-pin;

  echo "Done, 'backports' APT repo added to the system.";
  echo;
}
