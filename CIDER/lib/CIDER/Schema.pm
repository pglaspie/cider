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

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

