#!/bin/bash

# Version: 2019-02-28-01

# set workdir to the script dir
cd "$(dirname "$0")"

echo "Select build profile:";
options=( "test" "prod" "Quit" );

select opt in "${options[@]}"; do
  case $REPLY in
    1) run_command="./%s";
       profile=$opt;
       break;;
    2) run_command="bash <(curl -sS 'https://unimus.net/download/linux-v2/%s')";
       profile=$opt;
       break;;
    3) exit;;
  esac
done

# make target directory if missing
if [ ! -d "target" ]; then
  mkdir "target";
fi

# target cleanup
rm -r target/* &> /dev/null;

# copy scripts from src to target
cp -r src/* target;
cd target;

# replace script parts as per profile
find . -type f -exec sed -i -r "s#<run-replace\|(.+?)\|run-replace>#$(printf "${run_command}" "\1")#" {} +;

# if running in test profile, make scripts executable
if [[ $profile == 'test' ]]; then
  chmod -R +x .;
fi

echo;
echo "Build done, check target";
echo;
