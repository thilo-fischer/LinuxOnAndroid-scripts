#!/bin/sh

function die {
	echo "$1" "Abort." >&2
	exit 1
}

function scripting_error {
	die "Scripting error."
}

function die_on_error {
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
die "$1: $EXIT_CODE"
fi	
}

function invoke {
	eval $*
	die_on_error "invokation of \`$*' failed"
}

function variant_file {
  SUBDIR="$VARIANT"
  while [ "$SUBDIR" != "." -a ! -f "$DIR/$SUBDIR/$1" ]; do
    SUBDIR="$(dirname "$SUBDIR")"
  done
  echo "$SCRIPTDIR/$SUBDIR/$1"
}

function call_script {
  SCRIPT="$1"
  shift
  source "$(variant_file "$SCRIPT")" "$VARIANT" $*
  # Below is commented out the code for the alternate approach where subscripts get invoked instead of being sourced.
  #"$(variant_file "$SCRIPT")" "$SCRIPTDIR" "$VARIANT" $*
}