#!/usr/bin/perl
# c-drill (web only): the VM is 32-bit (long = 4 bytes) but the exam is 64-bit
# (long = 8 bytes). Rewrite `long` as `long long` in the COMPILED COPY of the
# student's file, outside strings, char literals and comments, keeping
# `long long` and `long double` as they are. Line numbers are unchanged.
use strict; use warnings;
my $f = shift or die "usage: long64.pl file.c\n";
open(my $in, '<', $f) or die; local $/; my $src = <$in>; close $in;
my @parts = split(m{("(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'|/\*.*?\*/|//[^\n]*)}s, $src);
for (my $i = 0; $i < @parts; $i += 2) {
    next unless defined $parts[$i];
    $parts[$i] =~ s/\blong(\s+)long\b/\x01$1\x02/g;
    $parts[$i] =~ s/\blong\b(?!\s+double\b)/long long/g;
    $parts[$i] =~ s/\x01/long/g; $parts[$i] =~ s/\x02/long/g;
}
open(my $out, '>', $f) or die; print $out join('', map { defined $_ ? $_ : '' } @parts); close $out;
