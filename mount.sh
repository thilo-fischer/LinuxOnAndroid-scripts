#!/bin/sh

. "$SCRIPTDIR/scriptenv.sh"

NEWROOT="$1"

function peek_mount {
	DEVICE="$1"
	MOUNTPOINT="$NEWROOT$2"
	shift; shift
	# Don't fail if device is already mounted at the given mountpoint
  # TODO grep
	#grep "\($DEVICE|/dev/fuse\s\+$MOUNTPOINT" /proc/mounts >/dev/null 2>&1 || 
	grep "$MOUNTPOINT" /proc/mounts >/dev/null 2>&1 || \
		mount "$@" "$DEVICE" "$MOUNTPOINT"
	die_on_error "failed to mount \`$DEVICE'"
}

peek_mount proc    /proc    -t proc
peek_mount sysfs   /sys     -t sysfs
peek_mount /dev    /dev     -o bind
peek_mount devpts  /dev/pts -t devpts
peek_mount /sdcard /sdcard  -o bind
peek_mount tmpfs   /tmp     -t tmpfs # ??
peek_mount /Removable /Removable -o rbind

#if [[ ! -d $NEWROOT/root/cfg ]]; then mkdir $NEWROOT/root/cfg; fi
#peek_mount -o bind $(dirname $ROOTIMAGE) $NEWROOT/root/cfg

#
# fixme: do not mount both to the same location! mount to /mnt or /media?
#
if [ -d /sdcard/external_sd ]; then
	peek_mount /sdcard/external_sd /external_sd -o bind
fi
if [ -d /Removable/MicroSD ]; then
	peek_mount /Removable/MicroSD /external_sd -o bind
fi
# This is for the HD version of the Archos 70 internet tablet, may be the same for the SD card edition but i dont know.
if [ -d /storage ]; then
	peek_mount /storage /external_sd -o bind
fi
