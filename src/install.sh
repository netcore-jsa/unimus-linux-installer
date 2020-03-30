#!/bin/bash

# Version: 2019-03-03-01

function main {
  # set workdir to the script dir
  cd "$(dirname "$0")";

  echo;

  # check if installer running as 'root'
  check_root;

  # import generic cross-OS parameters
  <source-replace|params/generic.sh|source-replace>;
  # get per-OS parameters
  get_os_parameters;

  # output installer info
  installer_info;

  # install dependencies
  package_list_update;
  install_dependencies;

  # install Java
  check_java;
  install_java;

  # before we deal with services, we need to know the init system
  check_if_systemd;

  # stop Unimus before upgrade / install
  stop_unimus_service;
  remove_unimus_autostart;

  # get Unimus
  download_unimus;
  download_unimus_support_files;

  # start Unimus after upgrade / install
  add_unimus_autostart;
  start_unimus_service;

  # post-install info
  post_install_info;
}

function debug {
  if [[ $debug == 1 ]]; then
    echo "DEBUG: ${1}";
  fi;
}

function check_root {
  # check if root
  local user=$(whoami);
  debug "Running as user '${user}'";

  if [[ $user != "root" ]]; then
    echo 'ERROR: This installer requires root privileges.';
    echo 'Please switch to root and run the installer again.';
    echo;
    exit 1;
  fi;
}

function get_os_parameters {
  # get OS release file
  os_release=$(cat /etc/*release);

  # import OS-specific parameters
  case $os_release in
    *"Amazon Linux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"CentOS"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"Debian"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|params/debian-raspbian-ubuntu.sh|source-replace>;
      ;;
    *"Raspbian"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|params/debian-raspbian-ubuntu.sh|source-replace>;
      ;;
    *"Red Hat Enterprise Linux"*)
      debug "Loading 'aws-centos-rhel.sh' parameters";
      <source-replace|params/aws-centos-rhel.sh|source-replace>;
      ;;
    *"Ubuntu"*)
      debug "Loading 'debian-raspbian-ubuntu.sh' parameters";
      <source-replace|params/debian-raspbian-ubuntu.sh|source-replace>;
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
  echo 'Welcome to the Unimus installer!';
  echo;
  echo 'This installer will perform the following steps:';
  echo '1) Install a compatible Java version (if not already present)';
  echo "2) Install dependencies [${dependency_packages[@]}] (if not already present)";
  echo '3) Install the latest version of Unimus';
  echo '4) Configure Unimus to start at boot';
  echo '5) Start Unimus';
  echo;
  echo 'If you are upgrading from a previous version, your current Unimus service will be stopped and restarted automatically.';
  echo;
  echo 'If you experience any issues with this installer, or have any questions, please contact us.';
  echo '(email, website live-chat, forums, create a support ticket, etc.)';
  echo;

  if [[ $unattended == 0 ]]; then
    echo 'Press ENTER to continue, or Ctrl+C to exit:';
    read -s;
    echo;
  fi

  echo '-----------------------------------------------------------------';
  echo;
}

function package_list_update {
  echo 'Updating list of available packages, this might take a while...';
  echo "(running '${package_list_update_command}' to refresh package indexes)";
  echo;
  ${package_list_update_command} ${package_utility_quiet_suffix} 2>&1;
}

function install_dependencies {
  for i in "${dependency_packages[@]}"; do
    if ! ${package_check_installed_command} $i &> /dev/null; then
      echo "Installing dependency package '${i}'";

      local dependency_install_command=$(printf "${package_install_command}" "${i}");
      ${dependency_install_command} ${package_utility_quiet_suffix} 2>&1;

      if [[ $? != 0 ]]; then
        echo "WARNING: installing package '${i}' failed!";
        echo 'Please install this package manually.';
        echo "(command: '${dependency_install_command}')";
        echo;
      fi;
    fi;
  done;

  echo 'Package dependencies installed, continuing...';
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
  if [[ $supported_java_found == 1 ]]; then
    return;
  fi;

  if [[ $java_install_counter == 0 ]]; then
    echo 'Supported Java version not found, will install...';
    echo;
  fi;

  local java_package_to_install='';

  # check if any of supported packages installable
  for i in "${java_package_install_list[@]}"; do
    debug "Checking if '${i}' package available";
    ${package_check_available_command} $i &> /dev/null;

    if [[ $? == 0 ]]; then
      # check if package version matches requirements
      if $(printf "${package_show_latest_version_command}" "${i}") |& grep -P "${supported_java_regex}" &> /dev/null; then
        debug "'${i}' package accepted for installation";
        java_package_to_install=$i;
        break;
      fi;
    fi;
  done;

  if [[ $java_package_to_install != '' ]]; then
    echo "Installing Java - '${java_package_to_install}'";
    echo 'This can take a considerable amount of time...';
    echo;

    local java_install_command=$(printf "${package_install_command}" "${java_package_to_install}");

    ${java_install_command} 2>&1;

    if [[ $? != 0 ]]; then
      echo;
      echo "ERROR: installing Java failed!";
      echo "Please try running '${java_install_command}' manually."
      echo;
      exit 1;
    fi;
  else
    if [[ $java_install_counter == 0 ]]; then
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

function check_if_systemd {
  if systemctl |& grep -- '-.mount' &> /dev/null; then
    debug "Detected systemd - YES";
    is_systemd=1;
  else
    debug "Detected systemd - NO";
    is_systemd=0;
  fi;
}

function stop_unimus_service {
  if [[ $is_systemd == 1 ]]; then
    if systemctl status unimus &> /dev/null; then
      echo 'The running Unimus service will now be stopped.';
      systemctl stop unimus &> /dev/null;
    fi;
  else
    if service unimus status &> /dev/null; then
      echo 'The running Unimus service will now be stopped.';
      service unimus stop &> /dev/null;
    fi;
  fi;
}

function remove_unimus_autostart {
  if [[ $is_systemd == 1 ]]; then
    echo 'Unimus service will now be removed from auto-start.';
    systemctl disable unimus &> /dev/null;
  else
    echo 'Unimus service will now be removed from auto-start.';
    $(printf "${service_autostart_remove_command}" "unimus") &> /dev/null;
  fi;
}

function download_unimus {
  echo;
  echo 'Downloading Unimus...';
  curl https://unimus.net/download/-%20Latest/Unimus.jar --create-dirs -o /opt/unimus/Unimus.jar 2>&1;
}

function download_unimus_support_files {
  echo;
  echo 'Downloading init/unit file...';
  if [[ $is_systemd == 1 ]]; then
    # for legacy reasons, make sure we don't have an init script even when running systemd
    rm /etc/init.d/unimus &> /dev/null;

    <get-replace|systemd/unimus.service|/etc/systemd/system/unimus.service|get-replace>;
    systemctl daemon-reload &> /dev/null;
  else
    <get-replace|sysv/init|/etc/init.d/unimus|get-replace>;
    chmod +x /etc/init.d/unimus 2>&1;
  fi;

  # create basic settings file (if not already present)
  if [ ! -f /etc/default/unimus ]; then
    echo "-Xms256M -Xmx768M -Djava.security.egd=file:/dev/./urandom" > /etc/default/unimus;
  fi;
}

function add_unimus_autostart {
# register Unimus service auto-start
  echo;
  echo 'Configuring Unimus service to auto-start...';
  if [[ $is_systemd == 1 ]]; then
    systemctl enable unimus &> /dev/null;
  else
    $(printf "${service_autostart_add_command}" "unimus") &> /dev/null;
  fi;
}

function start_unimus_service {
  # start Unimus service
  echo 'Starting the Unimus service...';
  if [[ $is_systemd == 1 ]]; then
    systemctl start unimus 2>&1;
  else
    service unimus start 2>&1;
  fi;
}

function post_install_info {
  echo;
  echo '-------------------------------------------------------------------------------------';
  echo;
  echo 'Unimus should now be installed and starting.'
  echo 'Please note it can take up to 30 seconds for the web interface to start responding.'
  echo "If Unimus UI doesn't start, please check the '/var/log/unimus/unimus.log' log file.";
  echo;
  echo "You can visit 'http://your_server_ip:8085/' to reach the Unimus UI.";
  echo;
}

# script entry point
unattended=0;
debug=0;

if [[ ! -z "$1" ]]; then
  if [[ "$1" == "true" || "$1" == "1" ]]; then
    unattended=1;
  fi;
fi;

if [[ ! -z "$2" ]]; then
  if [[ "$2" == "true" || "$2" == "1" ]]; then
    debug=1;
  fi;
fi;

main;
