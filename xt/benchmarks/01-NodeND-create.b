#!/usr/bin/env perl

use strict;
use warnings;

use Tree::AVL::Range::NodeND;
use Data::Dumper;

use Benchmark qw/timethese cmpthese :hireswallclock/;
use Test::More;

use constant VERBOSE => 1; # prints out several junk

srand time;

my $num_repeats = 1000;
my $NUM_DIMS = 7;

print "$0 : benchmarks...\n";
# shamelessly ripped off App::Benchmark
cmpthese(timethese($num_repeats, {
	"NodeND, creating 1000 NodeND objs of $NUM_DIMS dims, repeats ".$num_repeats.':' => \&runme
}));
plan tests => 1;
pass('benchmark : '.__FILE__);

sub	runme {
	for(1..1000){
		my @bounds = map { [rand(10),20+rand(10)] } 0..($NUM_DIMS-1);
		my $B = Tree::AVL::Range::NodeND->new({
			'boundaries' => \@bounds,
			'num-dimensions' => $NUM_DIMS,
			'label' => 'hello',
			'user-specified-data' => {'a'=>rand(), 'b'=>rand()},
			'user-specified-data-clone-function' => \&Clone::clone,
		});
	}
}
1;
__END__
