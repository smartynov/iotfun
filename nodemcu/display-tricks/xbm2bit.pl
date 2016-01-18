#!/opt/local/bin/perl
use strict;
undef $/;
print pack "b*", unpack "B*", pack "H*", grep { s/^.*{|\s+|0x|,|}.*$//gs } <>;

