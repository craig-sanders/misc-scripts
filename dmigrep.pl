#!/usr/bin/perl -00

# example usage:
#      dmigrep.pl ddr3 dimm | grep -E '^Handle|Size|Bank|Type:|Speed:|^$'

use strict;

my $args = scalar @ARGV;

open(DMIDECODE,'-|','dmidecode') or die "Can't start dmidecode $!";

while (<DMIDECODE>) {
    my $matches=0;

    # only output records that match ALL of the args on the command line.
    foreach my $arg (@ARGV) {
      $matches++ if (m/$arg/i);
    }
    next unless ($matches == $args);
    print ;
};

close(DMIDECODE);

