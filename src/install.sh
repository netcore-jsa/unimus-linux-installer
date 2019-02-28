#!/bin/bash

# Version: 2019-02-28-01

# set workdir to the script dir
cd "$(dirname "$0")"

echo;

# check if root
user=$(whoami);
if [[ $user != "root" ]]; then
    echo 'This installer requires root privileges.';
    echo 'Please switch to root and run the installer again.';
    echo;
    exit 1;
fi;

# import generic cross-OS parameters
<run-replace|params/generic.sh|run-replace>;

# get OS release file
release=$(cat /etc/*release)

# import OS-specific parameters
case $release in 
  *"Amazon Linux"*)
    <run-replace|params/aws-centos-rhel.sh|run-replace>;;
  *"CentOS"*)
    <run-replace|params/aws-centos-rhel.sh|run-replace>;;
  *"Debian"*)
    <run-replace|params/debian-raspbian-ubuntu.sh|run-replace>;;
  *"Raspbian"*)
    <run-replace|params/debian-raspbian-ubuntu.sh|run-replace>;;
  *"Red Hat Enterprise Linux"*)
    <run-replace|params/aws-centos-rhel.sh|run-replace>;;
  *"Ubuntu"*)
    <run-replace|params/debian-raspbian-ubuntu.sh|run-replace>;;

  *)
    echo "We are sorry, but the installer currently doesn't support your OS.";
    echo 'Please check our wiki for generic Linux / Unix / Mac install instructions.';
    echo;
    exit 1;
    ;;
esac

# inform the user what this installer will do
echo 'Welcome to the Unimus installer!';
echo;
echo 'This installer will perform the following steps:';
echo '1) Install a compatible Java version (if not already present)';
echo '2) Install the "haveged" entropy service (if not already present)';
echo '3) Install the latest version of Unimus';
echo '4) Configure Unimus to start at boot';
echo '5) Start Unimus';
echo;
echo 'If you are upgrading from a previous version, your current Unimus service will be stopped and restarted automatically.';
echo;
echo 'If you experience any issues with this installer, or have any questions, please contact us.';
echo '(email, website live-chat, forums, create a support ticket, etc.)';
echo;
echo 'Press ENTER to continue, or Ctrl+C to exit:';

read -s;
echo;
