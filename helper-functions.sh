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

# Find the script applicable to the selected variant matching the given name.
# 1st parameter: variant to which to find the appropriate script
# 2nd parameter: name of the script
function variant_file {
  SUBDIR="$1"
  while [ "$SUBDIR" != "." -a ! -f "$SCRIPTDIR/$SUBDIR/$2" ]; do
    SUBDIR="$(dirname "$SUBDIR")"
  done
  echo "$SUBDIR/$2"
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
  SCRIPTFILE="$(variant_file "$VARIANT" "$SCRIPT")"
  source "$SCRIPTDIR/$SCRIPTFILE" "$SCRIPTDIR" "$SCRIPTFILE" "$@"
  # Below is commented out the code for the alternate approach where subscripts get invoked instead of being sourced.
  #export $PATH # ??
  #"$(variant_file "$SCRIPTDIR/$SCRIPT")" "$SCRIPTDIR" "$VARIANT" "$@"
}

# Invoke the same script as the current one one level higher in the variant hierarchie.
# arbitrary number of parameters: Arguments to be passed to the script.
function super {
	SUPERDIR="$(dirname "$SELF")"
	# strip of any potential trailing "/."
	while [ "$(basename "$SUPERDIR")" = "." ]; do
		SUPERDIR="$(dirname "$SUPERDIR")"
		if [ "$SUPERDIR" = "." ]; then
			die "No such script: super of \`$SELF'."
		fi
	done
	# get parent directory
	SUPERDIR="$(dirname "$SUPERDIR")"
	# find variant file starting from parent directory and start it
	VARIANT="$SUPERDIR" run_script "$(basename "$SELF")" "$@"
}
