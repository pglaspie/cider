package CIDER::Schema::Result::AuditTrail;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use Carp qw( croak );

=head1 NAME

CIDER::Schema::Result::AuditTrail

=cut

__PACKAGE__->table( 'audit_trail' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->might_have(
    object =>
        'CIDER::Schema::Result::Object',
    { 'foreign.audit_trail' => 'self.id' },
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->might_have(
    record_context =>
        'CIDER::Schema::Result::RecordContext',
    { 'foreign.audit_trail' => 'self.id' },
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->has_many(
    logs =>
        'CIDER::Schema::Result::Log',
    'audit_trail',
);

__PACKAGE__->has_one(
    creation_log =>
        'CIDER::Schema::Result::Log',
    'audit_trail',
    { where => { action => 'create' },
      proxy => {
          created_by => 'staff',
          date_created => 'date',
      },
    },
);

__PACKAGE__->has_many(
    modification_logs =>
        'CIDER::Schema::Result::Log',
    'audit_trail',
    { where => { action => 'update' } },
);

__PACKAGE__->has_many(
    export_logs =>
        'CIDER::Schema::Result::Log',
    'audit_trail',
    { where => { action => 'export' } },
);

sub date_available {
    my $self = shift;

    my $rs = $self->export_logs->search( undef, {
        order_by => { -desc => 'timestamp' }
    } );
    return $rs->first->date;
}

sub delete {
    my $self = shift;

    $_->delete for $self->logs;

    $self->next::method( @_ );

    return $self;
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
