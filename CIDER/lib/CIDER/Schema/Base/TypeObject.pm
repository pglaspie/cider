package CIDER::Schema::Base::TypeObject;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use CIDER::Logic::Utils qw( iso_8601_date );
use Regexp::Common qw( URI );

=head1 NAME

CIDER::Schema::Result::Base::TypeObject

=head1 DESCRIPTION

Generic base class for type-specific field objects, i.e. Collection,
Series, and Item.

=cut



sub setup_object {
    my ( $class ) = @_;

    $class->add_column(
        id => {
            data_type => 'int',
            is_foreign_key => 1,
        }
    );
    $class->set_primary_key( 'id' );
    $class->belongs_to(
        object => 'CIDER::Schema::Result::Object',
        'id',
    );
}

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    unless ( $self->object->created_by ) {
        # The object was just created, so log its creation and add it
        # to the index.

        $self->object->created_by( $self->result_source->schema->user );

        $self->result_source->schema->indexer->add( $self->object );
    }
    else {
        # Otherwise, we're just changing the object's type; treat it
        # as an update.
        $self->_update;
    }

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->_update;

    return $self;
}

sub _update {
    my $self = shift;

    $self->object->add_to_modification_logs( {
        user => $self->result_source->schema->user
    } );

    $self->result_source->schema->indexer->update( $self->object );

    # TO DO: typically both the object and the type object will be
    # updated at once, which leads to two update log entries; it would
    # be nice to coalesce these.
}

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    # Convert all empty strings to nulls.
    $value = undef if defined( $value ) && $value eq '';

    if ( defined( $value ) ) {
        # TO DO: need better way of determining these column types...
        if ( $column =~ /date/ ) {
            $self->throw_exception( "$column must be ISO-8601 format" )
                unless iso_8601_date( $value );
        }
        elsif ( $column =~ /url/ ) {
            $self->throw_exception( "$column must be HTTP or HTTPS URI" )
                unless $RE{URI}{HTTP}{ -scheme => 'https?' }->matches( $value );
        }
    }

    return $self->next::method( $column, $value );
}

1;
