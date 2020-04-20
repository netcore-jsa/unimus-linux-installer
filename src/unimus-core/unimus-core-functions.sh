#!/bin/bash

function post_download_task {
  if [[ -f "${config_file}" ]]; then
    # if config file already present, skip this
    return;
  else
    # make sure we have the config directory
    mkdir -p "$(dirname ${config_file})";
  fi;

  if [[ ${interactive} == 1 ]]; then
    default_server_port=5509;

    echo;
    echo '-------------------------------------------------------------------------------------';
    echo 'Unimus Core requires connection information for the Unimus Server this Core should connect to.';
    echo 'The installer will now generate the Unimus Core configuration file from you.';
    echo "(you can always change these setting later in the '${config_file}' config file)";
    echo;
    echo 'Please provide the requested information:';
    read -p 'Unimus Server address: ' server_address
    read -p "Unimus Server port (default ${default_server_port}): " server_port
    read -p 'Unimus Server access key: ' server_access_key

    # set default port if empty
    if [[ -z "${server_port// }" ]]; then
      server_port=${default_server_port};
    fi;

    # build config file
    echo '# Core config file' > ${config_file};
    echo >> ${config_file};
    echo >> ${config_file};
    echo '# Unimus server IP or hostname' >> ${config_file};
    echo "unimus.address = ${server_address}" >> ${config_file};
    echo >> ${config_file};
    echo '# Unimus server port' >> ${config_file};
    echo "unimus.port = ${server_port}" >> ${config_file};
    echo >> ${config_file};
    echo '# Access key used for connection authentication' >> ${config_file};
    echo "unimus.access.key = ${server_access_key}" >> ${config_file};
    echo >> ${config_file}
    echo '# Defines the number of maximum logging files, valid values are 2 ~ 2147483647' >> ${config_file};
    echo 'logging.file.count = 9' >> ${config_file};
    echo >> ${config_file}
    echo '# Defines each logging file size in MB, valid values are 1 ~ 2047' >> ${config_file};
    echo 'logging.file.size = 50' >> ${config_file};
  else
    start_after_install=0;
    echo;
    echo '-------------------------------------------------------------------------------------';
    echo 'IMPORTANT: Unimus Core service will not start due to unattended setup.';
    echo 'IMPORTANT: Please configure settings in '${config_file}' and start the service manually.';
    echo '-------------------------------------------------------------------------------------';
    echo;
  fi;
}

function post_install_info {
  echo;
  echo '-------------------------------------------------------------------------------------';
  echo;
  if [[ -f "${config_file}" || ${interactive} == 1 ]]; then
    echo 'The Core should now be installed and starting.';
    echo "You can check the Core status with 'tail -f ${log_file}'.";
    echo;
    echo "You should see the Core online in your Unimus 'Zones' screen soon.";
    echo;
  fi;
  echo -n "If you need to change Core configuration, you can edit the '${config_file}' file.";
  echo "(please don't forget to restart the core service after to apply the change)";
  echo;
}
