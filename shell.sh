#!/bin/sh

. "$1/scriptenv.sh"

NEWROOT="$1"

#$CHROOT "$1" /root/init.sh $(basename $imgfile)
invoke "$(dirname $0)/chroot.sh" "$NEWROOT" /bin/sh -
