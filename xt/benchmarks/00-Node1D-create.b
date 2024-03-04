#!/usr/bin/env perl

use strict;
use warnings;

use Tree::AVL::Range::Node1D;
use Data::Dumper;

use Benchmark qw/timethese cmpthese :hireswallclock/;
use Test::More;

use constant VERBOSE => 1; # prints out several junk

srand time;

my $num_repeats = 1000;

print "$0 : benchmarks...\n";
# shamelessly ripped off App::Benchmark
cmpthese(timethese($num_repeats, {
	'Node1D, creating 1000 Node1D objs, repeats '.$num_repeats.':' => \&runme
}));
plan tests => 1;
pass('benchmark : '.__FILE__);

sub	runme {
	for(1..1000){
		my $B = Tree::AVL::Range::Node1D->new({
			'boundaries' => [rand(10),20+rand(10)],
			'label' => 'hello',
			'user-specified-data' => {'a'=>rand(), 'b'=>rand()},
			'user-specified-data-clone-function' => \&Clone::clone,
		});
	}
}
1;
__END__
