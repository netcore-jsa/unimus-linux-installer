#!/bin/bash

# set workdir to the script dir
cd "$(dirname "$0")";

# import common installer functions
<source-replace|functions.sh|source-replace>;

# override product specific functions
<source-replace|unimus-core-functions.sh|source-replace>;

# import Core specific installer data
<source-replace|unimus-core-data.sh|source-replace>;

# default installer behavior
interactive=1;
debug=0;
minimal=0;

# save provided arguments
run_args=$@;

# verify presence of existing installation if minimal upgrade is chosen
for i in ${run_args[@]}; do
	if [[ $i == '-m' ]]; then
		if [ -f "${binary_path}" ]; then
			break;
		else
			echo 'ERROR: We are sorry, but a minimal upgrade can be run only on existing installations.';
			echo "Remove \"-m\" argument to run a fresh installation of ${product_name}.";
			exit 1;
		fi;
	fi;
done

# run install script
main;
