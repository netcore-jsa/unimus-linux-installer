#!/bin/bash

# Version: 2019-03-02-01

# package manager commands
package_list_update_command='yum check-update';
package_check_available_command='yum info';
package_check_installed_command='yum list installed';
package_install_command='yum install %s -y';

# supported Java packages
java_package_install_list=( 'java-11-openjdk' 'java-1.8.0-openjdk' );

function add_java_package_repo {
  echo_no_java_supported_packages;
  exit 1;
}
