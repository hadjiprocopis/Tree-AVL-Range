#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Tree::AVL::Range' ) || print "Bail out!\n";
}

diag( "Testing Tree::AVL::Range $Tree::AVL::Range::VERSION, Perl $], $^X" );
