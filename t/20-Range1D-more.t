#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range;

my $num_tests = 0;

my $tree = Tree::AVL::Range->new(
);
ok(defined($tree), "Tree::AVL::Range->new() OK"); $num_tests++;
if( ! defined($tree) ){ print STDERR "$0 : call to ".'Tree::AVL::Range->new()'." has failed.\n"; exit(1); }

my $N = 10; # number of bins
my $BW = 1; # bin width
my @inserts = ();
my $B;
for(0..($N-1)){
	my $B = [$_, $_+$BW];
	my $lab = $_.':'.($_+$BW);
	my %params = (
		'boundaries' => $B,
		'label' => $lab,
	);
	$B = $tree->make_node_and_add(\%params);
	ok(defined($B), "make_node_and_add() OK"); $num_tests++;
	if( ! defined($B) ){ print STDERR "$0 : call to make_node_and_add() has failed.\n"; exit(1) }
	push(@inserts, $B);
}
print "Here is the final tree:\n".$tree."\n";

print "Done inserts, now checking if 2.1 is contained in tree (it does)\n";
my $obj = $tree->contains(2.1);
ok(defined($obj), "found item 2.1 belongs to tree:\n".$tree); $num_tests++;

my $arr_bins = $tree->to_array();
print "The bins as an ordered array:\n\t".join("\n\t", @$arr_bins)."\n";
is($arr_bins->[0]->left_boundary(), 0, "total left boundary is 0"); $num_tests++;
is($arr_bins->[-1]->right_boundary(), $N, "total right boundary is $N"); $num_tests++;

my $fifth_bin = $arr_bins->[4];
my $fifth_bin_again = $tree->bin(4);
ok($fifth_bin == $fifth_bin_again, "bin() works OK: ".$fifth_bin." and ".$fifth_bin_again); $num_tests++;

done_testing($num_tests);
1;
