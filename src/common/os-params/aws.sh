#!/bin/bash

# enable EPEL repo
function pre_dependency_install {
  debug "Enabling EPEL repos";

  case $os_release in
    *"Amazon Linux 2"*)
      yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;
      ;;
    *"Amazon Linux AMI"*)
      yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm;
      ;;
  esac;
}
