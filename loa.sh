#!/bin/sh

# Open a LinuxOnAndroid shell or set up or tear down the according environment to start such shell.
# The single steps are delegated to other, smaller subscripts. Process can be adapted to a specific LoA
# setup by configuring those smaller scripts. Several LoA environments can be maintained in parallel
# by putting the specific parts configurations for one environment into dedicated variant directory.

# The following environment variables will be available at the subscripts:
# * SCRIPTDIR - base directory in which to find all the loa scripts
# * SELF - path of the subscript currently running (relative to SCRIPTDIR)
# * VARIANT - name of the variant to chose
#
# Other environment variables that might be visible at the subscripts are not intended
# to be used at the subscript.
#
# All functions defined in helper_functions.sh shall be available in the subscripts.
#
# Every subscript should source "$SCRIPTDIR/scriptenv.sh" at its beginning to assure
# these variables and functions are made available in its environment.

function print_usage {
	echo "Usage: $(basename "$0") [VARIANT] [--startup|--shutdown|--status|--list|--chroot [PROG ARGS]]"
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
	--list|-l)
	TASK="list"
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


status)
# TODO
"$(variant_file "$VARIANT" lostatus.sh)"
echo -n "LoA root fs: "
grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts || echo "not mounted."
"$(variant_file "$VARIANT" mountstatus.sh)"
;;


list)
find "$SCRIPTDIR" -type d -print
;;


chroot)
# TODO check if environment is ready yet, i.e. if statup has been run
run_script chroot.sh "$NEWROOT" "$@"
die_on_error "failed to run command in LoA environment"
;;


shell)
# TODO check if environment is ready yet, i.e. if statup has been run
# TODO use string array for SHELLCOMMAND ??
run_script shell.sh "$NEWROOT" $SHELLCOMMAND
die_on_error "failed to start shell in LoA environment"
;;


*)
scripting_error

esac

exit 0
