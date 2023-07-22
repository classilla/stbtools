#!/usr/bin/perl -s
#
# Inserts an HFS image into an existing STB ROM. Must fit, must pass
# sanity checks.
#
# Copyright (C) 2023 Cameron Kaiser. All rights reserved.
# BSD license.
# oldvcr.blogspot.com
#
# usage: ./splicedisk0.pl input-rom disk-img output-rom

use bytes;
die("usage: $0 input-rom disk-img output-rom\n") if ($#ARGV != 2);

open(W, "$ARGV[0]") || die("can't open input ROM: $!\n");
undef $/; $rrom = <W>; @rom = unpack("N*", $rrom);
$rlen = scalar(@rom);
print (($rlen * 4). " ROM bytes loaded\n");
close(W);

open(X, "$ARGV[1]") || die("can't open input image: $!\n");
undef $/; $rdisk = <X>;
print length($rdisk), " disk image bytes loaded\n";
die("boot blocks are missing\n") if (substr($rdisk, 0, 2) ne 'LK');
if (unpack("H*", substr($rdisk, 1119, 1)) eq '00') {
	unless ($fix16) {
		die("not a bootable image: check byte 1119/0x045f\n")
	} else {
		print "fixing bootable folder byte at 0x045f to 0x10\n";
		$rdisk = substr($rdisk, 0, 1119) . pack("H*", "10") .
				substr($rdisk, 1120);
	}
}
close(X);

$marker0 = hex("78000000");
$backchain = 0;
# resource entries always on 16-byte boundary
for($i=0;$i<$rlen;$i+=4) {
	$type = $rom[$i];
	next if (($type & 134217727) || ($type == 0)); # 0x07ffffff
	next unless $rom[$i+1] == 0;
	# rooted type
	next unless ($rom[$i+2] == $backchain);

	$start = $rom[$i+3];
	next if ($start & 3); # unpossible

	# candidate found, see if it's rational
	if ($type == $marker0) {
		$backchain = ($i * 4);
		$end = $backchain;
		$i += 4;
	} else {
		next;
	}

	# resource type should be printable
	$roff = ($i * 4);
	$resc = substr($rrom, $roff, 4);
	next if grep { $_ < 32 || $_ > 127 } unpack("C4", $resc);

	$rnum = ($rom[$i+1] >> 16);
	$flags = ($rom[$i+1] & 65535);

	# get name
	$i += 2;
	$hexn = sprintf("%08x%08x%08x%08x%08x%08x", $rom[$i],
		$rom[$i+1],$rom[$i+2],$rom[$i+3],$rom[$i+4],$rom[$i+5]);
	($hname, $crap) = split("00", $hexn, 2);
	$name = pack("H*", $hname);
	$i += 2;

	printf "[%08x] found %s #%d at 0x%08x 0x%08x \"%s\" \n", $type,
		$resc, $rnum, $start, $end, $name;

	if ($resc eq "disk" && $rnum == 0) {
		die("can't splice, new disk image length does not match\n")
			if (($end - $start) != length($rdisk));

		print STDOUT "... splicing in new HFS disk image\n";
		$nrom = substr($rrom, 0, $start);
		$nrom .= $rdisk;
		$nrom .= substr($rrom, $end);
		die("oops\n") if (length($nrom) != length($rrom));

		$nrom = substr($nrom, 4); $checksum = 0;
		map { $checksum += $_ } unpack("n*", $nrom);
		$checksum &= 4294967295;
		printf STDOUT "... new checksum=0x%08x\n", $checksum;

		open(S, ">$ARGV[2]") || die("can't write output: $!\n");
		print S pack("N", $checksum);
		print S $nrom;
		close(S);
		exit 0;
	}
}

print "unable to find resource disk#0\n";
exit 1;

