#! /bin/bash

# some containers (especially old ones) need fixing before they are usable
case ${IMAGE} in
  *"centos"*|*"amazonlinux"*)
    echo "Running post-start fixes for '${IMAGE}'";
    echo;

    yum install initscripts -y -q;
    echo;
    ;;
esac;



options=( "Unimus installer" "Unimus Core installer" "Shell (bash)" "Quit" );

if [[ -z "${PRODUCT}" ]]; then
  select opt in "${options[@]}"; do
    case $REPLY in
      1) product='unimus';
         break;;
      2) product='unimus-core';
         break;;
      3) /bin/bash;;
      4) echo;
         echo "Exiting container...";
         echo;
         exit;;
    esac;
  done;
else
  product=${PRODUCT}
fi;

# run install script
echo;
/root/container-scripts/run-install.sh ${product} ${UNATTENDED} ${DEBUG};

# run post-install checks
echo;
/root/container-scripts/install-error-check.sh;

# echo port mapping
if [[ ${product} == 'unimus' ]]; then
  echo;
  echo "Port mapping host:${HOST_PORT} -> container:8085";
  echo;
fi;

# drop the user off in a shell
/bin/bash;
