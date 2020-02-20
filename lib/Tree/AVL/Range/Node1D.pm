package Tree::AVL::Range::Node1D;

use 5.006;
use strict;
use warnings;

use Carp;
use Data::Dump qw/dump/;

our $VERSION = '0.01';

use constant DEBUG => 1;
use constant FATAL => 0;

use overload
	'==' => \&equals,
	'""' => \&stringify,
	'<=>' => \&compare, # BEWARE compare returns undef if ranges overlap
;

sub	new {
	my ($class, $params) = @_;
	$params = {} unless defined($params);

	my $parent = ( caller(1) )[3] || "N/A";
	my $whoami = ( caller(0) )[3];

	my $self = {
		# numerical boundaries of 1D comprising of [left-b, right-b]
		'b' => [undef, undef],
		'l' => '', # a label, default is empty
		# user specified data ref
		# can be a hash, array or an object (blessed hash)
		'ud' => undef,

		# function to call when self->clone() is called in order to clone ud
		# if ud is an object and already has clone() you must specify
		# cloner as \&X::Y::Z::clone
		'ud-clone-function' => undef,
		# internal stuff
		'_str' => undef, # string to print each time stringify is called
	};
	bless($self, $class);

	if( ! defined($params) ){ carp 'Tree::AVL::Range::Node1D::new()'." : input parameter 'boundaries' is required as a ".'[$;$]'.".\n"; return undef }

	my $m;
	if( defined($m=$params->{'boundaries'}) ){
		if( $m->[0] > $m->[1] ){ carp 'Tree::AVL::Range::Node1D::new()'." : condition on Range boundaries LB <= RB is not satisfied for LB=".$m->[0]." and RB=".$m->[1]."\n"; return undef }
		$self->{'b'}->[0] = $m->[0];
		$self->{'b'}->[1] = $m->[1];
	} else { carp 'Tree::AVL::Range::Node1D::new()'." : input parameter 'boundaries' was not specified.\n"; return undef }
	if( defined($m=$params->{'user-specified-data'}) ){ $self->set_user_specified_data($m) }
	if( defined($m=$params->{'user-specified-data-clone-function'}) ){ $self->set_user_specified_data_clone_function($m) }

	# set label will also recalculate:
	if( defined($m=$params->{'label'}) ){ $self->set_label($m) }
	else { $self->_recalculate() }
	return $self
}
# check if specified scalar is within the boundaries of this range
sub	contains { return $_[0]->compare_scalar($_[1])==0 }

# checks if scalar input param belongs to the interval
# specified by left- and right-boundaries of the Range
# using LB <= x < RB
# if non-numeric turned on then it checks if label is the same
# as input wrt string compare.
# returns -1 if scalar is outside the boundaries and on the left
# returns +1 if outside and on the right
# returns 0 if inside
sub	compare_scalar {
	my $self = $_[0];
	my $m = $_[1];
	if( DEBUG == 1 ){ carp 'Tree::AVL::Range::Node1D::compare_scalar()'." : checking numerically if (".$self->{'b'}->[0]." <= $m < ".$self->{'b'}->[1]."). Result is ".((($self->{'b'}->[0] <= $m)&&($m < $self->{'b'}->[1]))?'true':'false') }
	if( $m < $self->{'b'}->[0] ){ return -1 }
	elsif( $m >= $self->{'b'}->[1] ){ return 1 }
	return 0; # in range
}
# compare self with another obj (Range::Node*)
# the meaning of this comparison is
# returns -1 if range of other Range::Node lies on the left of us without any overlaps
# returns +1 ditto but on the right
# returns  0 if the nodes have exactly the same boundaries
# returns  undef if the nodes somehow overlap, either one totally inside or enclosing
#            the other or one enclosing one of the boundaries of the other

# for comparing with a scalar check compare_scalar()
sub	compare {
	my ($self, $b) = @_;

	if( DEBUG == 1 ){ if( ref($b) ne __PACKAGE__ ){ confess "input parameter must be of type ".__PACKAGE__." and not '".ref($b)."'.\n" } }

	# numerical, boundaries based comparison
	my $a0 = $self->{'b'}->[0];
	my $a1 = $self->{'b'}->[1];
	my $b0 = $b->left_boundary();
	my $b1 = $b->right_boundary();
	if( ($a0==$b0) && ($a1==$b1) ){
		if( DEBUG == 1 ){ carp 'Tree::AVL::Range::Node1D::compare()'." : ".$self." == ".$b."\n" }
		return 0
	}
	if( ($a0<$b0) && ($a1<=$b0) ){
		# we are less than input
		if( DEBUG == 1 ){ carp 'Tree::AVL::Range::Node1D::compare()'." : ".$self." < ".$b."\n" }
		return 1
	}
	if( ($a0>=$b1) && ($a1>$b1) ){
		# we are greater than input
		if( DEBUG == 1 ){ carp 'Tree::AVL::Range::Node1D::compare()'." : ".$self." > ".$b."\n" }
		return -1
	}
	if( DEBUG == 1 ){ carp 'Tree::AVL::Range::Node1D::compare()'." : numerical comparisons have holes because of nodes' boundaries overlap for ".$self." and ".$b."\n"; }
	if( FATAL == 1 ){ croak "and can not continue" }
	return undef
}

# check if input node overlaps with self
# meaning that at least one boundary is within the
# other node
# returns -1 if b encloses left-b of self only
# returns +1 if b encloses right-b of self only
# returns 0 if no overlap
# returns -2 if if b encloses self totally
# returns +2 if self encloses b totally
# returns +3 if equal
# encloses means lb <= and rb <
sub	overlap {
	my ($self, $b) = @_;

	if( $self->equals($b) ){ return 3 }

	my $a0 = $self->{'b'}->[0];
	my $a1 = $self->{'b'}->[1];
	my $b0 = $b->left_boundary();
	my $b1 = $b->right_boundary();

	if( DEBUG == 1 ){
		print "overlap() :\n\ta0=$a0, a1=$a1\n\tb0 = $b0, b1=$b1\n";
	}

	if( ($a1 <= $b0) || ($b1 <= $a0) ){ return 0 }

	if( ($a0 < $b0) && ($a1 >= $b0) ){
		print "overlap() : (1) ($a0 < $b0) && ($a1 >= $b0)\n";
		if( $a1 < $b1 ){ return 1 }
		return 2
	}
	if( ($b0 < $a0) && ($b1 >= $a0) ){
		print "overlap() : (2) ($b0 < $a0) && ($b1 >= $a0)\n";
		if( $b1 < $a1 ){ return -1 }
		return -2
	}

	if( ($b0 <= $a0) && ($b1 >= $a1) ){ return -2 }
	if( ($a0 <= $b0) && ($a1 >= $b1) ){ return  2 }

	croak 'overlap() '.": case not covered self=($a0,$a1) and ($b0,$b1)";
	if( FATAL == 1 ){ croak "and can not continue" }
	return 0
}
sub	left_boundary { return $_[0]->{'b'}->[0] }
sub	right_boundary { return $_[0]->{'b'}->[1] }
sub	boundaries { return $_[0]->{'b'} }
sub	label { return $_[0]->{'l'} }
sub	set_label {
	my $self = $_[0];
	$self->{'l'} = $_[1];
	$self->_recalculate();
}
sub	_recalculate {
	my $self = $_[0];
	$self->{'_str'} = $self->left_boundary()
			.':'. $self->right_boundary()
	;
	if( $self->{'l'} ne '' ){ $self->{'_str'} .= '/"'.$self->{'l'}.'"' }
}
# specify user-specified-data (optional)
sub	user_specified_data { return $_[0]->{'ud'} }
sub	set_user_specified_data { $_[0]->{'ud'} = $_[1] }
# specify a function (optional) to call it every time clone()
# is called so to clone our user-spec data
sub	user_specified_data_clone_function { return $_[0]->{'ud-clone-function'} }
sub	set_user_specified_data_clone_function { $_[0]->{'ud-clone-function'} = $_[1] }

# returns true or false if input node has the same boundaries
# as self (not counts or anything else)
sub	equals {
	my ($self, $b) = @_;
	# compare may return also undef if overlap
	my $ret = $self->compare($b);
	return defined($ret) && ($self->compare($b) == 0)
}
sub	clone {
	my $self = $_[0];

	my %config = (
		'boundaries' => [$self->{'b'}->[0], $self->{'b'}->[1]],
		'label' => $self->label(),
		'user-specified-data-clone-function' => $self->user_specified_data_clone_function(),
	);
	my $asub;
	if( defined($asub=$self->{'ud-clone-function'}) ){
		$config{'user-specified-data'} = $asub->($self->{'ud'}); # <<< note we pass asub's self as well as the ud
		if( ! defined($config{'user-specified-data'}) ){ carp 'Tree::AVL::Range::Node1D::clone()'." : failed to clone the user-specified data which is of type ".ref($self->{'ud'}); return undef }
	}
	my $newa = Tree::AVL::Range::Node1D->new(\%config);
	if( ! defined($newa) ){ carp 'Tree::AVL::Range::Node1D::clone()'." : call to ".'Tree::AVL::Range::Node1D->new()'." has failed for config: ".@{[%config]}; return undef }
	return $newa # success
}
sub	stringify {
	my $self = $_[0];

	return '['.$self->{'_str'}.']'
		# assuming that user has overloaed the print via a custom-made stringify
		.(defined($self->{'ud'}) ?
			     ' = '.Data::Dump::dump($self->{'ud'})
			   : ''
		)
}

=head1 NAME

Tree::AVL::Range::Node1D - A data structure for a Bin, data to be stored at every node of Tree::AVL::Bins

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tree::AVL::Range::Node1D;

    my $foo = Tree::AVL::Range::Node1D->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Andreas Hadjiprocopis, C<< <bliako at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tree-avl-bins at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tree-AVL-Bins>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tree::AVL::Range::Node1D


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tree-AVL-Bins>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tree-AVL-Bins>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tree-AVL-Bins>

=item * Search CPAN

L<http://search.cpan.org/dist/Tree-AVL-Bins/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2018 Andreas Hadjiprocopis.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Tree::AVL::Range::Node1D
