#!/bin/sh

# This script and function run_script from helper_functions.sh implement the details of how to
# invoke subscripts. 

# This script is not necessary with the current approach of invoking subscripts,
# but it may easily becoma necessary if the approach is changed.

# If subscripts get called (instead of being sourced), function run_script from helper_functions.sh
# shall pass SCRIPTDIR and VARIANT as the first two positional parameters to the script.
#SELF="$0"
#SCRIPTDIR="$1"
#shift
#VARIANT="$1"
#shift
#. "$SCRIPTDIR/helper-functions.sh"
