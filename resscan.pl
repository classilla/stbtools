#!/usr/bin/perl
#
# Scan for resources in a ROM dump. Right now, this only works with the
# backchains in the red Set Top Box ROM, but I'd like to make it be able
# to parse most classic Mac Toolbox ROM dumps generally.
#
# Pass the ROM as an argument or on standard input.
# If you provide pairs of resource codes and numbers after, then this scanner
# will put them in files for you.
#
# Example: ./resscan.pl RED.rom disk 0
#
# Copyright (C) 2023 Cameron Kaiser. All rights reserved.
# BSD license.
# oldvcr.blogspot.com

use bytes;

# the resource code must fall on a 32-bit boundary
undef $/; $rrom = <>; @rom = unpack("N*", $rrom);
$rlen = scalar(@rom);
print (($rlen * 4). " bytes loaded\n");

$marker0 = hex("78000000");
$marker1 = hex("08000000");
$marker2 = hex("18000000");
$marker3 = hex("28000000");
$marker4 = hex("38000000");
$marker5 = hex("70000000");
$backchain = 0;
# resource entries always on 16-byte boundary
for($i=0;$i<$rlen;$i+=4) {
	$type = $rom[$i];
	next if (($type & 134217727) || ($type == 0)); # 0x07ffffff
	next unless $rom[$i+1] == 0;
	# rooted type
	next unless ($rom[$i+2] == $backchain || $type == $marker2);

	$start = $rom[$i+3];
	next if ($start & 3); # unpossible

	# candidate found, see if it's rational
	if ($type == $marker0) {
		$backchain = ($i * 4);
		$end = $backchain;
		$i += 4;
	} elsif ($type == $marker1 || $type == $marker2 ||
			$type == $marker3 || $type == $marker4 ||
			$type == $marker5) {
		# XXX: not working yet
		$backchain = ($i * 4);
		$end = 0;
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

	if ($resc eq 'STR ') {
		$length = unpack("C", substr($rrom, $start, 1));
		print "    [$resc] \"", substr($rrom, $start+1, $length),
			"\" (length $length)\n";
	}
	if ($resc eq 'STR#') {
		$num = unpack("n", substr($rrom, $start, 2));
		$anustart = $start + 2; # KEEP TOBIAS BLUE
		print "    [STR#] $num strings follow\n";
		print "           -------------------\n";
		for(1..$num) {
			$length = unpack("C", substr($rrom, $anustart++, 1));
			if ($length) {
				print "          [$_] \"",
					substr($rrom, $anustart, $length),
					"\" (length $length)\n";
			} else {
				print "          [$_] (length 0)\n";
			}
			$anustart += $length;
		}
	}

	if ($resc eq $ARGV[0] && $rnum == $ARGV[1]) {
		print STDOUT "... writing to disk\n";
		open(S, ">$resc-$rnum.dump") || die("can't write resource: $!\n");
		print S substr($rrom, $start, ($end - $start));
		close(S);
		shift @ARGV;
		shift @ARGV;
	}
}

__DATA__

 001c7a70:  78 00 00 00 00 00 00 00  00 1c 78 80 00 1c 78 b0  x.........x...x.
 001c7a80:  50 49 43 54 b5 12 58 00  6b 63 6b 63 6b 63 6b 63  PICT..X.kckckckc
 001c7a90:  4b 75 72 74 c0 a0 00 00  00 00 00 c6 00 00 05 d4  Kurt............

 000572a0:  78 00 00 00 00 00 00 00  00 05 71 a0 00 05 72 e0  x.........q...r.
 000572b0:  50 49 43 54 00 63 58 10  44 69 73 6b 4d 6f 64 65  PICT.cX.DiskMode
 000572c0:  20 42 61 74 74 65 72 79  00 00 00 00 00 00 00 00   Battery........
 000572d0:  00 00 00 00 c0 a0 00 00  00 00 00 d1 00 00 02 b4  ................

