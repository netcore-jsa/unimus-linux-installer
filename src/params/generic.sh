#!/bin/bash

# Version: 2019-03-03-01

# OS release (will be populated during run-time)
os_release='';

# Java version check and installation
java_version_check_command="java -version";
supported_java_regex='(?:^| )(?:1\.8\.0[_\.][0-9]{3}|1\.8\.[1-9][0-9]*|8u[0-9]{3}|1\.9|1\.[0-9][0-9]+|[0-9]{2,}\.[0-9]+|[0-9]{2,}u[0-9]+)';
supported_java_found=0;
java_install_counter=0;

# init system used
is_systemd=0;

# other package dependencies
dependency_packages=( 'curl' 'haveged' 'procps' );

# echo supported Java not available message
function echo_no_java_supported_packages {
  echo 'ERROR: It seems none of the supported Java packages were found.';
  echo;
  echo 'This usually happens when you try to run the installer on an unsupported OS.'
  echo 'You can try to install Java 8 or newer manually and restart this installer.';
  echo;
  echo 'Alternatively, please contact us so we can add support for your OS.';
  echo;
}

#----------------------------------------------------------------#
# anything below this line should be overridden by per-OS params #
#----------------------------------------------------------------#

# package manager commands
package_list_update_command='';
package_check_available_command='';
package_check_installed_command='';
package_install_command='';
package_show_latest_version_command='';

# supported Java packages
java_package_install_list='';

# service management
service_autostart_add_command='';
service_autostart_remove_command='';

function add_java_package_repo {
  echo 'ERROR: This function should be overridden by OS-specific params.';
  echo 'If you are seeing this, something is wrong... please let us know about this.';
  echo;
  exit 1;
}
