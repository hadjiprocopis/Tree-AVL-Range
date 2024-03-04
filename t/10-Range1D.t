#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range;

my $R1 = Tree::AVL::Range->new({
	'num-dimensions' => 1,
});
ok(defined($R1), "Tree::AVL::Range->new() OK") or BAIL_OUT("call to ".'Tree::AVL::Range->new()'." has failed, R1.");
print $R1."\n";

done_testing();
1;
