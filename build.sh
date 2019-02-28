#!/bin/bash

# Version: 2019-02-28-01

# set workdir to the script dir
cd "$(dirname "$0")"

# make target directory if missing
if [ ! -d "target" ]; then
  mkdir "target";
fi

# target cleanup
rm -r target/*;

echo "Select build profile:";
options=( "test" "prod" "Quit" );

select opt in "${options[@]}"; do
  case $REPLY in
    1) run_command="./%s";;
    2) run_command="bash <(curl -sS 'https://unimus.net/download/linux-v2/%s')";;
    3) break;;
  esac
done

cp -r src/* target;
cd target;

find . -type f -exec sed -i -r "s#<run-replace\|(.+?)\|run-replace>#$(printf "${run_command}" "\1")#" {} +;
