#!/bin/sh

# Set up the environment subscripts may expect and use.
# 1st parameter: Base directory where to find the scripts.
# 2nd parameter: Pathname of the current script.

SCRIPTDIR="$1"
shift
SELF="$1"
shift

# If subscripts get called (instead of being sourced), function run_script from helper_functions.sh
# shall pass SCRIPTDIR and VARIANT as the first two positional parameters to the script.
#SELF="$0"
#SCRIPTDIR="$1"
#shift
#VARIANT="$1"
#shift
#. "$SCRIPTDIR/helper-functions.sh"
