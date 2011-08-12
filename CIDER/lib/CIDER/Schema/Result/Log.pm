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

1;
