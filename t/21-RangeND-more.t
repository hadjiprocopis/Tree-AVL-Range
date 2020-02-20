#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;
use Math::Cartesian::Product;
use Data::Dumper;

use Tree::AVL::Range;

my $num_tests = 0;

my $NDIMS = 3;
my $tree = Tree::AVL::Range->new({
	'num-dimensions' => $NDIMS,
});
ok(defined($tree), "Tree::AVL::Range->new() OK"); $num_tests++;
if( ! defined($tree) ){ print STDERR "$0 : call to ".'Tree::AVL::Range->new()'." has failed.\n"; exit(1); }

my $N = 10; # number of bins
my $BW = 1; # bin width
my @inserts = ();
my $B;
my @bw = map { [$_, $_+$BW] } 0..$N-1;
my @bwall = map { [@bw] } 0..$NDIMS-1;
Math::Cartesian::Product::cartesian {
	my %params = (
		'boundaries' => [@_],
	);
	$B = $tree->make_node_and_add(\%params);
	ok(defined($B), "make_node_and_add() OK"); $num_tests++;
	if( ! defined($B) ){ print STDERR "$0 : call to make_node_and_add() has failed.\n"; exit(1) }
	push(@inserts, $B);
} @bwall;
print "Here is the final tree:\n".$tree."\n";

my ($i);
print "Done inserts, now checking if 2.1 is contained in tree (it must)\n";
my $obj = $tree->contains([2.1, 2.1, 2.1]);
ok(defined($obj), "found item 2.1 belongs to tree correctly"); $num_tests++;
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 2, "left boundary dim $i is 2"); $num_tests++;
	is($obj->right_boundary($i), 3, "right boundary dim $i is 3"); $num_tests++;
}
$obj = $tree->contains([0.1, 0.1, 0.1]);
ok(defined($obj), "found item 0.1 belongs to tree correctly"); $num_tests++;
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 0, "left boundary dim $i is 0"); $num_tests++;
	is($obj->right_boundary($i), 1, "right boundary dim $i is 1"); $num_tests++;
}
$obj = $tree->contains([9.1, 9.1, 9.1]);
ok(defined($obj), "found item 9.1 belongs to tree correctly"); $num_tests++;
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 9, "left boundary dim $i is 9"); $num_tests++;
	is($obj->right_boundary($i), 10, "right boundary dim $i is 10"); $num_tests++;
}
$obj = $tree->contains([10.1, 10.1, 10.1]);
ok(!defined($obj), "item does not belong to tree: correctly"); $num_tests++;
$obj = $tree->contains([-0.1, -0.1, -0.1]);
ok(!defined($obj), "item does not belong to tree: correctly"); $num_tests++;

my $arr_bins = $tree->to_array();
print "The bins as an ordered array:\n\t".join("\n\t", @$arr_bins)."\n";
is($arr_bins->[0]->left_boundary(0), 0, "total left boundary is 0"); $num_tests++;
is($arr_bins->[-1]->right_boundary(0), $N, "total right boundary is $N"); $num_tests++;

my $fifth_bin = $arr_bins->[4];
my $fifth_bin_again = $tree->bin(4);
ok($fifth_bin == $fifth_bin_again, "bin() works OK: ".$fifth_bin." and ".$fifth_bin_again); $num_tests++;

print "$0 : tree is\n".$tree."\n";
done_testing($num_tests);
1;
