#!/bin/bash

# Version: 2019-02-27-01

function main {
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
  options=( "Raspbian Stretch" "Raspbian Jessie" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "raspbian/stretch";;
      2) docker_run "raspbian/jessie";;
      3) break;;
    esac
  done
}

function x64_menu {
  echo "Select distribution to start a new container:";
  options=( "Ubuntu 18.04" "Ubuntu 16.04" "Ubuntu 14.04" "Ubuntu 12.04" "Debian 9" "Debian 8" "Debian 7" \
            "CentOS 7" "CentOS 6.10" "CentOS 6.5" "RHEL 7" "RHEL 6.5" "Amazon Linux 2" "Amazon Linux AMI" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "ubuntu:18.04";;
      2) docker_run "ubuntu:16.04";;
      3) docker_run "ubuntu:14.04";;
      4) docker_run "ubuntu:12.04";;
      5) docker_run "debian:9";;
      6) docker_run "debian:8";;
      7) docker_run "debian:7";;
      8) docker_run "centos:7";;
      9) docker_run "centos:6.10";;
      10) docker_run "centos:6.5";;
      11) docker_run "richxsl/rhel7";;
      12) docker_run "richxsl/rhel6.5";;
      13) docker_run "amazonlinux:2";;
      14) docker_run "amazonlinux:1";;
      15) break;;
    esac
  done
}

function docker_run {
  docker run -it $1 /bin/bash;
}

# script entry point
main
