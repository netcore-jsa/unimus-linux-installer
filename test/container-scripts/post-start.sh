#! /bin/bash

# EOL distros no longer serve their default mirrors. Repoint their package
# sources to the archive/vault mirrors so the test container has working repos.
# This is TEST SCAFFOLDING ONLY - the installer itself must never rewrite a
# user's repositories.
function repoint_centos_vault { # full vault base url
  # note: '|' delimiter, because the pattern itself contains '#'
  sed -i -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e "s|^#\\?baseurl=http://mirror.centos.org/\$contentdir/\$releasever|baseurl=$1|g" \
         -e "s|^#\\?baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=$1|g" \
         /etc/yum.repos.d/CentOS-*.repo;
  echo "Repointed CentOS repos to '$1'";
}

function repoint_rhel6_vault {
  # RHEL 6 repos are subscription-gated/dead; point at the binary-compatible
  # CentOS 6.10 vault so the RHEL install path can be exercised
  rm -f /etc/yum.repos.d/*.repo;
  cat > /etc/yum.repos.d/centos6-vault.repo <<'EOF'
[c6-base]
name=CentOS 6.10 vault - base
baseurl=http://vault.centos.org/6.10/os/$basearch/
enabled=1
gpgcheck=0
[c6-updates]
name=CentOS 6.10 vault - updates
baseurl=http://vault.centos.org/6.10/updates/$basearch/
enabled=1
gpgcheck=0
EOF
  echo "Repointed RHEL 6 repos to CentOS 6.10 vault";
}

function repoint_debian_archive { # codename
  printf 'deb http://archive.debian.org/debian %s main\ndeb http://archive.debian.org/debian-security %s/updates main\n' "$1" "$1" > /etc/apt/sources.list;
  # archived suites have expired Release files / GPG keys; tell apt to tolerate
  # that (test scaffolding only). Also covers the installer's own backports repo.
  { echo 'Acquire::Check-Valid-Until "false";';
    echo 'Acquire::AllowInsecureRepositories "true";';
    echo 'APT::Get::AllowUnauthenticated "true";'; } > /etc/apt/apt.conf.d/10-archive;
  echo "Repointed Debian '$1' repos to archive.debian.org";
}

case ${IMAGE} in
  *"roboxes/rhel6"*) repoint_rhel6_vault;;
  *"centos:8"*)     repoint_centos_vault "http://vault.centos.org/8.5.2111";;
  *"centos:7"*)     repoint_centos_vault "http://vault.centos.org/centos/7.9.2009";;
  *"centos:6.10"*)  repoint_centos_vault "http://vault.centos.org/6.10";;
  *"debian:8"*)     repoint_debian_archive "jessie";;
  *"debian:9"*)     repoint_debian_archive "stretch";;
  *"debian:10"*)    repoint_debian_archive "buster";;
  *"ubuntu:12.04"*)
    sed -i -e 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' \
           -e 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' \
           /etc/apt/sources.list;
    echo "Repointed Ubuntu 12.04 repos to old-releases.ubuntu.com";
    ;;
esac;

# some containers (especially old ones) need fixing before they are usable
case ${IMAGE} in
  *"centos"*|*"amazonlinux"*|*"roboxes/rhel6"*)
    echo "Running post-start fixes for '${IMAGE}'";
    echo;

    yum install initscripts -y -q;
    yum update ca-certificates -y -q;
    yum update nss -y -q;
    echo;
    ;;
esac;



options=( "Unimus installer" "Unimus Core installer" "Shell (bash)" "Quit" );

if [[ -z "${PRODUCT}" ]]; then
  select opt in "${options[@]}"; do
    case $REPLY in
      1) product='unimus';
         break;;
      2) product='unimus-core';
         break;;
      3) /bin/bash;;
      4) echo;
         echo "Exiting container...";
         echo;
         exit;;
    esac;
  done;
else
  product=${PRODUCT}
fi;

# run install script
echo;
/root/container-scripts/run-install.sh ${product} ${UNATTENDED} ${DEBUG};

# run post-install checks
echo;
/root/container-scripts/install-error-check.sh;
check_status=$?;

# echo port mapping
if [[ ${product} == 'unimus' ]]; then
  echo;
  echo "Port mapping host:${HOST_PORT} -> container:8085";
  echo;
fi;

# in unattended mode there is no one to use the shell, so exit with the
# check result (lets CI / automated runs detect failures via exit code)
if [[ -n "${UNATTENDED}" ]]; then
  exit ${check_status};
fi;

# drop the user off in a shell
/bin/bash;
