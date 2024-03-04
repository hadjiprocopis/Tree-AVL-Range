#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range::NodeND;
use Clone 'clone';

my ($got, $exp, $B1, $B2, $B3, $B4);
$B1 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'num-dimensions' => 2,
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
});
ok(defined($B1), "Tree::AVL::Range::NodeND->new() OK") or BAIL_OUT("call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B1.");

$B2 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'num-dimensions' => 2,
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
});
ok(defined($B2), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B2) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B2.\n"; exit(1) }
ok($B1==$B2, "Nodes are equal OK");
is($B1->compare($B2), 0, "Nodes compare 0 OK");
ok($B1->equals($B2), "Nodes equals() OK");
ok($B2->equals($B1), "Nodes equals() OK");

$B3 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[1,2],[1,2]],
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
	'num-dimensions' => 2,
});
ok(defined($B3), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B3) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B3.\n"; exit(1) }
is($B1->compare($B3), +1, "B1 on the left of B3");
is($B3->compare($B1), -1, "B3 on the right of B1");

$B4 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,2],[0,2]],
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
	'num-dimensions' => 2,
});
ok(defined($B4), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B4) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B4.\n"; exit(1) }
ok(!($B1->equals($B4)), "B1 not equal to B4");
is($B1->compare($B4), undef, "B1 entangled with B4 somehow");
is($B4->compare($B1), undef, "B4 entangled with B1 somehow");
is($B4->overlap($B1), 2, "B4 encloses B1 totally");
is($B1->overlap($B4), -2, "B1 is totally enclosed by B4");

# for overlap tests:
$B1 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'num-dimensions' => 2,
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
});
ok(defined($B1), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B1) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B1.\n"; exit(1) }
foreach(
	[[[-1,0],[-1,0]], 0],
	[[[-1,0.1],[-1,0.1]], -1],
	[[[-1,0.5],[-1,0.5]], -1],
	[[[0.5,0.7],[0.5,0.7]], 2],
	[[[0.7,1.0],[0.7,1.0]], 2],
	[[[0.7,1.2],[0.7,1.2]], 1],
	[[[1.0,1.2],[1.0,1.2]], 0],
	[[[1.1,1.2],[1.1,1.2]], 0],
	[[[-1,3],[-1,3]], -2],
	[[[0,1],[0,1]], 3],
	[[[1.2,1.5],[1.2,1.5]], 0],
){
	$B2 = Tree::AVL::Range::NodeND->new({
		'boundaries' => $_->[0],
		'num-dimensions' => 2,
	});
	if( ! defined($B2) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B2 (loop1).\n"; exit(1) }
	ok(defined($B2), "Tree::AVL::Range::NodeND->new() OK");
	is($B1->overlap($B2), $_->[1], "overlap test ".$B1." overlaps with ".$B2." expecting ".$_->[1]);
	if( ! $B1->equals($B2) ){
		is($B2->overlap($B1), -$_->[1], "overlap test (reciprocal to above) ".$B2." overlaps with ".$B1." expecting ".(-$_->[1]));
	}
}
# for compare tests:
$B1 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'num-dimensions' => 2,
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
});
ok(defined($B1), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B1) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B1.\n"; exit(1) }
foreach(
	[[[-1,0],[-1,0]], -1],
	[[[-1,0.1],[-1,0.1]], undef],
	[[[-1,0.5],[-1,0.5]], undef],
	[[[0.5,0.7],[0.5,0.7]], undef],
	[[[0.7,1.0],[0.7,1.0]], undef],
	[[[0.7,1.2],[0.7,1.2]], undef],
	[[[1.0,1.2],[1.0,1.2]], 1],
	[[[1.1,1.2],[1.1,1.2]], 1],
	[[[-1,3],[-1,3]], undef],
	[[[0,1],[0,1]], 0],
	[[[1.2,1.5],[1.2,1.5]], 1],
){
	$B2 = Tree::AVL::Range::NodeND->new({
		'boundaries' => $_->[0],
		'num-dimensions' => 2,
	});
	if( ! defined($B2) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B2 (loop2).\n"; exit(1) }
	ok(defined($B2), "Tree::AVL::Range::NodeND->new() OK");
	$got = $B1->compare($B2);
	$exp = $_->[1];
	is($got, $_->[1], "compare test ".$B1." compared with ".$B2." expecting ".(defined($exp)?$exp:'undef'));
	if( defined($exp) ){
		is($B2->compare($B1), -$_->[1], "compare test (reciprocal of the above) ".$B1." compared with ".$B2." expecting ".(defined($exp)?$exp:'undef'));
	}
}
# for contains and compare_scalar() tests:
$B1 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'num-dimensions' => 2,
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
});
ok(defined($B1), "Tree::AVL::Range::NodeND->new() OK");
if( ! defined($B1) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->new()'." has failed, B1.\n"; exit(1) }
foreach(
	[[-1,-1],-1],
	[[0,0], 0],
	[[0.1,0.1], 0],
	[[0.9999,0.9999], 0],
	[[1.0,1.0], 1],
	[[2,2], 1],
){
	is($B1->compare_scalar($_->[0]), $_->[1], "compare_scalar() : compares with scalar [".join(",",@{$_->[0]}).'], expects : '.$_->[1]);
	is($B1->contains($_->[0]), $_->[1]==0, "contains() : contains scalar [".join(",",@{$_->[0]}).'], expects : '.$_->[1]);
}

# clone
$B1 = Tree::AVL::Range::NodeND->new({
	'boundaries' => [[0,1],[0,1]],
	'label' => 'hello',
	'user-specified-data' => {'a'=>12, 'b'=>13},
	'user-specified-data-clone-function' => \&Clone::clone,
	'num-dimensions' => 2,
});
$B2 = $B1->clone();
if( ! defined($B2) ){ print STDERR "$0 : call to ".'Tree::AVL::Range::NodeND->clone()'." has failed, B2 (clone).\n"; exit(1) }
ok(defined($B2), "clone() returned ok");
ok($B2->equals($B1), "clone correct");
ok(defined($B2->user_specified_data()), "clone() succeded in cloning user-specified-data");
ok($B2->user_specified_data()!=$B1->user_specified_data(), "cloned user-specified-data too!");

is($B2->user_specified_data()->{'a'}, 12, "clone OK");
$B1->user_specified_data()->{'a'} = 'xxxxxx';
is($B2->user_specified_data()->{'a'}, 12, "clone OK");
ok($B2->label() eq $B1->label(), "cloned labels too");
is($B2->num_dimensions(), $B1->num_dimensions(), "cloned num-dimensions same");

done_testing();
