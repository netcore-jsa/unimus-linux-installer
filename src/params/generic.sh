#!/bin/bash

# Version: 2019-02-28-01

# Java version check and installation
java_install_counter=0;
java_version_check_command="java -version";
supported_java_regex='(?:1\.8\.0_(?:[5-9]\d|[1-9]\d\d+)|1\.8\.[1-9]\d*|1\.9|1\.\d\d+|\d{2,}\.\d+\.\d+)';

# other package dependencies
dependency_packages=( 'haveged' );

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
