#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

if [ $# -lt 2 ]
then
	echo "Usage: $0 <LaminAC.info> <LaminB1.info>"
	echo "Please refer to README.md for more details."
	exit 2
fi > /dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`

LaminAC=$1
LaminB1=$2

## merge peaks and stitch
echo "Processing peak regions ..."
while read sid category peakfile bedfile readcnt
do
	cat $peakfile
done < $LaminAC | sort -k1,1 -k2,2n | bedtools merge -i - >LaminAC.peaks.bed

while read sid category peakfile bedfile readcnt
do
	cat $peakfile
done < $LaminB1 | sort -k1,1 -k2,2n | bedtools merge -i - >LaminB1.peaks.bed

cat LaminAC.peaks.bed LaminB1.peaks.bed | sort -k1,1 -k2,2n | bedtools merge -i - | perl $PRG/stitch.pl -  >candidate.bed

## count reads
echo "Counting reads ..."
cut -f 1-3 candidate.bed >cand.cnt.tmp
HEADER="Loci"
while read sid category peakfile bedfile readcnt
do
#	echo "=> $sid: $bedfile"
	bedtools intersect -a cand.cnt.tmp -b $bedfile -sorted -c >tmp
	mv tmp cand.cnt.tmp
	HEADER="$HEADER\t$sid"
done < $LaminAC

while read sid category peakfile bedfile readcnt
do
#	echo "=> $sid: $bedfile"
	bedtools intersect -a cand.cnt.tmp -b $bedfile -sorted -c >tmp
	mv tmp cand.cnt.tmp
	HEADER="$HEADER\t$sid"
done < $LaminB1

echo -e $HEADER >Lamin.cnt
cat cand.cnt.tmp | perl -ne 's/\t/:/; s/\t/-/; print' >>Lamin.cnt
rm -f cand.cnt.tmp tmp

## Replication Stress-sensitive LADs
echo "Screening RESS-LADs ..."
R --slave --args $LaminAC $LaminB1 Lamin.cnt < $PRG/norm.R
cat Lamin.RPM | perl -lane 'print $F[0] if $F[0]=~s/[:-]/\t/g && $F[-2]<0.05 && $F[-5]<0.05' >RESS-LADs.bed

## overlap LaminB1
#bedtools intersect -a RESS-LADs.bed -b $PRG/known.fragile.bed -wao >RESS-LADs.ol.fragile

## clean up
echo "Cleaning up ..."
rm -f LaminAC.peaks.bed LaminB1.peaks.bed Lamin.cnt candidate.bed
gzip Lamin.RPM

echo "Done."

