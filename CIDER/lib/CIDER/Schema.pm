package CIDER::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

use CIDER::Logic::Indexer;
use File::Spec;


__PACKAGE__->load_namespaces;

# The 'user' field is used when adding to the audit trail.  Make sure
# it's set to a Result::User object before inserting or updating any objects!

# The 'search_index' field is initialized from the
# CIDER::Model::CIDERDB config using the SchemaProxy trait.

__PACKAGE__->mk_group_accessors( simple => qw(
    user
    search_index
    _indexer
) );

sub indexer {
    my $self = shift;

    my $indexer = $self->_indexer;
    unless ( $indexer ) {
        $indexer = CIDER::Logic::Indexer->new(
            schema => $self,
            path_to_index => $self->search_index,
        );
        $self->_indexer( $indexer );
    }

    return $indexer;
}

sub ddl_filename {
    my $self = shift;
    my ( $version, $db, $dir ) = @_;

    return File::Spec->catfile( $dir, 'cider.sql' );
}

1;

=head1 NAME

CIDER::Schema - DBIx schema.

=head1 DESCRIPTION

The DBIx database schema for CIDER.

=head1 METHODS

=head2 indexer

Returns an instance of L<CIDER::Logic::Indexer>.

=head1 AUTHORS

Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

