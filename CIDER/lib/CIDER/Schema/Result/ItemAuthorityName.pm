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

1;
