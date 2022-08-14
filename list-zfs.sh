#! /bin/bash
#
# script: list-zfs.sh
# author: Craig Sanders <cas@taz.net.au>
# license: Public Domain (this script is too trivial to be anything else)

# options:
# default/none    list the packages, one per line
# -v              verbose (dpkg -l) list the packages
# -h              hold the packages with apt-mark
# -u              unhold the packages with apt-mark


# build an array of currently-installed zfs packages.
PKGS=( $(dpkg -l '*libnvpair*linux' '*libuutil*linux*' '*zfs*' '*zpool*' 'spl' 'spl-dkms' 'spl-kernel-modules' 'zfs-kernel-modules' 2>/dev/null | awk '/^[hi][^n]/ && ! /zfsnap|libvirt/ {print $2}') )

if [ "$1" == "-v" ] ; then
  dpkg -l "${PKGS[@]}"
elif [ "$1" == "-h" ] ; then
  apt-mark hold "${PKGS[@]}"
elif [ "$1" == "-u" ] ; then
  apt-mark unhold "${PKGS[@]}"
else
  printf "%s\n" "${PKGS[@]}"
fi

