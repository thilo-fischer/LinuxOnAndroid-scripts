#!/bin/sh

# Open a LinuxOnAndroid shell or set up or tear down the according environment to start such shell.
# The single steps are delegated to other, smaller scripts. Process can be adapted to a specific LoA
# setup by configuring those smaller scripts. Several LoA environments can be maintained in parallel
# by putting the specific parts configurations for one environment into dedicated variant directory.

SCRIPTDIR="$(dirname "$0")"
. "$SCRIPTDIR/helper-functions.sh"


# will only work if busybox is available
BBDIR="$(which busybox)"
die_on_error "Could not find busybox in PATH."
# favor busybox commands over Android specific vensions
PATH="$BBDIR:$PATH"

function print_usage {
	echo "Usage: $(basename "$0") [--startup|--shutdown|--status] [VARIANT] [--chroot [PROG ARGS]]"
}

#
# Parse commandline
#

TASK="shell"
VARIANT="."

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

. "$(variant_file envvar)"


#
# accomplish task (as given via commandline and envvar file)
#

case $TASK in

status)
# fixme
"$(variant_file lostatus.sh)"
echo -n "LoA root fs: "
grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts || echo "not mounted."
"$(variant_file mountstatus.sh)"
;;


startup)
if [ -n "$ROOTIMAGE" ]; then
	"$(call_script mount-image.sh)" "$ROOTIMAGE" "$NEWROOT"
	die_on_error "failed to mount the loop device"
fi

"$(call_script mount.sh)" "$NEWROOT"
die_on_error "failed processing the configured mount commands"
;;


shutdown)
# TODO Check for open chroot-shells ?
"$(call_script umount.sh)" "$NEWROOT"
die_on_error "failed processing the configured umount commands"

if [ -n "$ROOTIMAGE" ]; then	
  "$(call_script umount-image.sh)" "$ROOTIMAGE"
	die_on_error "failed to tear down the according loop device"
fi
;;


chroot)
"$(call_script chroot.sh)" "$NEWROOT" $*
;;


shell)
"$(call_script shell.sh)" "$NEWROOT"
;;


*)
scripting_error

esac
