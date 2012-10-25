package CIDER::Schema::Result::Log;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components( qw( InflateColumn::DateTime TimeStamp ) );

=head1 NAME

CIDER::Schema::Result::Log

=cut

__PACKAGE__->table( 'log' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    audit_trail =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    audit_trail =>
        'CIDER::Schema::Result::AuditTrail',
);

__PACKAGE__->add_columns(
    action =>
        { data_type => 'enum',
          extra => { list => [ qw(create update export) ] } },
    timestamp =>
        { data_type => 'datetime', set_on_create => 1 },
);

__PACKAGE__->add_columns(
    staff =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    staff =>
        'CIDER::Schema::Result::Staff',
    undef,
    { proxy => 'user' }
);

sub date {
    my $self = shift;

    return $self->timestamp->truncate( to => 'day' );
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
