#! /bin/bash

options=( "Core installer" "Unimus installer" "Shell (bash)" "Quit" );

select opt in "${options[@]}"; do
  case $REPLY in
    1) product="core";
       break;;

    2) product="unimus";
       break;;

    3) /bin/bash;;

    4) echo;
       echo "Exiting container...";
       echo;
       exit;;
  esac;
done;

echo;
echo "Running ${product} installer...";
/root/${product}-installer/install.sh "${UNATTENDED}" "${DEBUG}" | tee /root/install.log;
