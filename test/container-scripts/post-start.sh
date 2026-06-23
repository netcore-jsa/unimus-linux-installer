#! /bin/bash

# some containers (especially old ones) need fixing before they are usable
case ${IMAGE} in
  *"centos"*|*"amazonlinux"*)
    echo "Running post-start fixes for '${IMAGE}'";
    echo;

    yum install initscripts -y -q;
    yum update ca-certificates -y -q;
    yum update nss -y -q;
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
check_status=$?;

# echo port mapping
if [[ ${product} == 'unimus' ]]; then
  echo;
  echo "Port mapping host:${HOST_PORT} -> container:8085";
  echo;
fi;

# in unattended mode there is no one to use the shell, so exit with the
# check result (lets CI / automated runs detect failures via exit code)
if [[ -n "${UNATTENDED}" ]]; then
  exit ${check_status};
fi;

# drop the user off in a shell
/bin/bash;
