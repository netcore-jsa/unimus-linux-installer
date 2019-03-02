#!/bin/bash

# Version: 2019-03-02-01

# package manager commands
package_list_update_command='apt-get update';
package_check_available_command='apt-get show';
package_check_installed_command='dpkg -l';
package_install_command='apt-get install %s -y';

# supported Java packages
java_package_install_list=( 'openjdk-11-jre' 'openjdk-8-jre' );

function add_java_package_repo {
  # FIXME
}
