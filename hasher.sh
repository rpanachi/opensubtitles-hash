#!/usr/bin/perl
#from http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Perl
#usage: ./hasher.sh filename.avi

use strict;
use warnings;

sub OpenSubtitlesHash {
        my $filename = shift or die("Need video filename");

        open my $handle, "<", $filename or die $!;
        binmode $handle;

        my $fsize = -s $filename;

        my $hash = [$fsize & 0xFFFF, ($fsize >> 16) & 0xFFFF, 0, 0];

        $hash = AddUINT64($hash, ReadUINT64($handle)) for (1..8192);

    my $offset = $fsize - 65536;
    seek($handle, $offset > 0 ? $offset : 0, 0) or die $!;

    $hash = AddUINT64($hash, ReadUINT64($handle)) for (1..8192);

    close $handle or die $!;
    return UINT64FormatHex($hash);
}

sub ReadUINT64 {
        read($_[0], my $u, 8);
        return [unpack("vvvv", $u)];
}

sub AddUINT64 {
    my $o = [0,0,0,0];
    my $carry = 0;
    for my $i (0..3) {
        if (($_[0]->[$i] + $_[1]->[$i] + $carry) > 0xffff ) {
                        $o->[$i] += ($_[0]->[$i] + $_[1]->[$i] + $carry) & 0xffff;
                        $carry = 1;
                } else {
                        $o->[$i] += ($_[0]->[$i] + $_[1]->[$i] + $carry);
                        $carry = 0;
                }
        }
    return $o;
}

sub UINT64FormatHex {
    return sprintf("%04x%04x%04x%04x", $_[0]->[3], $_[0]->[2], $_[0]->[1], $_[0]->[0]);
}


print OpenSubtitlesHash("$ARGV[0]");
