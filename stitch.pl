#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# First version:
# Modified date:

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <sorted.bed>\n\n";
	exit 2;
}

my $stitch_dist = 20000;
my $min_length  = 100000;

my ($lastChr, $lastStart, $lastEnd, $count);

open IN, "$ARGV[0]" or die( "$!" );
while( <IN> ) {
	next if /^#/;	## skip header
	chomp;
	my @l = split /\t/;	##chr start end extra

	## first segment
	($lastChr, $lastStart, $lastEnd) = ($l[0], $l[1], $l[2]);
	$count = 1;
	last;
}

## stitch and report
while( <IN> ) {
	chomp;
	my @l = split /\t/; ##chr start end extra

	my ($chr, $s, $e) = ($l[0], $l[1], $l[2]);
	if( $chr ne $lastChr || $s-$lastEnd>$stitch_dist ) {	## too faraway, or different direction
		## check last segment
		my $prefix = ($lastEnd - $lastStart >= $min_length) ? '' : '#';
		print join("\t", $prefix.$lastChr, $lastStart, $lastEnd, $count), "\n";

		## init a new segment
		($lastChr, $lastStart, $lastEnd) = ($chr, $s, $e);
		$count = 1;
	} else {	## stitch and prolong the current segment
		$lastEnd = $e;
		++ $count;
	}
}
close IN;

## check the last segment
my $prefix = ($lastEnd - $lastStart >= $min_length) ? '' : '#';
print join("\t", $prefix.$lastChr, $lastStart, $lastEnd, $count), "\n";

