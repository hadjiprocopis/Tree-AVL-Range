#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;
use Math::Cartesian::Product;

use Tree::AVL::Range;

my $NDIMS = 3;
my $tree = Tree::AVL::Range->new({
	'num-dimensions' => $NDIMS,
});
ok(defined($tree), "Tree::AVL::Range->new() OK") or BAIL_OUT("call to ".'Tree::AVL::Range->new()'." has failed.");

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
	ok(defined($B), "make_node_and_add() OK") or BAIL_OUT("call to make_node_and_add() has failed.");
	push(@inserts, $B);
} @bwall;
print "Here is the final tree:\n".$tree."\n";

my ($i);
print "Done inserts, now checking if 2.1 is contained in tree (it must)\n";
my $obj = $tree->contains([2.1, 2.1, 2.1]);
ok(defined($obj), "found item 2.1 belongs to tree correctly");
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 2, "left boundary dim $i is 2");
	is($obj->right_boundary($i), 3, "right boundary dim $i is 3");
}
$obj = $tree->contains([0.1, 0.1, 0.1]);
ok(defined($obj), "found item 0.1 belongs to tree correctly");
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 0, "left boundary dim $i is 0");
	is($obj->right_boundary($i), 1, "right boundary dim $i is 1");
}
$obj = $tree->contains([9.1, 9.1, 9.1]);
ok(defined($obj), "found item 9.1 belongs to tree correctly");
for($i=0;$i<$NDIMS;$i++){
	is($obj->left_boundary($i), 9, "left boundary dim $i is 9");
	is($obj->right_boundary($i), 10, "right boundary dim $i is 10");
}
$obj = $tree->contains([10.1, 10.1, 10.1]);
ok(!defined($obj), "item does not belong to tree: correctly");
$obj = $tree->contains([-0.1, -0.1, -0.1]);
ok(!defined($obj), "item does not belong to tree: correctly");

my $arr_bins = $tree->to_array();
print "The bins as an ordered array:\n\t".join("\n\t", @$arr_bins)."\n";
is($arr_bins->[0]->left_boundary(0), 0, "total left boundary is 0");
is($arr_bins->[-1]->right_boundary(0), $N, "total right boundary is $N");

my $fifth_bin = $arr_bins->[4];
my $fifth_bin_again = $tree->bin(4);
ok($fifth_bin == $fifth_bin_again, "bin() works OK: ".$fifth_bin." and ".$fifth_bin_again);

print "$0 : tree is\n".$tree."\n";
done_testing();
1;
