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
    echo "Unsupported CPU architecture";
    exit 1;

  fi
}

function arm_menu {
  echo "Select distribution to start a new container:";
  options=( "Raspbian Stretch (9)" "Raspbian Jessie (8)" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "raspbian/stretch";;
      2) docker_run "raspbian/jessie";;
      3) exit;;
    esac
  done
}

function x64_menu {
  echo "Select distribution to start a new container:";
  options=( "Amazon Linux 2" "Amazon Linux AMI" "CentOS 7" "CentOS 6.10" "CentOS 6.6" "Debian 9 (Stretch)" \
            "Debian 8 (Jessie)" "Debian 7 (Wheeze)" "RHEL 7" "RHEL 6.5" "Ubuntu 18.04" "Ubuntu 16.04" \
            "Ubuntu 14.04" "Ubuntu 12.04" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "amazonlinux:2";;
      2) docker_run "amazonlinux:1";;
      3) docker_run "centos:7";;
      4) docker_run "centos:6.10";;
      5) docker_run "centos:6.6";;
      6) docker_run "debian:9";;
      7) docker_run "debian:8";;
      8) docker_run "debian:7";;
      9) docker_run "richxsl/rhel7";;
      10) docker_run "richxsl/rhel6.5";;
      11) docker_run "ubuntu:18.04";;
      12) docker_run "ubuntu:16.04";;
      13) docker_run "ubuntu:14.04";;
      14) docker_run "ubuntu:12.04";;
      15) exit;;
    esac
  done
}

function docker_run {
  docker run -it -v "$(dirname $(pwd))/target:/root/unimus-installer:ro" $1 /bin/bash;
}

# script entry point
main;
