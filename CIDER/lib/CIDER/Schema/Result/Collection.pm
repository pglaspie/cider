package CIDER::Schema::Result::Collection;

use strict;
use warnings;

use base 'CIDER::Schema::Result::Object';

=head1 NAME

CIDER::Schema::Result::Collection

=cut

__PACKAGE__->table("object");

__PACKAGE__->add_columns(
);

=head1 METHODS

=head2 required_fields

An array of required fields for this class.

=cut

sub required_fields {
    my $class = shift;

    return ( $class->next::method( @_ ),
             qw( processing_status has_physical_documentation ) );
}

1;
