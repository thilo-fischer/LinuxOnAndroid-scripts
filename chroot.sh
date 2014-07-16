CHROOT="$(which chroot)"

export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
export USER=root
export HOME=/root

#$CHROOT "$1" /root/init.sh $(basename $imgfile)
$CHROOT "$1" /bin/sh -
