#!/bin/sh

. "$SCRIPTDIR/scriptenv.sh"

NEWROOT="$1"
shift

CHROOT="$(which chroot)"

export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
export USER=root
export HOME=/root

$CHROOT "$NEWROOT" "$@"
