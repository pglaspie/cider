package CIDER::Schema::Result::AuthorityName;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::AuthorityName

=cut

__PACKAGE__->table( 'authority_name' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    creator_item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    'name',
    { where => { role => 'creator' } }
);
__PACKAGE__->many_to_many(
    created_items =>
        'creator_item_authority_names',
    'item',
);

__PACKAGE__->has_many(
    personal_name_item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    'name',
    { where => { role => 'personal_name' } }
);
__PACKAGE__->many_to_many(
    personal_items =>
        'personal_name_item_authority_names',
    'item',
);

__PACKAGE__->has_many(
    corporate_item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    'name',
    { where => { role => 'corporate_name' } }
);
__PACKAGE__->many_to_many(
    corporate_items =>
        'corporate_item_authority_names',
    'item',
);

__PACKAGE__->has_many(
    item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    'name',
);
__PACKAGE__->many_to_many(
    items =>
        'item_authority_names',
    'item',
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    note =>
        { data_type => 'text', is_nullable => 1 },
);

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

# name_and_note: Convenience method that returns a string in this format:
#                 $name ($note)
#                 ...unless this name has no note, in which case, just the name.
sub name_and_note {
    my $self = shift;

    if ($self->note) {
        return sprintf "%s (%s)", $self->name, $self->note;
    }
    else {
        return $self->name;
    }
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
