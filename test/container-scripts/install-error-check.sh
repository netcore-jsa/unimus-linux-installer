#! /bin/bash

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }



log_file="/root/install.log";

# real failure signals, matched case-sensitively so we catch the installer's
# own 'ERROR:' / 'WARNING:' prefixes (and genuine shell failures) without
# tripping on benign lower-case text such as the package name 'libgpg-error',
# container noise ('Failed to resolve user ...'), or the installer's own
# "Supported Java version not found" message.
problem_regex="ERROR:|WARNING:|command not found|[Pp]ermission denied";

echo "Running post-install log checks...";

if [[ ! -f "${log_file}" ]]; then
  echoRed "ERROR: Install log file not found";
  exit 1;
fi;

# make sure the installer actually started (a missing installer or a bad mount
# can leave an empty/partial log that would otherwise read as 'clean')
if ! grep -q "Welcome to the" "${log_file}"; then
  echoRed "ERROR: installer did not run (no banner in log)";
  exit 1;
fi;

if grep -Eq "${problem_regex}" "${log_file}"; then
  echoRed "Potential problems found:";
  echoRed "----------";
  grep -En -B2 -A2 "${problem_regex}" "${log_file}";
  exit 1;
else
  echoGreen "No errors found in log file";
  exit 0;
fi;
