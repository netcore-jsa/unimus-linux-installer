#!/bin/bash

# Version: 2019-02-28-01

# Java version check and installation
java_version_check_command="java -version";
supported_java_regex='(?:1\.8\.0_(?:[5-9]\d|[1-9]\d\d+)|1\.8\.[1-9]\d*|1\.9|1\.\d\d+|\d{2,}\.\d+\.\d+)';
supported_java_found=0;
java_install_counter=0;

# init system used
is_systemd=0;

# other package dependencies
dependency_packages=( 'curl' 'haveged' 'ps' );

# echo supported Java not available message
function echo_no_java_supported_packages {
  echo 'It seems none of the supported Java packages were found.';
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

# supported Java packages
java_package_install_list='';

function add_java_package_repo {
  echo 'This function should be overridden by OS-specific params';
  echo 'If you are seeing this, something is wrong...';
  echo;
  exit 1;
}
