#!/bin/bash

# set workdir to the script dir
cd "$(dirname "$0")";

supported_options=( 'test' 'prod' 'Quit' );
selected_profile='';

if [[ " ${supported_options[@]} " =~ " ${1} " ]]; then
  selected_profile=$1;
else
  echo "Select build profile:";
  select opt in "${supported_options[@]}"; do
    case $REPLY in
      1|2)
        selected_profile=$opt;
        break;;
      3)
        exit;;
    esac;
  done;
fi;

case $selected_profile in
  test)
    source_command="source <(cat ./%s)";
    get_command="cp ./%s %s";
    ;;
  prod)
    source_command="source <(curl -sS 'https://unimus.net/download/linux-v2/%s')";
    get_command="curl https://unimus.net/download/linux-v2/%s -o %s 2>&1')";
    ;;
  Quit)
    exit;;
esac;

# make target directory if missing
if [ ! -d "target" ]; then
  mkdir "target";
fi

# target cleanup
rm -r target/* &> /dev/null;

echo;
echo "Building in '${selected_profile}' profile...";

products=( 'unimus' 'unimus-core' );

for i in ${products[@]}; do
  mkdir "target/${i}";
  cp src/${i}/*.sh "target/${i}";
done;

# copy scripts from src to target
common_dirs=( 'functions' 'params' 'systemd' 'sysv' );

for i in ${common_dirs[@]}; do
  for p in ${products[@]}; do
    cp -r "src/common/${i}" "target/${p}";
  done;
done;

cd target;

# replace script parts as per profile
find . -type f -exec sed -i -r "s#<source-replace\|(.+?)\|source-replace>#$(printf "${source_command}" "\1")#" {} +;
find . -type f -exec sed -i -r "s#<get-replace\|(.+?)\|(.+?)\|get-replace>#$(printf "${get_command}" "\1" "\2")#" {} +;

# FIXME generate per-application init/unit files

# if running in test profile, make scripts executable
if [[ $selected_profile == 'test' ]]; then
  chmod -R +x .;
fi

echo "Build done, check target";
echo;
