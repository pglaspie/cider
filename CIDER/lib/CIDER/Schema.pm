package CIDER::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-02 16:49:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9E4noPv7F0YFb1t8JbIGlg

use CIDER::Logic::Indexer;

# The 'user' field is used when adding to the audit trail.  Make sure
# it's set before inserting or updating any objects!

__PACKAGE__->mk_classdata( 'user' );

# The 'search_index' field is initialized from the
# CIDER::Model::CIDERDB config using the SchemaProxy trait.

__PACKAGE__->mk_group_accessors( simple => qw(
    search_index
) );

sub indexer {
    my $self = shift;

    return CIDER::Logic::Indexer->new(
        schema => $self,
        path_to_index => $self->search_index,
    );
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

