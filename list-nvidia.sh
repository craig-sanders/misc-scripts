#! /bin/bash
#
# script: list-nvidia.sh
# author: Craig Sanders <cas@taz.net.au>
# license: Public Domain (this script is too trivial to be anything else)

# options:
# default/none    list the packages, one per line
# -v              verbose (dpkg -l) list the packages
# -h              hold the packages with apt-mark
# -u              unhold the packages with apt-mark


# build an array of currently-installed nvidia packages.

#PKGS=$(dlocate -l nvidia cuda vdpau | awk '/^[hi]i/ {print $2}' | sed -e 's/:.*//')
#PKGS=$(dlocate -l nvidia cuda vdpau | awk '/^[hi]i/ {print $2}')

PKGS=( $(dpkg -l '*nvidia*' '*cuda*' '*vdpau*' 2>/dev/null| awk '/^[hi][^n]/ && ! /mesa/ {print $2}') )

#PKGS=$(for p in nvidia cuda vdpau ; do apt-cache search "$p" ; done |
#       cut -d" " -f1 | xargs -d'\n' dpkg -l 2>/dev/null |
#       awk '/^[hi]i/ {print $2}')


if [ "$1" == "-v" ] ; then
  dpkg -l "${PKGS[@]}"
elif [ "$1" == "-h" ] ; then
  apt-mark hold "${PKGS[@]}"
elif [ "$1" == "-u" ] ; then
  apt-mark unhold "${PKGS[@]}"
else
  printf "%s\n" "${PKGS[@]}"
fi

