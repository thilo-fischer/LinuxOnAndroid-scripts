#!/bin/sh

# Open a LinuxOnAndroid shell or set up or tear down the according environment to start such shell.
# The single steps are delegated to other, smaller scripts. Process can be adapted to a specific LoA
# setup by configuring those smaller scripts. Several LoA environments can be maintained in parallel
# by putting the specific parts configurations for one environment into dedicated variant directory.

TASK="shell"
VARIANT="."

DIR="$(dirname "$0")"

function print_usage {
	echo "Usage: $(basename "$0") [--startup|--shutdown|--status] [VARIANT]"
}

function die {
	echo "$1" "Abort." >&2
	exit 1
}

function scripting_error {
	die "Scripting error."
}

function variant_file {
  SUBDIR="$VARIANT"
  while [ "$SUBDIR" != "." -a ! -f "$DIR/$SUBDIR/$1" ]; do
    SUBDIR="$(dirname "$SUBDIR")"
  done
  echo "$DIR/$SUBDIR/$1"
}

# TODO detect when incompatible arguments are given on the command line
while [ $# -gt 0 ]; do
	case $1 in
	--help|-h)
	print_usage
	exit 0
	;;
	--startup|-u)
	TASK="startup"
	;;
	--shutdown|-d)
	TASK="shutdown"
	;;
	--status|-t)
	TASK="status"
	;;
	*)
	VARIANT="$1"
	;;
	esac
	shift
done

. "$(variant_file envvar)"

case $TASK in
status)
"$(variant lostatus.sh)"
echo -n "LoA root fs: "
grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts || echo "not mounted."
"$(variant mountstatus.sh)"
;;
startup)
if [ -n "$ROOTIMAGE" ]; then
	LOOPDEVICE="$("$(variant_file losetup.sh)" "$ROOTIMAGE")"
	if [ $? -ne 0 ]; then
		die "Failed to setup the according loop device."
	fi
	grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts > /dev/null || mount "$LOOPDEVICE" "$NEWROOT"
	#grep "$LOOPDEVICE[[:space:]][[:space:]]*$NEWROOT" /proc/mounts > /dev/null || mount "$LOOPDEVICE" "$NEWROOT"
	if [ $? -ne 0 ]; then
		die "Failed to mount the loop device."
	fi
fi
"$(variant_file mount.sh)" "$NEWROOT"
if [ $? -ne 0 ]; then
	die "Failed processing the configured mount commands."
fi
;;
shell)
"$(variant chroot.sh)"
;;
shutdown)
;;
*)
scripting_error
esac
