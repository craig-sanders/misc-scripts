#! /bin/sh

# Script to list processes that have a particular filesystem mounted
# within their private mount namespace.
#
# See: https://github.com/zfsonlinux/zfs/issues/5038#issuecomment-329136822
#
# In short, docker can't rm or restart a container if another process has
# the container's volume mounted in a private namespace
#
# Argument:
#
# $1 - mountpoint or dataset (e.g. from the 'docker rm' error message)
#
# Example:
#
# docker-find-mounting-proc.sh ganesh/docker/bb7aff706e3f55ae77d200035639ee2fd7c5b385600ca3fdbaab8c9d31d02ef5

main() {
  # copy-pasting from the error msg may have a trailing ':' - if so, strip it
  mountpoint="${1/%:/}"

  [ -z "$mountpoint" ] && error 1 "usage: $(basename $0) [ mountpoint ]"

  local -a procs=''
  procs=( $(for pid in $(lsns -t mnt -n -o pid,command -r |
                           awk '$2 !~ /^(\/sbin\/init|kdevtmpfs)$/ {print $1}'
                        ); do
                grep -q graph "/proc/$pid/mounts" && echo $pid;
            done)
        )
  #typeset -p mountpoint procs

  suffix=':'
  [ "${#procs[*]}" -gt 1 ] && suffix=' one or more of:'

  if [ -n "${procs[0]}" ] ; then
    ps u -p "${procs[@]}" 
    echo
    echo "If this mount is preventing docker from removing or restarting a"
    echo "container, this may be fixable by running${suffix}"
    echo
    for p in "${procs[@]}" ; do
      printf 'nsenter -m -t %s umount %s\n' "$p" "$mountpoint"
   done
  else
    echo 'No processes found'
  fi
}

error() {
  local exitcode=1
  [ -n "$2" ] && exitcode="$1" && shift
  printf "%s\n" "$@" >&2
  exit "$exitcode"
}

main "$@"

