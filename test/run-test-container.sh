#!/bin/bash

function main {
  # set workdir to the script dir
  cd "$(dirname "$0")";

  if [[ -z "${image}" ]]; then
    lscpu=$(lscpu);

    if [[ ${lscpu} == *ARM* ]]; then
      arm_menu;
    elif [[ ${lscpu} == *x86_64* ]]; then
      x64_menu;
    else
      echo "ERROR: Unsupported CPU architecture";
      exit 1;
    fi;
  else    
    docker_run "${image}";
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

  options=( "AlmaLinux 9" "AlmaLinux 8" "Amazon Linux 2" "Amazon Linux AMI" "CentOS 9 (Stream)" "CentOS 8" "CentOS 7" "CentOS 6.10" "CentOS 6.6" \
            "Debian 12 (Bookworm)" "Debian 11 (Bullseye)" "Debian 10 (Buster)" "Debian 9 (Stretch)" "Debian 8 (Jessie)" "RHEL 9" "RHEL 8" \
            "RHEL 7" "RHEL 6.5" "Rocky Linux 9" "Rocky Linux 8.5" "Rocky Linux 8.4" "OL 8" "OL 7" "Ubuntu 22.04" "Ubuntu 20.04" "Ubuntu 18.04" \
            "Ubuntu 16.04" "Ubuntu 14.04" "Ubuntu 12.04" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "almalinux:9";;
      2) docker_run "almalinux:8";;
      3) docker_run "amazonlinux:2";;
      4) docker_run "amazonlinux:1";;
      5) docker_run "ciready/centos:stream-9-ci-c";;
      6) docker_run "centos:8";;
      7) docker_run "centos:7";;
      8) docker_run "centos:6.10";;
      9) docker_run "centos:6.6";;
      10) docker_run "debian:12";;
      11) docker_run "debian:11";;
      12) docker_run "debian:10";;
      13) docker_run "debian:9";;
      14) docker_run "debian:8";;
      15) docker_run "redhat/ubi9";;
      16) docker_run "redhat/ubi8";;
      17) docker_run "richxsl/rhel7";;
      18) docker_run "richxsl/rhel6.5";;
      19) docker_run "rockylinux:9";;
      20) docker_run "rockylinux/rockylinux:8.5";;
      21) docker_run "rockylinux/rockylinux:8.4";;
      22) docker_run "oraclelinux:8";;
      23) docker_run "oraclelinux:7";;
      24) docker_run "ubuntu:22.04";;
      25) docker_run "ubuntu:20.04";;
      26) docker_run "ubuntu:18.04";;
      27) docker_run "ubuntu:16.04";;
      28) docker_run "ubuntu:14.04";;
      29) docker_run "ubuntu:12.04";;
      30) exit;;
    esac;
  done;
}

function docker_run {
  echo;
  echo "Running ${1} container...";
  echo;

  docker run -it --rm \
    -p "${host_port}:8085" \
    -v "$(dirname $(pwd))/target/unimus:/root/unimus-installer:ro" \
    -v "$(dirname $(pwd))/target/unimus-core:/root/unimus-core-installer:ro" \
    -v "$(dirname $(pwd))/test/container-scripts:/root/container-scripts:ro" \
    -e HOST_PORT="${host_port}" \
    -e UNATTENDED="${unattended}" \
    -e DEBUG="${debug}" \
    -e IMAGE="${1}" \
    -e PRODUCT="${product}" \
    $1 /root/container-scripts/post-start.sh;
}



# script entry point
unattended='';
debug='';
image='';
product='';
host_port=$(( RANDOM * 10001 / 32768 + 10000 ));

supported_products=( 'unimus' 'unimus-core' );

while getopts 'udc:p:' opt; do
  case "${opt}" in
    u) unattended='-u';; # unattended mode
    d) debug='-d';; # debug mode
    c) image=${OPTARG};;
    p) product=${OPTARG};;
    \?) echo "Invalid option: -${OPTARG}" >&2;;
  esac;
done;

if [[ ! ${product} == '' ]]; then
  if [[ ! " ${supported_products[@]} " =~ " ${product} " ]]; then
    echo "ERROR: product '${product}' not supported";
    exit 1;
  fi;
fi;

main;
