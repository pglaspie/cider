package CIDER::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::User

=cut

__PACKAGE__->table( 'user' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_columns(
    username =>
        { data_type => 'varchar', is_nullable => 0 },
    password =>
        { data_type => 'varchar', is_nullable => 0 },
);

__PACKAGE__->add_columns(
    staff =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    staff =>
        'CIDER::Schema::Result::Staff',
);

__PACKAGE__->has_many(
    sets =>
        'CIDER::Schema::Result::ObjectSet',
    'owner',
);

__PACKAGE__->has_many(
    map_user_role =>
        'CIDER::Schema::Result::UserRole',
    'user_id' );
__PACKAGE__->many_to_many(
    roles =>
        'map_user_role',
    'role' );

# sets_not_containing: Given a CIDER object, return the this users' sets which
# _don't_ contain that object.
sub sets_not_containing {
    my $self = shift;
    my ( $object ) = @_;

    # This isn't a very sexy way of doing this, and it won't scale well if
    # users build extremely large sets. In that case, come up with a sexy
    # way to do this in pure SQL, and then express it in DBIC.
    my $user_sets_rs = $self->sets;
    my $object_sets_rs = $object->sets;

    # I wanted to do it this way, but MySQL 5 doesn't support EXCEPT. :(
#    my $exceptions_rs = $user_sets_rs->except( $object_sets_rs );

    my @not_sets;
    my %object_is_in_set;

    while ( my $object_set = $object_sets_rs->next ) {
        $object_is_in_set{ $object_set->id } = 1;
    }

    while ( my $user_set = $user_sets_rs->next ) {
        unless ( $object_is_in_set{ $user_set->id } ) {
            push @not_sets, $user_set;
        }
    }

    return @not_sets;
}

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

1;
