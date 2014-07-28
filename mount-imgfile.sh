#!/bin/bash

. "$SCRIPTDIR/scriptenv.sh"

IMAGEFILE="$1"
MOUNTPOINT="$2"

# todo: seems losetup -a might cut off the end of long filenames, this might get a problem
# todo: grep -F "$IMAGEFILE" would also match prefix"$IMAGEFILE"postfix :(
LOOPDEVICE="$(losetup -a | grep -F "$IMAGEFILE" | cut -f1 -d:)"

if [ -z "$LOOPDEVICE" ]; then
	invoke mkdir -p "$MOUNTPOINT"
	invoke mount -o loop "$IMAGEFILE" "$MOUNTPOINT"
else
	if ! grep -F "$MOUNTPOINT" /proc/mounts >/dev/null 2>&1; then
		invoke mount "$LOOPDEVICE" "$MOUNTPOINT"
	fi
fi

# todo: implement fallback if mount -o loop fails: manually losetup -f, mknod, losetup, mount
