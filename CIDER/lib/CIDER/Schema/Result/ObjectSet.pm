package CIDER::Schema::Result::ObjectSet;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use Carp qw(croak);

=head1 NAME

CIDER::Schema::Result::ObjectSet

=cut

__PACKAGE__->table( 'object_set' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);

__PACKAGE__->add_columns(
    owner =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    owner =>
        'CIDER::Schema::Result::User',
    'owner',
);

__PACKAGE__->has_many(
    object_set_objects =>
        'CIDER::Schema::Result::ObjectSetObject',
    'object_set',
);
__PACKAGE__->many_to_many(
    objects =>
        'object_set_objects',
    'object',
);

sub delete {
    my $self = shift;

    for my $link ( $self->object_set_objects ) {
        $link->delete;
    }

    return $self->next::method( @_ );
}

sub add {
    my $self = shift;
    my ( $object_to_add ) = @_;

    $self->add_to_objects( $object_to_add->object );
}

sub remove {
    my $self = shift;
    my ( $object_to_remove ) = @_;

    my ( $link ) = $self->object_set_objects->search (
        {
            object => $object_to_remove->id,
            object_set => $self->id,
        }
    );

    if ( $link ) {
        $link->delete;
    }
    else {
        warn "Attempt to remove object "
            . $object_to_remove->id
            . "from set "
            . $self->id
            . ", but it doesn't appear to be a member.";
    }
}

sub is_homogenous {
    my $self = shift;

    my $last_object_type = undef;
    for my $object ( $self->objects ) {
        if ( not $last_object_type ) {
            $last_object_type = $object->type;
        }
        elsif ( $last_object_type ne $object->type ) {
            return 0;
        }
    }

    return 1;
}

sub type {
    my $self = shift;

    return $self->objects->first->type;
}

sub type_plural {
    my $self = shift;
    my ( $count ) = @_;

    $count = $self->count unless defined( $count );
    return $self->type . ( $count == 1 ? '' : 's' );
}

sub count {
    my $self = shift;

    return $self->objects->count;
}

sub search_in_field {
    my $self = shift;
    my ( $field, $substring ) = @_;

    return $self->objects->search( { $field => { 'like', "%$substring%" } } );
}

sub search_and_replace {
    my $self = shift;

    my ( $args_ref ) = @_;

    unless ( $self->is_homogenous ) {
        croak "Can't search-and-replace a non-homogenous set.";
    }

    my $field = $args_ref->{ field };
    my $count = 0;
    for my $object ( $self->objects ) {
        my $type_obj = $object->type_object;
        my $value = $type_obj->$field;
        if ( $value =~ s/$$args_ref{old}/$$args_ref{new}/eg ) {
            $type_obj->$field( $value );
            $type_obj->update;
            $count++;
        }
    }

    return $count;
}

sub set_field {
    my $self = shift;
    my ( $field, $new_value ) = @_;

    unless ( $self->is_homogenous ) {
        croak "Can't batch-set the fields of a non-homogenous set.";
    }

    # TO DO: get type-specific resultset
    $self->objects->update( { $field => $new_value } );
}

sub move_all_objects_to {
    my $self = shift;

    my ( $new_parent ) = @_;

    unless ( $self->is_homogenous ) {
        croak "Can't batch-move a non-homogenous set.";
    }

    for my $object ( $self->objects ) {
        $object->parent( $new_parent );
        $object->update;
    }
}

1;
