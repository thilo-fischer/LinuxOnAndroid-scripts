#!/bin/sh

# Function run_script from helper_functions.sh implements the mechanism to pass control to subscripts
# (providing an abstraction from the actual invokation).

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
#export $PATH
#. "$SCRIPTDIR/helper-functions.sh"
