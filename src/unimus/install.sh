#!/bin/bash

# set workdir to the script dir
cd "$(dirname "$0")";

# import common installer functions
<source-replace|functions.sh|source-replace>;

# override product specific functions
<source-replace|unimus-functions.sh|source-replace>;

# import Unimus specific installer data
<source-replace|unimus-data.sh|source-replace>;

# default installer behavior
interactive=1;
debug=0;
minimal=0;

# run install script
main $@;
