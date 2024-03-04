use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

sub MY::postamble {
	my (undef,%h) = @_;
	require Data::Dumper;
	#print STDERR Data::Dumper->Dump([\%h], [qw(mm_args{postamble})]);
	return "BENCHMARK_FILES=$h{BENCHMARK_FILES}\n"
	. <<'POSTAMBLE';
#bench :: benchmarks/*.b
TEST_D = $(ABSPERLRUN) -MExtUtils::Command -e test_d --

# run author-tests on the original
authtest ::
	$(TEST_D) xt && $(MAKE) test TEST_FILES='xt/*.t'

bench :: $(BENCHMARK_FILES)
	prove --blib $(INST_LIB) --blib $(INST_ARCHLIB) --verbose $^

bench2 :: $(BENCHMARK_FILES)
	$(TEST_D) xt && $(MAKE) test TEST_FILES='$(BENCHMARK_FILES)'
POSTAMBLE
}

WriteMakefile(
	INSTALL_BASE	  => "$ENV{HOME}/usr",
	NAME		 => 'Tree::AVL::Range',
	AUTHOR	   => q{Andreas Hadjiprocopis <bliako@cpan.org>},
	VERSION_FROM	 => 'lib/Tree/AVL/Range.pm',
	ABSTRACT_FROM	=> 'lib/Tree/AVL/Range.pm',
	LICENSE	  => 'artistic_2',
	PL_FILES	 => {},
	MIN_PERL_VERSION => '5.006',
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => '0',
	},
	BUILD_REQUIRES => {
		'Test::More' => '0',
	},
	PREREQ_PM => {
		'Clone' => '0',
		'Tree::AVL' => '0',
		'Data::Roundtrip' => '0',
		'Carp' => '0',
	},
	TEST_REQUIRES => {
		'Math::Cartesian::Product' => '0',
		'Clone' => '0',
	},
	dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES => 'Tree-AVL-Range-*' },
	postamble => { BENCHMARK_FILES => 'xt/benchmarks/*.b' }
);
