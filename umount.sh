#!/bin/sh

. "$SCRIPTDIR/scriptenv.sh"

# which unmounts are necessary and which will be done implicitly when unmounting NEWROOT ? (esp. binds, proc etc.)

NEWROOT="$1"

function try_umount {
	MOUNTPOINT="$NEWROOT$1"
	# Don't fail if device is not mounted (anymore)
  # TODO grep -F
	umount "$MOUNTPOINT" || ! grep -F "$MOUNTPOINT" /proc/mounts >/dev/null 2>&1
	die_on_error "failed to unmount \`$MOUNTPOINT'"
}

try_umount /dev/pts
try_umount /proc
try_umount /sys
try_umount /sdcard
try_umount /tmp

#try_umount /root/cfg

#
# fixme: do not mount both to the same location! mount to /mnt or /media?
#
if [ -d /sdcard/external_sd ]; then
	try_umount /external_sd
fi
if [ -d /Removable/MicroSD ]; then
	try_umount /external_sd
fi
# This is for the HD version of the Archos 70 internet tablet, may be the same for the SD card edition but i dont know.
if [ -d /storage ]; then
	try_umount /external_sd
fi
