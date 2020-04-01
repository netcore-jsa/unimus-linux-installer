#! /bin/bash

port=$1;
product=$2;
unattended=$3;
debug=$4;


cd /root/${product}-installer

echo "Running ${product} installer...";
./install.sh "${unattended}" "${debug}" "-p=${port}" | tee /root/install.log;
