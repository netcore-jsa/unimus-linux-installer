#!/bin/bash

# Version: 2019-02-27-01

function main {
  # set workdir to the script dir
  cd "$(dirname "$0")";

  lscpu=$(lscpu);

  if [[ $lscpu == *ARM* ]]; then
    arm_menu;

  elif [[ $lscpu == *x86_64* ]]; then
    x64_menu;

  else
    echo "ERROR: Unsupported CPU architecture";
    exit 1;

  fi;
}

function arm_menu {
  echo "Select distribution to start a new container:";
  echo;

  options=( "Resin Buster (10)" "Raspbian Stretch (9)" "Raspbian Jessie (8)" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "resin/raspberry-pi-debian:buster";;
      2) docker_run "raspbian/stretch";;
      3) docker_run "raspbian/jessie";;
      4) exit;;
    esac;
  done;
}

function x64_menu {
  echo "Select distribution to start a new container:";
  echo;

  options=( "Amazon Linux 2" "Amazon Linux AMI" "CentOS 8" "CentOS 7" "CentOS 6.10" "CentOS 6.6" "Debian 10 (Buster)" \
            "Debian 9 (Stretch)" "Debian 8 (Jessie)" "Debian 7 (Wheezy)" "RHEL 7" "RHEL 6.5" "Ubuntu 20.04" "Ubuntu 18.04" \
            "Ubuntu 16.04" "Ubuntu 14.04" "Ubuntu 12.04" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "amazonlinux:2";;
      2) docker_run "amazonlinux:1";;
      3) docker_run "centos:8";;
      4) docker_run "centos:7";;
      5) docker_run "centos:6.10";;
      6) docker_run "centos:6.6";;
      7) docker_run "debian:10";;
      8) docker_run "debian:9";;
      9) docker_run "debian:8";;
      10) docker_run "debian:7";;
      11) docker_run "richxsl/rhel7";;
      12) docker_run "richxsl/rhel6.5";;
      13) docker_run "ubuntu:20.04";;
      14) docker_run "ubuntu:18.04";;
      15) docker_run "ubuntu:16.04";;
      16) docker_run "ubuntu:14.04";;
      17) docker_run "ubuntu:12.04";;
      18) exit;;
    esac;
  done;
}

function docker_run {
  echo;
  echo "Running ${1} container...";
  echo;

  docker run -it --rm \
    -p 8085:8085 \
    -v "$(dirname $(pwd))/target:/root/unimus-installer:ro" \
    -v "$(dirname $(pwd))/target:/root/core-installer:ro" \
    -v "$(dirname $(pwd))/test/container-scripts:/root/container-scripts:ro" \
    -e UNATTENDED="${unattended}" \
    -e DEBUG="${debug}" \
    -e IMAGE="${1}" \
    $1 /root/container-scripts/post-start.sh;
}

# script entry point
unattended=0;
debug=0;

if [[ ! -z "$1" ]]; then
  if [[ "$1" == "true" || "$1" == "1" ]]; then
    unattended=1;
  fi;
fi;

if [[ ! -z "$2" ]]; then
  if [[ "$2" == "true" || "$2" == "1" ]]; then
    debug=1;
  fi;
fi;

main;
