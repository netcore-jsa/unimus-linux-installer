#!/bin/bash

function main {
  # set installer behavior
  parse_args;

  # set installer type
  if [[ ${minimal} == 1 ]]; then
    minimal_upgrade;
  else
    standard_installation;
  fi;
}

function minimal_upgrade {
  # check if installer running as 'root'
  check_root;
  check_existing_installation;

  # import generic cross-OS and specific per-OS parameters
  get_generic_parameters;
  get_per_os_parameters;

  # output installer info
  installer_info;

  # before we deal with services, we need to know the init system
  check_if_systemd;

  # install Java
  check_java;

  # stop application before upgrade / install
  stop_application_service;

  # get application binary & support files
  download_application_binary;

  # post application download task
  post_download_task;

  # start application after upgrade / install
  start_application_service;

  # post-install info
  post_install_info;
}

function standard_installation {
  # check if installer running as 'root'
  check_root;

  # import generic cross-OS and specific per-OS parameters
  get_generic_parameters;
  get_per_os_parameters;

  # output installer info
  installer_info;

  # before we deal with services, we need to know the init system
  check_if_systemd;

  # install dependencies
  package_list_update;
  install_dependencies;

  # install Java
  check_java;
  install_java;

  # stop application before upgrade / install
  stop_application_service;
  remove_application_autostart;

  # get application binary & support files
  download_application_binary;
  download_application_support_files;

  # post application download task
  post_download_task;

  # start application after upgrade / install
  add_application_autostart;
  start_application_service;

  # post-install info
  post_install_info;
}

function debug {
  if [[ ${debug} == 1 ]]; then
    echo "DEBUG: ${1}";
  fi;
}

function parse_args {
  for i in "${run_args[@]}"; do
    case ${i} in
      "-d") # debug mode
        debug=1;;
      "-u") # unattended mode
        interactive=0;;
      "-m") # minimal upgrade mode
      	minimal=1;;
    esac;
  done;

  debug "debug='${debug}', interactive='${interactive}', minimal='${minimal}'";
}

function check_root {
  # check if root
  local user=$(whoami);
  debug "Running as user '${user}'";

  if [[ ${user} != "root" ]]; then
    echo;
    echo 'ERROR: This installer requires root privileges.';
    echo 'Please switch to root and run the installer again.';
    echo;
    exit 1;
  fi;
}

function check_existing_installation {
  # check existing installation if -m argument (minimal upgrade) is detected
  if [[ ! -f "${binary_path}" ]]; then
      echo 'ERROR: We are sorry, but a minimal upgrade can be run only on existing installations.';
      echo "Remove \"-m\" argument to run a full installation/upgrade of ${product_name}.";
      exit 1;
  fi;
}

function get_generic_parameters {
  <source-replace|os-params/generic.sh|source-replace>;
}

function get_per_os_parameters {
  # get OS release file
  os_release=$(cat /etc/*release);

  # import OS-specific parameters
  case $os_release in
    *"AlmaLinux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|os-params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"Amazon Linux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|os-params/aws-centos-rhel.sh|source-replace>;

      debug "Loading 'aws.sh' parameters";
      <source-replace|os-params/aws.sh|source-replace>;
      ;;
    *"CentOS"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|os-params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"Debian"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|os-params/debian-raspbian-ubuntu.sh|source-replace>;
      ;;
    *"Raspbian"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|os-params/debian-raspbian-ubuntu.sh|source-replace>;
      ;;
    *"Oracle Linux"*)
      debug "Loading 'oracle-linux.sh' parameters";
      <source-replace|os-params/oracle-linux.sh|source-replace>;
      ;;
    *"Red Hat Enterprise Linux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|os-params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"Rocky Linux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|os-params/aws-centos-rhel.sh|source-replace>;
      ;;  
    *"Ubuntu"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|os-params/debian-raspbian-ubuntu.sh|source-replace>;
      ;;
    *)
      echo "ERROR: We are sorry, but the installer currently doesn't support your OS.";
      echo 'Please check our wiki for generic Linux / Unix / Mac install instructions.';
      echo;
      exit 1;
      ;;
  esac;
}

function installer_info {
  # inform the user what this installer will do
  echo;
  echo "Welcome to the ${product_name} installer!";
  echo;

  if [[ ${minimal} == 1 ]]; then
    echo "Minimal upgrade mode detected. This installer will only deploy the latest version of ${product_name} and will not change any existing configuration.";
  else
    echo 'This installer will perform the following steps:';
    echo '1) Install a compatible Java version (if not already present)';
    echo "2) Install dependencies [${dependency_packages[*]}] (if not already present)";
    echo "3) Install the latest version of ${product_name}";
    echo "4) Configure ${product_name} to start at boot";
    echo "5) Start ${product_name}";
  fi;

  echo;
  echo "If you are upgrading from a previous version, your current ${product_name} service will be stopped and restarted automatically.";
  echo;
  echo 'If you experience any issues with this installer, or have any questions, please contact us.';
  echo '(email, website live-chat, forums, create a support ticket, etc.)';
  echo;

  if [[ ${interactive} == 1 ]]; then
    echo 'Press ENTER to continue, or Ctrl+C to exit:';
    read -s;
    echo;
  fi;

  echo '-----------------------------------------------------------------';
  echo;
}

function check_if_systemd {
  if systemctl |& grep -- '-.mount' &> /dev/null; then
    debug "Detected systemd - YES";
    is_systemd=1;
  else
    debug "Detected systemd - NO";
    is_systemd=0;
  fi;
}

function package_list_update {
  echo 'Updating list of available packages, this might take a while...';
  echo "(running '${package_list_update_command}' to refresh package indexes)";
  echo;
  ${package_list_update_command} ${package_utility_quiet_suffix};
  echo;
}

function install_dependencies {
  # run pre install tasks
  pre_dependency_install;

  for i in "${dependency_packages[@]}"; do
    if ! ${package_check_installed_command} $i &> /dev/null; then
      echo "Installing dependency package '${i}'";

      local dependency_install_command=$(printf "${package_install_command}" "${i}");
      ${dependency_install_command} ${package_utility_quiet_suffix};

      if [[ $? != 0 ]]; then
        echo "WARNING: installing package '${i}' failed!";
        echo 'Please install this package manually.';
        echo "(command: '${dependency_install_command}')";
        echo;
      fi;
    fi;
  done;

  # run post install tasks
  post_dependency_install;

  echo 'Package dependencies installed, continuing...';
  echo;
}

function check_java {
  echo 'Checking if supported Java installed...'
  if type java &> /dev/null; then
    if ${java_version_check_command} |& grep -P "${supported_java_regex}" &> /dev/null; then
      echo 'Supported Java version found, continuing...'
      supported_java_found=1;
      return;
    fi;
  fi;

  supported_java_found=0;
}

function install_java {
  if [[ ${supported_java_found} == 1 ]]; then
    return;
  fi;

  if [[ ${java_install_counter} == 0 ]]; then
    echo 'Supported Java version not found, will install Java...';
    echo;
  fi;

  local java_package_to_install='';

  # check if any of supported packages installable
  for i in "${java_package_install_list[@]}"; do
    debug "Checking if '${i}' package available";
    local package_available=$(${package_check_available_command} $i 2>&1);

    if [[ $? == 0 ]] && [[ "$package_available" != *"No packages found"* ]]; then
      # check if package version matches requirements
      debug "'${i}' package available, validating version requirements";
      if $(printf "${package_show_latest_version_command}" "${i}") |& grep -P "${supported_java_regex}" &> /dev/null; then
        debug "'${i}' package accepted for installation";
        java_package_to_install=$i;
        break;
      fi;
    else
      debug "'${i}' package not available for installation";
    fi;
  done;

  if [[ ${java_package_to_install} != '' ]]; then
    echo "Installing Java - '${java_package_to_install}'";
    echo 'This can take a considerable amount of time...';
    echo;

    local java_install_command=$(printf "${package_install_command}" "${java_package_to_install}");

    ${java_install_command} ${package_utility_quiet_suffix};

    if [[ $? != 0 ]]; then
      echo;
      echo "ERROR: installing Java failed!";
      echo "Please try running '${java_install_command}' manually."
      echo;
      exit 1;
    fi;
  else
    if [[ ${java_install_counter} == 0 ]]; then
      # add OpenJDK APT repo
      add_java_package_repo;
      ((java_install_counter++));

      # call this function again to install Java from the new repo
      install_java;
    else
      # if this is the 2nd time we got here, packages are not even in OpenJDK APT repo
      echo_no_java_supported_packages;
      exit 1;
    fi;
  fi;
}

function stop_application_service {
  if [[ ${is_systemd} == 1 ]]; then
    if systemctl status ${service_name} &> /dev/null; then
      echo "The running ${product_name} service will now be stopped.";
      systemctl stop ${service_name} &> /dev/null;
    fi;
  else
    if service ${service_name} status &> /dev/null; then
      echo "The running ${product_name} service will now be stopped.";
      service ${service_name} stop &> /dev/null;
    fi;
  fi;
}

function remove_application_autostart {
  if [[ ${is_systemd} == 1 ]]; then
    echo "${product_name} service will now be removed from auto-start.";
    systemctl disable ${service_name} &> /dev/null;
  else
    echo "${product_name} service will now be removed from auto-start.";
    $(printf "${service_autostart_remove_command}" "${service_name}") &> /dev/null;
  fi;
}

function download_application_binary {
  echo;
  echo "Downloading ${product_name}...";
  curl -L ${binary_download_url} --create-dirs -o ${binary_path};
}

function download_application_support_files {
  echo;
  echo 'Downloading init/unit file...';
  if [[ ${is_systemd} == 1 ]]; then
    # for legacy reasons, make sure we don't have an init script even when running systemd
    rm /etc/init.d/${service_name} &> /dev/null;

    <get-replace|systemd/service|/etc/systemd/system/${service_name}.service|get-replace>;
    systemctl daemon-reload &> /dev/null;
  else
    <get-replace|sysv/init|/etc/init.d/${service_name}|get-replace>;
    chmod +x /etc/init.d/${service_name};
  fi;

  # create basic settings file (if not already present)
  if [[ ! -f "/etc/default/${service_name}" ]]; then
    echo "-Xms256M -Xmx768M -Djava.security.egd=file:/dev/./urandom" > /etc/default/${service_name};
  fi;
}

function post_download_task {
  debug "Default empty post download task";
}

function add_application_autostart {
  # register application service auto-start
  echo;
  echo "Configuring ${product_name} service to auto-start after boot...";
  if [[ ${is_systemd} == 1 ]]; then
    systemctl enable ${service_name} &> /dev/null;
  else
    $(printf "${service_autostart_add_command}" "${service_name}") &> /dev/null;
  fi;
}

function start_application_service {
  if [[ ${start_after_install} == 1 ]]; then
    # start application service
    echo "Starting the ${product_name} service...";
    if [[ ${is_systemd} == 1 ]]; then
      systemctl start ${service_name};
    else
      service ${service_name} start;
    fi;
  fi;
}
