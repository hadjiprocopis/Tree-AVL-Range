#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range;

my $num_tests = 0;

my ($R1);
$R1 = Tree::AVL::Range->new({
	'num-dimensions' => 3,
});
if( ! defined($R1) ){ print STDERR "$0 : call to ".'Tree::AVL::Range->new()'." has failed, R1.\n"; exit(1) }
ok(defined($R1), "Tree::AVL::Range->new() OK"); $num_tests++;
print $R1."\n";

done_testing($num_tests);
1;
