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
dependency_packages=( "epel-release" "${dependency_packages[@]}" );

function add_java_package_repo {
  echo_no_java_supported_packages;
  exit 1;
}
