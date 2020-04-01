#!/bin/bash

function post_install_info {
  echo;
  echo '-------------------------------------------------------------------------------------';
  echo;
  echo 'Unimus should now be installed and starting.';
  echo 'Please note it can take up to 30 seconds for the web interface to start responding.';
  echo "If Unimus UI doesn't start, please check the '${log_file}' log file.";
  echo;
  echo "You can visit 'http://your_server_ip:8085/' to reach the Unimus UI.";
  echo;
}
