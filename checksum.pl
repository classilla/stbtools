#!/usr/bin/perl
#
# Compute Mac checksum for a ROM and compares it with the existing one.
# Provide the ROM as an argument or on standard input.
#
# Copyright (C) 2023 Cameron Kaiser. All rights reserved.
# BSD license.
# oldvcr.blogspot.com

eval "use bytes";
$/ = \4; $actual = unpack("N", <>); printf("expected = 0x%08x\n", $actual);

read(ARGV, $buf, 8388608);
die("length of buffer is not even: @{[ length($buf) ]} bytes\n")
	if (length($buf) & 1);
print "bytes read = @{[ length($buf) + 4 ]}\n";
$checksum = 0;
map { $checksum += $_ } unpack("n*", $buf); # map is faster than grep
$checksum &= 4294967295;
printf("computed = 0x%08x (%s)\n", $checksum,
	($checksum == $actual) ? "matches" : "DOES NOT MATCH");
