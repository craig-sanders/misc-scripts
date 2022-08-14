#! /bin/bash

dkms status

declare -a VER MODULES KERNELS

#KERNELS=( $( find /var/lib/initramfs-tools/ -maxdepth 1 -type f \
#               -exec basename -a {} +
#           )
#        )
#
KERNELS=( $( linux-version list ) )

if [ "$#" -gt 0 ] ; then
  # modules listed on cmd-line. get versions.
  for m in "$@" ; do
    VER=( $(find "/var/lib/dkms/$m" -mindepth 1 -maxdepth 1 -type d \
              -name '[0-9.]*' -exec basename {} \;
           )
        )
    if [ "${#VER[@]}" -eq 1 ] ; then
      MODULES+=( "$m" "${VER[0]}" )
    fi
  done
else
  MODULES=( $( find /var/lib/dkms/ -mindepth 2 -maxdepth 2 -type d |
                 awk -F/ '{print $5, $6}' |
                 sort
             )
          )
fi


if [ "${#MODULES[@]}" -eq 0 ] ; then
  echo "No modules to compile"
  exit 1
fi

#typeset -p MODULES KERNELS VER


# make sure all modules are built and installed for
# all kernel versions
for k in "${KERNELS[@]}" ; do
  while read module version ; do
    echo echo
    echo echo dkms install -m "$module" -v "$version" -k "$k"
    echo dkms install -m "$module" -v "$version" -k "$k"
  done < <(printf "%s %s\n" "${MODULES[@]}")
done | bash

# now update initrd for all kernels where new or updated
# modules have been built.
for k in "${KERNELS[@]}" ; do
   itime=$(stat -c '%Y' "/boot/initrd.img-$k")
   mtime=$(stat -c '%Y' "/lib/modules/$k/updates/dkms/")

   [ "$mtime" -gt "$itime" ] && update-initramfs -u -k "$k"
done

rm -fv /boot/initrd.img-*.old-dkms
