package CIDER::Schema::Result::ObjectSet;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use Carp qw(croak);

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::ObjectSet

=cut

__PACKAGE__->table("object_set");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 owner

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "owner",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 owner

Type: belongs_to

Related object: L<CIDER::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "owner",
  "CIDER::Schema::Result::User",
  { id => "owner" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 object_set_objects

Type: has_many

Related object: L<CIDER::Schema::Result::ObjectSetObject>

=cut

__PACKAGE__->has_many(
  "object_set_objects",
  "CIDER::Schema::Result::ObjectSetObject",
  { "foreign.object_set" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->many_to_many('objects' => 'object_set_objects', 'object');

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

    $self->add_to_objects( $object_to_add );
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

    my $last_object_class = undef;
    for my $object ( $self->objects ) {
        if ( not $last_object_class ) {
            $last_object_class = ref $object;
        }
        elsif ( $last_object_class ne ref $object ) {
            return 0;
        }
    }

    return 1;
}

sub type {
    my $self = shift;

    return $self->objects->first->cider_type;
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

    my $count = 0;
    for my $object ( $self->objects ) {
        my $field = $args_ref->{ field };
        my $value = $object->$field;
        if ( $value =~ s/$$args_ref{old}/$$args_ref{new}/eg ) {
            $object->$field( $value );
            $object->update;
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
