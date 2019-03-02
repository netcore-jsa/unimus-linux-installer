#!/bin/bash

# Version: 2019-02-27-01

function main {
  lscpu=$(lscpu);

  if [[ $lscpu == *ARM* ]]; then
    echo_pull "Raspbian";
    pull_raspbian;

  elif [[ $lscpu == *x86_64* ]]; then
    echo_pull "Amazon Linux";
    pull_amazon_linux;

    echo_pull "CentOS";
    pull_centos;

    echo_pull "Debian";
    pull_debian;

    echo_pull "RHEL";
    pull_rhel;

    echo_pull "Ubuntu";
    pull_ubuntu;

  else
    echo;
    echo "Unsupported CPU architecture";
    echo;

    exit 1;

  fi
}

function echo_pull {
  echo;
  echo "Pulling ${1} images...";
  echo;
}

function pull_raspbian {
  images=( "raspbian/stretch" "raspbian/jessie" );
  docker_pull ${images[@]};
}

function pull_amazon_linux {
  images=( "amazonlinux:2" "amazonlinux:1" );
  docker_pull ${images[@]};
}

function pull_centos {
  images=( "centos:7" "centos:6.10" "centos:6.6" );
  docker_pull ${images[@]};
}

function pull_debian {
  images=( "debian:9" "debian:8" "debian:7" );
  docker_pull ${images[@]};
}

function pull_rhel {
  images=( "richxsl/rhel7" "richxsl/rhel6.5" );
  docker_pull ${images[@]};
}

function pull_ubuntu {
  images=( "ubuntu:18.04" "ubuntu:16.04" "ubuntu:14.04" "ubuntu:12.04" );
  docker_pull ${images[@]};
}

function docker_pull {
  for image in "${@}"; do
    docker pull ${image};
  done
}

# script entry point
main;
