package Tree::AVL::Range;

use 5.006;
use strict;
use warnings;

use Carp;
use Data::Roundtrip qw/perl2dump perl2json no-unicode-escape-permanently/;

use Tree::AVL::Range::Node1D;
use Tree::AVL::Range::NodeND;

use base qw/Tree::AVL/;

use constant DEBUG => 1;

use overload
	'""' => \&stringify
;

# remember that each node stores Range::Node objs
# which have their own compare sub
sub	new {
	my $class = $_[0];
	my $params = $_[1];
	my $self = $class->SUPER::new(
		'fcompare' => sub($;$){
			# compare a node with another, i.e. their range-boundaries
			# depending on this comparison nodes will be placed on the tree
			return $_[0] <=> $_[1]
		},
		'fcompare_scalar' => sub($;$){
			# will check if a scalar (x=$_[1]) falls within a bin($_[0])
			# by checking if LB <= x < RB
			return $_[0]->compare_scalar($_[1]);
		},
	);
	if( ! defined($self) ){ carp 'Tree::AVL::Range->new()'." : call to $class->SUPER::new() has failed."; return undef }
	bless($self, $class);

	if( defined($params) ){
		my $m;
		if( defined($m=$params->{'fget_key'}) ){ $self->{'fget_key'} = $m }
		else {
			$self->{'fget_key'} = sub($){ return $_[0] }
		}

		if( defined($m=$params->{'fget_value'}) ){ $self->{'fget_value'} = $m }
		else {
			$self->{'fget_value'} = sub($){ return $_[0]->data() }
		}
		if( defined($m=$params->{'num-dimensions'}) ){ $self->{'num-dims'} = $m; }
	} else {
		$self->{'num-dims'} = 1
	}
	# more setup
	if( $self->{'num-dims'} > 1 ){
		$self->{'node-type'} = __PACKAGE__.'::NodeND'
	} else {
		$self->{'node-type'} = __PACKAGE__.'::Node1D'
	}
	$self->{'new-node-sub'} = $self->{'node-type'}->can('new');
	if( ! defined($self->{'new-node-sub'}) ){ carp 'Tree::AVL::Range->new()'." : specified node type '".$self->{'node-type'}."' does not provide a new(), something is seriously wrong...\n"; return undef }

	$self->{'num-nodes'} = 0;
	return $self
}
# returns created-and-added node on success,
# returns undef on failure (e.g. wrong params)
#           or if overlapping wrt boundaries exists
sub	make_node_and_add {
	my ($self, $params) = @_;

	if( ! defined($params) || (ref($params) ne 'HASH') ){ carp 'Tree::AVL::Range::make_node_and_add()'." : input parameters in the form of a hashref were not specified."; return undef }
	$params->{'num-dimensions'} = $self->{'num-dims'};
	# create the node object by calling the subref with these params
	my $bi = $self->{'new-node-sub'}->($self->{'node-type'}, $params);

	if( ! defined($bi) ){ carp 'Tree::AVL::Range::make_node_and_add()'." : call to $self->{'new-node-sub'} has failed for params:\n".perl2dump($params); return undef }
	my $ret = $self->add_node($bi);
	if( $ret != 1 ){
		carp 'Tree::AVL::Range::make_node_and_add()'." : call to ".'add_node()'." has failed for node ".$bi;
		return undef
	}
	if( DEBUG ){ carp 'Tree::AVL::Range::make_node_and_add()'." : created and added node ".$bi."\n" }
	return $bi # returns the created bin
}
# adds an already existing bin
# return 0 on failure (e.g. overlapping boundaries)
# return 1 on success
sub	add_node {
	my ($self, $abin) = @_;

	# check if lb or rb falls within any other bin
	my $m;
# TODO: check if node-to-be-added overlaps any existing:
#	if( defined($m=$self->contains($abin->left_boundary())) ){ carp 'Tree::AVL::Range::add_node()'." : bin to insert ".$abin." overlaps with already existing bin: ".$m; return 0 }
#	if( defined($m=$self->contains($abin->right_boundary())) ){ carp 'Tree::AVL::Range::add_node()'." : bin to insert ".$abin." overlaps with already existing bin: ".$m; return 0 }

	# bin to be inserted does not overlap
	# parent's insert croaks instead of returning error, so:
	eval { $self->insert($abin) };
	if( $@ ){ carp 'Tree::AVL::Range::add_node()'." : call to insert() has failed for bin: ".$abin." : $@"; return 0 };

	$self->{'num-nodes'}++;
	return 1; # success
}
sub	num_dimensions { return $_[0]->{'num-dims'} }
sub	num_nodes { return $_[0]->{'num-nodes'} }

# check which bin the input scalar value belongs to
# based on LB <= x < RB
sub	contains {
	my ($self, $scalar) = @_;
	return $self->SUPER::lookup($scalar, $self->{'fcompare_scalar'});
}
sub	has_bin {
	my ($self, $scalar) = @_;
	return $self->SUPER::lookup($scalar, $self->{'fcompare'});
}
sub	bin {
	my ($self, $index) = @_;

	my $it = $self->iterator('>');
	while( $it->() && --$index ){};
	return $it->();
}
sub	to_array {
	my $self = $_[0];
	my $n = $self->{'num-nodes'};
	my @ret = (undef)x$n;

	my $it = $self->iterator('>'); # reverse because compare is vice versa
	my $i;
	for($i=0;$i<$n;$i++){
		$ret[$i] = $it->();
	}
	return \@ret;
}
sub	stringify {
	# this is so stupid, we are copy-pasting parent's print()
	# because it prints to stdout instead to a string!
    my ($self, $char, $o_char, $node, $depth) = @_;

	$char = "    " unless defined($char);
	my $ret = "";
    if(!$node && !defined($depth)){       
	$node = $self->{_node};
    }
    if(!$depth){ $depth = 0; }
    if(!$o_char){
	$o_char = $char;
    }
           
    my $key = $self->get_key($node);
    my $data = $self->get_data($node);

    if(!defined($self->{_node}->{_obj})){
	$ret .= "tree is empty.";
	return $ret;
    }

    if(!defined($key)){
	croak "get_key() function provided to Tree::AVL object returned a null value\n";
    }
    if(!defined($data)){
	$data = "";
    }

    $ret .= $char . $key . ": " . $data;
    $ret .= ": height: " . $self->get_height($node) . ": balance: " . $node->{_balance} . "\n";

    if($node->{_left_node}){
	my $leftnode = $node->{_left_node};
	$ret .= Tree::AVL::Range::stringify($self, $char . $o_char, $o_char, $leftnode, $depth+1);
    }
    if($node->{_right_node}){
	my $rightnode =  $node->{_right_node};
	$ret .= Tree::AVL::Range::stringify($self, $char . $o_char, $o_char, $rightnode, $depth+1);
    }
    return $ret
}

=head1 NAME

Tree::AVL::Range - The great new Tree::AVL::Range!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tree::AVL::Range;

    my $foo = Tree::AVL::Range->new();
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

    perldoc Tree::AVL::Range


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

1; # End of Tree::AVL::Range
