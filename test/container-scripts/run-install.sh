#! /bin/bash

product=$1;

echo "Running ${product} installer...";
/root/${product}-installer/install.sh "${UNATTENDED}" "${DEBUG}" | tee /root/install.log;
