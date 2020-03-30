#! /bin/bash

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }



echo "Running post-install log checks...";

# if not exist log file
if [[ ! -f "/root/install.log" ]]; then
  echoRed "ERROR: Install log file not found";

elif (( $(grep -Ei "warn|error|not found" /root/install.log | wc -l) > 0 )); then
  echoRed "Errors:"
  echoRed "----------"
  grep -Ein -B2 -A2 "error|command not found|permission denied" /root/install.log;

  echoRed "Warnings:"
  echoRed "----------"
  grep -Ein -B2 -A2 "warn" /root/install.log;

else
  echoGreen "No errors found in log file";

fi;
