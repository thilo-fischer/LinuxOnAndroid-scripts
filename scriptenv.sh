#!/bin/sh

# This script is actaully not necessary as long as subscripts are just sourced (instead of being invoked).
# Function call_script from helper_functions.sh implements the mechanism to pass control to subscripts
# (providing an abstraction from the actual invokation).

# If subscripts get invoked (instead of being sourced), function call_script from helper_functions.sh
# shall pass SCRIPTDIR and VARIANT as the first two positional parameters to the script.
#SCRIPTDIR="$1"
#VARIANT="$2"
#shift
#shift
#
#. "$SCRIPTDIR/helper-functions.sh"
