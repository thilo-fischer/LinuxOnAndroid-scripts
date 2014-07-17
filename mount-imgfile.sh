#!/bin/bash

. "$1/scriptenv.sh"

ROOTIMAGE="$1"
NEWROOT="$2"

invoke mount -o loop "$ROOTIMAGE" "$NEWROOT"

# todo: implement fallback if mount -o loop fails: manually losetup -f, mknod, losetup, mount
