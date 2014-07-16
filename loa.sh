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

. helper-functions.sh

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
	die_on_error "failed to set up the according loop device"
	
	grep -E "^\s*$LOOPDEVICE\s+$NEWROOT\s" /proc/mounts > /dev/null || mount "$LOOPDEVICE" "$NEWROOT"
	die_on_error "failed to mount the loop device"
fi

"$(variant_file mount.sh)" "$NEWROOT"
die_on_error "failed processing the configured mount commands"
;;


shell)
"$(variant chroot.sh)" "$NEWROOT"
;;


shutdown)
# TODO Check for open chroot-shells ?
"$(variant_file umount.sh)" "$NEWROOT"
die_on_error "failed processing the configured umount commands"

if [ -n "$ROOTIMAGE" ]; then	
	if grep -E "^\s*\w+\s+$NEWROOT\s" /proc/mounts > /dev/null; then
		umount "$NEWROOT"
		die_on_error "failed to unmount the loop device"
	fi
  "$(variant_file loteardown.sh)" "$ROOTIMAGE"
	die_on_error "failed to tear down the according loop device"
fi
;;


*)
scripting_error

esac
