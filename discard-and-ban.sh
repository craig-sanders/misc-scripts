#! /bin/bash 

# wrapper util for mailman's withlist
#
# Discard all mail (spam) from addresses from all mailing
# lists and ban them from ever subscribing.

for address in "$@" ; do
    echo "$address"
    /var/lib/mailman/bin/withlist -a -r discard_address -- "$address"
    /var/lib/mailman/bin/withlist -a -r add_banned -- "$address"
    echo
done

