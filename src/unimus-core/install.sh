#!/bin/bash

# set workdir to the script dir
cd "$(dirname "$0")";

# import common installer functions
<source-replace|functions/functions.sh|source-replace>;

# override product specific functions
function post_download_task {
  # FIXME implement config file creation
  echo "ERROR: NOONE SHOULD EVER SEE THIS!!!";
}

function post_install_info {
  echo;
  echo '-------------------------------------------------------------------------------------';
  echo;
  echo 'The Core should now be installed and starting.';
  echo "You can check the Core status with 'tail -f /var/log/unimus-core/core.log'."; # FIXME is this correct?
  echo;
  echo "You should see the Core online in your Unimus 'Zones' menu soon.";
  echo;
  echo "If you need to change Core configuration, you can edit the '/etc/unimus/core.properties' file."; # FIXME is this correct?
  echo "(please don't forget to restart the core service after to apply the change)";
  echo;
}

# import Core specific installer data
<source-replace|unimus-core-data.sh|source-replace>;

# default installer behavior
interactive=1;
debug=0;

# save provided arguments
run_args=$@;

# run install script
main;
