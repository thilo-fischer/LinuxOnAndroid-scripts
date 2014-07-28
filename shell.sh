#!/bin/sh

# This script is basically just a wrapper around chroot.sh. It is a script on its own though,
# mainly to enable variant specific scripting wrt shell invokation.

. "$SCRIPTDIR/scriptenv.sh"

NEWROOT="$1"
shift

#$CHROOT "$1" /root/init.sh $(basename $imgfile)
run_script chroot.sh "$NEWROOT" "$@"
