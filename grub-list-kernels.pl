#! /usr/bin/perl 

# parse and list the boot entries in the grub boot menu (grub.cfg)
#
# $Id: grub-list-kernels.pl,v 1.9 2016/06/06 23:22:48 root Exp $

# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 Craig Sanders <cas@taz.net.au>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# Partial Revision History:
# 2015-07-24 - added --verbose option for use with grub-set-default
#              fixed display of default boot item when it is "submenuid>menuentry_id_option"
# 2013-06-20 - better handling of non-numeric default saved entries, code still uglyish but better commented.
# 2013-05-13 - first stab at support for submenus...works but uglified the code
# 2010-11-03 - rewrote for grub2 (grub.cfg rather than menu.lst)

use strict;

use Getopt::Long;

our $verbose = 0;   # verbose format displays menuidoption for use with grub-set-default
my $debug = 0 ;
my $help = 0;

GetOptions('help|?|h' => \$help, 
           'verbose|v' => \$verbose, 
           'debug|d' => \$debug, 
           ) ;


my $cfg = shift || '/boot/grub/grub.cfg';

my $grubenv='/boot/grub/grubenv';

# hash of kernels (menu entry index -> menu entry description) 
# e.g. '4' => 'Debian GNU/Linux, with Linux 3.8-1-amd64'
my %K = ();

# hash of menuentry_id_option -> menuindex
# e.g. 'gnulinux-3.8-1-amd64-advanced-6bb6d228-0581-49ae-9d49-dd148c273ecc' => 4
my %M = ();

# read in the menu entries.

open(MENU,"<$cfg") || die "couldn't open $cfg for read: $!\n" ;

my $insubmenu = 0;
my $menuitem=0;
my $submenuitem=0;
my $prefix='';
my $menuindex='';
my $kernel='';
my $menuidoption='';

while (<MENU>) {
  #next unless /^\s*menuentry\s/io;
  chomp;
  if ($insubmenu ne 0) {
    next unless /^\s*(menuentry|submenu)\s|^}$/io;
    if (m/^}$/) { $insubmenu = 0 ; $prefix='' ; next };

    $menuindex = $prefix . $submenuitem++;

  } else {
    next unless /^\s*(menuentry|submenu)\s/io;
    if (m/submenu/) {
        $insubmenu=1;
        $prefix = $menuitem . '>';
        $submenuitem = 0;
        $menuindex = $submenuitem;
    };

    $menuindex = $menuitem++;
  }

  # sometimes the default entry saved in grubenv is the menu_id_option
  # rather than numeric.  The %M hash links menu_id_option to menuindex
  # numbers.
  # e.g. 'gnulinux-3.8-1-amd64-advanced-6bb6d228-0581-49ae-9d49-dd148c273ecc' => 4
  $menuidoption='';
  my $line = $_;
  if ($line =~ m/menuentry_id_option/) { 
      $line =~ s/.*menuentry_id_option '//;
      $line =~ s/'.*//;
      $menuidoption=$line;
      $M{$menuidoption} = $menuindex;
  };

  s/[^'"]*["']([^'"]*)['"].*/$1/;
  $kernel = $_;


  $K{$menuindex} = $kernel;
  #printf "%4s\t%s\t%s\n", $menuindex, $_, $menuidoption;
  if ($verbose eq 1) {
    printf "%4s\t%s\t%s\t\n", $menuindex, $menuidoption, $_;
  } else {
    printf "%4s\t%s\t\n", $menuindex, $_;
  } ;
} ;



# now get the default kernel and boot-once kernel if any

my $saved_entry='';
my $prev_saved_entry='';
my $defk = 0;
my $once = 0;

open(GRUBENV, "<$grubenv") || die "couldn't open $grubenv for read: $!\n" ;
while (<GRUBENV>) {
  chomp;
  next unless /saved_entry/;
  if (/^saved_entry/) {
    (undef,$saved_entry) = split /=/;
  } elsif (/^prev_saved_entry/) {
    (undef,$prev_saved_entry) = split /=/;
  }
}
close(GRUBENV);

$saved_entry = 0 if ($saved_entry eq '');

if ($prev_saved_entry ne '') {
  $defk = $prev_saved_entry;
  $once = $saved_entry;
  $defk =~ s/^.*>//;
  $once =~ s/^.*>//;
} else {
  $defk = $saved_entry;
  $defk =~ s/^.*>//;
}

# if $defk is non-numeric, look up index in %M
if ($defk !~ /^[0-9]+$/) {
  $defk = $M{$defk};
}

# if $once is non-numeric, look up index in %M
if ($once !~ /^[0-9]+$/) {
  $once = $M{$once};
}

print "\n  Default: $defk";
print "  \"", $K{$defk}, "\"\n";

if ($prev_saved_entry ne '') {
  print "Boot Once: $once";
  print "  \"", $K{$once}, "\"\n";
}

