#!/bin/bash

IMAGEFILE="$1"

SCRIPTDIR="$(dirname "$0")"
. "$SCRIPTDIR/helper-functions.sh"

# todo: seems losetup -a might cut off the end of long filenames, this might get a problem
# todo: grep -F "$IMAGEFILE" would also match prefix"$IMAGEFILE"postfix :(
LOOPDEVICE="$(losetup -a | grep -F "$IMAGEFILE" | cut -f1 -d:)"

if [ -n "$LOOPDEVICE" ]; then

  MOUNTPOINT="$(echo "$(grep -E "^\s*$LOOPDEVICE\s" /proc/mounts)")"
  
  if [ -n "$MOUNTPOINT" ]; then
    umount "$MOUNTPOINT"
  fi

	# Mount should have disassociated the loop device.
	# But just in the case it failed to do so (maybe because the user
	# unmounted manually not using busybox's mount command):
	if losetup -a | cut -f1 -d: | grep -F "$LOOPDEVICE" > /dev/null; then
    invoke losetup -d "$LOOPDEVICE"
	fi

fi
