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
    docker_run ${image};
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

  options=( "AlmaLinux 8" "Amazon Linux 2" "Amazon Linux AMI" "CentOS 8" "CentOS 7" "CentOS 6.10" "CentOS 6.6" "Debian 10 (Buster)" \
            "Debian 9 (Stretch)" "Debian 8 (Jessie)" "RHEL 7" "RHEL 6.5" "OL 8" "OL 7" "Ubuntu 20.04" "Ubuntu 18.04" \
            "Ubuntu 16.04" "Ubuntu 14.04" "Ubuntu 12.04" "Quit" );

  select opt in "${options[@]}"; do
    case $REPLY in
      1) docker_run "almalinux:8";;
      2) docker_run "amazonlinux:2";;
      3) docker_run "amazonlinux:1";;
      4) docker_run "centos:8";;
      5) docker_run "centos:7";;
      6) docker_run "centos:6.10";;
      7) docker_run "centos:6.6";;
      8) docker_run "debian:10";;
      9) docker_run "debian:9";;
      10) docker_run "debian:8";;
      11) docker_run "richxsl/rhel7";;
      12) docker_run "richxsl/rhel6.5";;
      13) docker_run "oraclelinux:8";;
      14) docker_run "oraclelinux:7";;
      15) docker_run "ubuntu:20.04";;
      16) docker_run "ubuntu:18.04";;
      17) docker_run "ubuntu:16.04";;
      18) docker_run "ubuntu:14.04";;
      19) docker_run "ubuntu:12.04";;
      20) exit;;
    esac;
  done;
}

function docker_run {
  echo;
  echo "Running ${1} container...";
  echo;

  docker run -it --rm \
    -p ${host_port}:8085 \
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
