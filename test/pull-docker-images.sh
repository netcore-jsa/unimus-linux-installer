#!/bin/bash

# Version: 2019-02-27-01

function main {
  lscpu=$(lscpu);

  if [[ $lscpu == *ARM* ]]; then
    echo_pull "Raspbian";
    pull_raspbian;

  elif [[ $lscpu == *x86_64* ]]; then
    echo_pull "Ubuntu";
    pull_ubuntu;

    echo_pull "Debian";
    pull_debian;

    echo_pull "CentOS";
    pull_centos;

    echo_pull "RHEL";
    pull_rhel;

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

function pull_ubuntu {
  ubuntu_images=( "ubuntu:18.04" "ubuntu:16.04" "ubuntu:14.04" "ubuntu:12.04" );
  docker_pull ${ubuntu_images[@]};
}

function pull_debian {
  debian_images=( "debian:9" "debian:8" "debian:7" );
  docker_pull ${debian_images[@]};
}

function pull_centos {
  centos_images=( "centos:7" "centos:6.10" "centos:6.5" );
  docker_pull ${centos_images[@]};
}

function pull_rhel {
  rhel_images=( "richxsl/rhel7" "richxsl/rhel6.5" );
  docker_pull ${rhel_images[@]};
}

function pull_raspbian {
  raspbian_images=( "raspbian/stretch" "raspbian/jessie" );
  docker_pull ${raspbian_images[@]};
}

function docker_pull {
  for i in "${@}"; do
    docker pull ${i};
  done
}

# script entry point
main
