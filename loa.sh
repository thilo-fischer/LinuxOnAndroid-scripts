#!/bin/sh

# Open a LinuxOnAndroid shell or set up or tear down the according environment to start such shell.
# The single steps are delegated to other, smaller subscripts. Process can be adapted to a specific LoA
# setup by configuring those smaller scripts. Several LoA environments can be maintained in parallel
# by putting the specific parts configurations for one environment into dedicated variant directory.

function print_usage {
	echo "Usage: $(basename "$0") [VARIANT] [--startup|--shutdown|--status|--chroot [PROG ARGS]]"
}

# The script should be called, not sourced. Warn and abort if it is likely we are getting sourced.
if [ "$(basename "$0" .sh)" != "loa" ]; then
	echo "Script must be called (run within its own shell instance), it cannot be sourced. (Call it like \`sh loa.sh' if it resides on a partition where you cannot \`chmod a+x loa.sh'.)" >&2
	return 1
fi

# Base directory of all subscripts
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"

. "$SCRIPTDIR/helper-functions.sh"

# The scripts will only work if busybox is available
BBDIR="$(dirname "$(which busybox)")"
die_on_error "Could not find busybox in PATH."
# favor busybox commands over Android specific vensions
PATH="$BBDIR:$PATH"

#
# Default values
#

# command line parameters
TASK="shell"
VARIANT="."

# config file (envvars) defaults
SHELLCOMMAND="/bin/bash -"


#
# Parse commandline
#

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
	--chroot|-r)
	TASK="chroot"
	shift
	break
	;;
	*)
	VARIANT="$1"
	;;
	esac
	shift
done


#
# parse "config file"
#

source "$SCRIPTDIR/$(variant_file "$VARIANT" envvar)"


#
# accomplish task (as given via commandline and envvar file)
#

case $TASK in

status)
# TODO
"$(variant_file "$VARIANT" lostatus.sh)"
echo -n "LoA root fs: "
grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts || echo "not mounted."
"$(variant_file "$VARIANT" mountstatus.sh)"
;;


startup)
if [ -n "$ROOTIMAGE" ]; then
	run_script mount-imgfile.sh "$ROOTIMAGE" "$NEWROOT"
	die_on_error "failed to mount the loop device"
fi
run_script mount.sh "$NEWROOT"
die_on_error "failed processing the configured mount commands"
;;


shutdown)
# TODO Check for open chroot-shells ?
run_script umount.sh "$NEWROOT"
die_on_error "failed processing the configured umount commands"
if [ -n "$ROOTIMAGE" ]; then	
  run_script umount-imgfile.sh "$ROOTIMAGE"
	die_on_error "failed to tear down the according loop device"
fi
;;


chroot)
# TODO check if environment is ready yet, i.e. if statup has been run
run_script chroot.sh "$NEWROOT" "$@"
die_on_error "failed to run command in LoA environment"
;;


shell)
# TODO check if environment is ready yet, i.e. if statup has been run
run_script shell.sh "$NEWROOT" "$SHELLCOMMAND"
die_on_error "failed to start shell in LoA environment"
;;


*)
scripting_error

esac

exit 0
