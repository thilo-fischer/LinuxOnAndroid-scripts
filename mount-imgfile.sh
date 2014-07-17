#!/bin/bash

ROOTIMAGE="$1"
NEWROOT="$2"

SCRIPTDIR="$(dirname "$0")"
. "$SCRIPTDIR/helper-functions.sh"

invoke mount -o loop "$ROOTIMAGE" "$NEWROOT"

# todo: implement fallback if mount -o loop fails: manually losetup -f, mknod, losetup, mount
