This module implements the idea of a binary tree with range checks.

Each node represents a numerical range. For
example the range: [3:4].
Each node can have up to 2 child nodes (binary tree). The Left node
represents all those numbers who fall outside the range and on the left
of the input range (that's the less operator (<) in 1D). The Right node
represents the numbers who fall to the right of the input space (>).

This data structure is known as a [segment tree](https://en.wikipedia.org/wiki/Segment_tree).

Here is an example use-case:
```
#!/usr/bin/env perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Tree::AVL::Range;

my $num_tests = 0;

my $tree = Tree::AVL::Range->new();
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
	if( ! defined($B) ){ print STDERR "$0 : call to make_node_and_add() has failed.\n"; exit(1) }
	push(@inserts, $B);
}
print "Here is the final tree:\n".$tree."\n";

print "Done inserts, now checking if 2.1 is contained in tree (it does)\n";
my $obj = $tree->contains(2.1);
if( defined($obj) ){ print "found item 2.1 belongs to tree.\n"; }

my $arr_bins = $tree->to_array();
print "The bins as an ordered array:\n\t".join("\n\t", @$arr_bins)."\n";
```

Please note that this software is not ready for production, it's just
a rough sketch of a concept still.

INSTALLATION

```perl Makefile.PL && make install```

run some tests: ```make test```
run some benchmarks (a few minutes): ```make bench```


Author: Andreas Hadjiprocopis

contact: ```$email{'google.com'} = 'andreashad2';```

contact: ```$email{'cpan.org'} = 'bliako';```

licence: GPLv3

date: 21/06/2018

Hugs: Almaz!
