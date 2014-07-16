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
  echo "$DIR/$SUBDIR/$1"
}
