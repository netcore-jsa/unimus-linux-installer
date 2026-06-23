#! /bin/bash

product=$1;
unattended=$2;
debug=$3;

cd /root/${product}-installer || exit 1

echo "Running ${product} installer...";
./install.sh "${unattended}" "${debug}" | tee /root/install.log;
