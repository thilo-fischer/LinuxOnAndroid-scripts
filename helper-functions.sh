#!/bin/sh

# Abort script execution.
# 1 parameter: Error message
function die {
	echo "$1" "Abort." >&2
	exit 1
}

# Abort script execution with error message "Scripting error."
# No parameters.
function scripting_error {
	die "Scripting error."
}

# Abort script execution if the previous command exited with an error code.
# 1 parameter: Error message
function die_on_error {
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
die "$1: $EXIT_CODE"
fi	
}

# Run the command given by the parameters. If an error occurs, abort script with generic error message.
# arbitrary number of parameters: Command to run.
function invoke {
	"$@"
	die_on_error "invokation of \`$*' failed"
}

# Find the script applicable to the selected variant matching the provided name.
# 1 parameter: name of the script
function variant_file {
  SUBDIR="$VARIANT"
  while [ "$SUBDIR" != "." -a ! -f "$SCRIPTDIR/$SUBDIR/$1" ]; do
    SUBDIR="$(dirname "$SUBDIR")"
  done
  echo "$SCRIPTDIR/$SUBDIR/$1"
}

# Run the script given by the first parameter with the arguments given by the remaining parameters.
# Will provide additional parameters for "reflection" that will be consumed by the scriptenv.sh script.
# Implements the mechanism to pass control to subscripts -- run in shell or source --
# providing an abstraction from the actual invokation mechanism.
# 1st parameter: Name of the script to be invoked.
# arbitrary number of additional parameters: Arguments passed to the script.
# TODO 1: restore SELF after script has been run
# TODO 2: scriptenv.sh and providing of the parameters consumed by it seems not necessary ...
#   ===> SELF="$SCRIPTDIR" source "$SCRIPTFILE" "$@" # ??
function run_script {
  SCRIPT="$1"
  shift
  SCRIPTFILE="$(variant_file "$SCRIPT")"
  source "$SCRIPTFILE" "$SCRIPTDIR" "$SCRIPTFILE" "$@"
  # Below is commented out the code for the alternate approach where subscripts get invoked instead of being sourced.
  #export $PATH # ??
  #"$(variant_file "$SCRIPT")" "$SCRIPTDIR" "$VARIANT" "$@"
}
