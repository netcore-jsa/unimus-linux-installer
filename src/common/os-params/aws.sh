#!/bin/bash

# Amazon Linux 2023 ships Amazon Corretto instead of OpenJDK and has no EPEL
# or haveged, so override the package lists for it (overrides aws-centos-rhel.sh)
case $os_release in
  *"Amazon Linux 2023"*)
    # AL2023 ships curl-minimal (provides curl); installing the full 'curl'
    # package conflicts with it, so only pull in procps here
    dependency_packages=( 'procps' );
    java_package_install_list=( 'java-17-amazon-corretto' 'java-11-amazon-corretto' 'java-1.8.0-amazon-corretto' );
    ;;
esac;

# enable EPEL repo
function pre_dependency_install {
  debug "Enabling EPEL repos";

  case $os_release in
    *"Amazon Linux 2023"*)
      # AL2023 has no EPEL; matched first so it can't fall into the 'Amazon Linux 2' branch
      ;;
    *"Amazon Linux 2"*)
      yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;
      ;;
    *"Amazon Linux AMI"*)
      yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm;
      ;;
  esac;
}
