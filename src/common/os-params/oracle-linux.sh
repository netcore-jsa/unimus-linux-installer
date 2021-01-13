#!/bin/bash

# package manager commands
package_list_update_command='yum check-update';
package_check_available_command='yum info';
package_check_installed_command='yum list installed';
package_install_command='yum install %s -y';
package_utility_quiet_suffix='-q';
package_show_latest_version_command="yum info %s | grep 'Version'";

# supported Java packages
java_package_install_list=( 'java-11-openjdk' 'java-1.8.0-openjdk' );

# service management
service_autostart_add_command='chkconfig %s on';
service_autostart_remove_command='chkconfig %s off';

# add EPEL repository
dependency_packages=( "${dependency_packages[@]}" );

# enable EPEL repo
function pre_dependency_install {
  debug "Enabling EPEL repos";
  local epel_package='';

  case $os_release in
    *"Oracle Linux Server 8"*)
      epel_package='oracle-epel-release-el8';
      ;;
    *"Oracle Linux Server 7"*)
      epel_package='oracle-epel-release-el7';
      ;;
    *)
      echo 'ERROR: It seems your Oracle Linux distribution is currently not supported by our installer.';
      echo 'If you are seeing this message, please let us know!';
      echo;
      exit 1;;
  esac;

  # confirm EPEL addition
  echo "The EPEL repo is required to install dependencies.";
  echo "Would you like the installer to add the EPEL repo to your system?";
  echo "(will use '${epel_package}')";
  echo;

  if [[ ${interactive} == 1 ]]; then
    echo 'Press ENTER to continue, or Ctrl+C to exit:';
    read -s;
    echo;
  fi;

  echo "Installing '${epel_package}'";
  local epel_install_command=$(printf "${package_install_command}" "${epel_package}");
  ${epel_install_command} ${package_utility_quiet_suffix};
}

function add_java_package_repo {
  echo_no_java_supported_packages;
  exit 1;
}
