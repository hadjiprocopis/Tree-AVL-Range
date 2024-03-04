#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range;

my $tree = Tree::AVL::Range->new(
);
ok(defined($tree), "Tree::AVL::Range->new() OK") or BAIL_OUT("call to ".'Tree::AVL::Range->new()'." has failed.");

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
	ok(defined($B), "make_node_and_add() OK") or BAIL_OUT("call to make_node_and_add() has failed.");
	push(@inserts, $B);
}
print "Here is the final tree:\n".$tree."\n";

print "Done inserts, now checking if 2.1 is contained in tree (it does)\n";
my $obj = $tree->contains(2.1);
ok(defined($obj), "found item 2.1 belongs to tree:\n".$tree);

my $arr_bins = $tree->to_array();
print "The bins as an ordered array:\n\t".join("\n\t", @$arr_bins)."\n";
is($arr_bins->[0]->left_boundary(), 0, "total left boundary is 0");
is($arr_bins->[-1]->right_boundary(), $N, "total right boundary is $N");

my $fifth_bin = $arr_bins->[4];
my $fifth_bin_again = $tree->bin(4);
ok($fifth_bin == $fifth_bin_again, "bin() works OK: ".$fifth_bin." and ".$fifth_bin_again);

done_testing();
1;
