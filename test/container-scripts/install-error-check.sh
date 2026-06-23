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

# real failure signals. Note 'not found' on its own is intentionally NOT a
# signal: the installer legitimately prints "Supported Java version not found"
# before installing Java. We match 'command not found' instead.
problem_regex="error|warn|command not found|permission denied|failed";

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

if grep -Eiq "${problem_regex}" "${log_file}"; then
  echoRed "Potential problems found:";
  echoRed "----------";
  grep -Ein -B2 -A2 "${problem_regex}" "${log_file}";
  exit 1;
else
  echoGreen "No errors found in log file";
  exit 0;
fi;
