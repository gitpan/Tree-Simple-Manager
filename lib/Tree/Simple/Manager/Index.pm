
package Tree::Simple::Manager::Index;

use strict;
use warnings;

use Scalar::Util qw(blessed);

our $VERSION = '0.01';
    
use Tree::Simple::Manager::Exceptions;    
    
sub new {
    my ($_class, $tree) = @_;
    my $class = ref($_class) || $_class;
    my $index = {};
    bless($index, $class);
    $index->_init($tree);
    return $index;
}

sub _init {
    my ($self, $tree) = @_;
    (blessed($tree) && $tree->isa("Tree::Simple")) 
        || throw Tree::Simple::Manager::InsufficientArguments;
    # add our root
    $self->{root_tree} = $tree;
    $self->{index}     = {};
    # then add all its children on down
    $tree->traverse(sub {
        my ($tree) = @_;
        (!exists ${$self->{index}}{$tree->getUID()}) 
            || throw Tree::Simple::Manager::IllegalOperation "tree (" . $tree->getUID() . ") already exists in the index, cannot add a duplicate";        
        $self->{index}->{$tree->getUID()} = $tree;
    });
}

sub getIndexKeys {
    my ($self) = @_;
    my @keys = sort { $a <=> $b } keys %{$self->{index}};
    return wantarray ? @keys : \@keys;
}

sub getRootTree { (shift)->{root_tree} }

sub getTreeByID {
    my ($self, $id) = @_;
    (exists ${$self->{index}}{$id}) 
        || throw Tree::Simple::Manager::KeyDoesNotExist "tree ($id) does not exist in the index";        
    return $self->{index}->{$id};
}

1;

__END__

=head1 NAME

Tree::Simple::Manager::Index - A class for quick-access indexing for Tree::Simple hierarchies

=head1 SYNOPSIS

  use Tree::Simple::Manager::Index;
  
  my $index = Tree::Simple::Manager::Index->new($tree_hierarchy);  
  my $node_deep_in_the_tree = $index->getTreeByID(100134);

=head1 DESCRIPTION

This module will index a Tree::Simple hierarchy so that node's can be quickly accessed without needing to search the entire heirarchy. It currently will index the Tree::Simple nodes by their UID property. Plans for allowing other means of indexing are in the future.

=head1 METHODS

=over 4

=item B<new ($tree)>

Given a C<$tree> it will index all it's nodes by their UID values.

=item B<getIndexKeys>

This will return a list of all the index keys. 

=item B<getRootTree>

This will return the root of the indexed tree.

=item B<getTreeByID ($id)>

Given an C<$id> this will return the tree associated with it. If no tree is associated with it, an exeception will be thrown.

=back

=head1 TO DO

=over 4

=item I<Allow for alternate means of indexing trees>

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, see the L<Tree::Simple::Manager> documentation for more details.

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

