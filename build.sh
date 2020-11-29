#!/bin/bash

set -e;

# set workdir to the script dir
cd "$(dirname "$0")";

supported_options=( 'test' 'prod' 'Quit' );
selected_profile='';

if [[ " ${supported_options[@]} " =~ " ${1} " ]]; then
  selected_profile=$1;
else
  echo 'Select build profile:';
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

echo;
echo "Building in '${selected_profile}' profile...";

# make target directory if missing
if [[ ! -d 'target' ]]; then
  mkdir 'target';
fi

# target cleanup
rm -r target/* &> /dev/null || true;

products=( 'unimus' 'unimus-core' );
common_dirs=( 'os-params' 'systemd' 'sysv' );

for p in ${products[@]}; do
  echo "Making 'target/${p}'";
  mkdir "target/${p}";

  cp src/${p}/*.sh "target/${p}";
  cp "src/common/functions/functions.sh" "target/${p}";

  for d in ${common_dirs[@]}; do
    cp -r "src/common/${d}" "target/${p}";
  done;

  cd "target/${p}";

  case ${selected_profile} in
    test)
      from='./%s';
      source_command="source <(cat ${from})";
      get_command="cp ${from} %s";
      ;;
    prod)
      from="https://download.unimus.net/${p}/linux-v2/%s";
      source_command="source <(curl -LsS '${from}')";
      get_command="curl -L '${from}' -o %s";
      ;;
  esac;

  # replace script parts as per profile
  find . -type f -exec sed -i -r "s#<source-replace\|(.+?)\|source-replace>#$(printf "${source_command}" '\1')#" {} +;
  find . -type f -exec sed -i -r "s#<get-replace\|(.+?)\|(.+?)\|get-replace>#$(printf "${get_command}" '\1' '\2')#" {} +;

  # generate init / unit files
  files=( 'systemd/service' 'sysv/init' );
  replacements=( 'product_name' 'short_description' 'long_description' 'service_name' 'binary_path' );

  for f in ${files[@]}; do
    for r in ${replacements[@]}; do
      data=$(sed -n -E "s/^${r}='(.+?)';$/\1/p" "${p}-data.sh");
      sed -i "s@<|${r}|>@${data}@g" "${f}";
    done;
  done;

  cd "../..";
done;

# if running in test profile, make scripts executable
if [[ ${selected_profile} == 'test' ]]; then
  find 'target' -type f -exec chmod -R +x {} +;
fi

echo "Build done, check target";
echo;
