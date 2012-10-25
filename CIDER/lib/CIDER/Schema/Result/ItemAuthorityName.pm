package CIDER::Schema::Result::ItemAuthorityName;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::ItemAuthorityName

=cut

__PACKAGE__->table( 'item_authority_name' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    item =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    item =>
        'CIDER::Schema::Result::Item',
);

__PACKAGE__->add_columns(
    role =>
        { data_type => 'enum',
          extra => { list => [ qw( creator personal_name corporate_name ) ] } },
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    name =>
        'CIDER::Schema::Result::AuthorityName',
);

sub name_and_note {
    my $self = shift;

    return $self->name->name_and_note;
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
