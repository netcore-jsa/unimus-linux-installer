#!/bin/bash

# import common installer functions
<source-replace|functions/functions.sh|source-replace>;

# override product specific functions
function post_install_info {
  echo;
  echo '-------------------------------------------------------------------------------------';
  echo;
  echo 'Unimus should now be installed and starting.';
  echo 'Please note it can take up to 30 seconds for the web interface to start responding.';
  echo "If Unimus UI doesn't start, please check the '/var/log/unimus/unimus.log' log file.";
  echo;
  echo "You can visit 'http://your_server_ip:8085/' to reach the Unimus UI.";
  echo;
}

# import Unimus specific installer data
<source-replace|unimus-data.sh|source-replace>;

# default installer behavior
interactive=1;
debug=0;

# save provided arguments
run_args="$@";

# run install script
main;
