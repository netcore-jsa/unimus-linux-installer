#! /bin/bash

# some containers (especially old ones) need fixing before they are usable
case $IMAGE in
  "debian:7")
    echo "Running post-start fixes for '${IMAGE}'";
    echo;

    echo "deb http://archive.debian.org/debian wheezy main" > /etc/apt/sources.list;
    ;;
esac;

# run install script
/root/container-scripts/run-install.sh;

# run post-install checks
/root/container-scripts/install-error-check.sh;

# drop the user off in a shell
/bin/bash;
