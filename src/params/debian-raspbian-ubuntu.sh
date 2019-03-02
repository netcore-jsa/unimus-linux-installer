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
  echo "You OS doesn't have the required Java version in it's default APT repositories.";
  echo 'Would you like the installer to add the latest OpenJDK APT repo to your system?';
  echo;
  echo 'Press ENTER to continue, or Ctrl+C to exit:';

  case $os_release in
    *"Ubuntu"*)
      # make sure we have 'add-apt-repository'
      $(printf "${package_install_command}" 'add-apt-repository') &> /dev/null;

      # add OpenJDK repo
      add-apt-repository ppa:openjdk-r/ppa;
      ;;
    *"Debian"*)
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

      # add the OpenJDK PPA
      cat "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu ${ubuntu_equivalent} main" > /etc/apt/sources.list.d/openjdk-r.list;
      cat "deb-src http://ppa.launchpad.net/openjdk-r/ppa/ubuntu ${ubuntu_equivalent} main " >> /etc/apt/sources.list.d/openjdk-r.list;
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A  &> /dev/null;
      ;;
    *)
      echo_no_java_supported_packages;
      exit 1;;
  esac;

  echo;
  echo 'Done, OpenJDK APT repo added to the system.';
  echo;
}
