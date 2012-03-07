package CIDER::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers qw(around);
use Carp qw( croak );

=head1 NAME

CIDER::Schema::Result::Object

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'object' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    parent =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1,
          accessor => '_parent'},
);

__PACKAGE__->belongs_to(
    parent =>
        'CIDER::Schema::Result::Object',
);

__PACKAGE__->has_many(
    objects =>
        'CIDER::Schema::Result::Object',
    'parent',
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    number =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'number' ] );

__PACKAGE__->add_columns(
    title =>
        { data_type => 'varchar' },
);

__PACKAGE__->might_have(
    collection =>
        'CIDER::Schema::Result::Collection',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->might_have(
    series =>
        'CIDER::Schema::Result::Series',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->might_have(
    item =>
        'CIDER::Schema::Result::Item',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);

=head2 type_object

The type-specific object for this Object, i.e. either a Collection,
Series, or Item object.

=cut

sub type_object {
    my $self = shift;

    return $self->collection || $self->series || $self->item;
}

=head2 type

The type identifier for this Object, i.e. either 'collection',
'series', or 'item'.

=cut

sub type {
    my $self = shift;

    if ( $self->type_object ) {
        return $self->type_object->type;
    }
    else {
        return undef;
    }
}

__PACKAGE__->has_many(
    object_set_objects =>
        'CIDER::Schema::Result::ObjectSetObject',
);

__PACKAGE__->many_to_many(
    sets =>
        'object_set_objects',
    'object_set');

__PACKAGE__->add_columns(
    audit_trail =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    audit_trail =>
        'CIDER::Schema::Result::AuditTrail',
    undef,
    { cascade_delete => 1 }
);

sub children {
    my $self = shift;

    return map { $_->type_object }
        $self->objects->search( undef, { order_by => 'number' } );
}

sub number_of_children {
    my $self = shift;

    return $self->objects->count;
}

sub ancestors {
    my $self = shift;

    if ( my $parent = $self->parent ) {
        return $parent->ancestors, $parent->type_object;
    }
    return ();
}

# has_ancestor: Returns 1 if the given object is an ancestor of this object.
sub has_ancestor {
    my $self = shift;
    my ( $possible_ancestor ) = @_;

    for my $ancestor ( $self->ancestors ) {
        if ( $ancestor->id == $possible_ancestor->id ) {
            return 1;
        }
    }

    return 0;
}

=head2 descendants

Returns a list of all descendants, including self.

=cut

sub descendants {
    my $self = shift;

    return $self->type_object, map { $_->descendants } $self->children;
}

=head2 item_descendants

Returns a list of all descendants that are Items.

=cut

sub item_descendants {
    my $self = shift;

    return grep { $_->type eq 'item' } $self->descendants;
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $self->type_object->delete if $self->type_object;

    $_->delete for ( $self->children,
                     $self->object_set_objects,
                   );

    $self->next::method( @_ );

    $self->result_source->schema->indexer->remove( $self );

    return $self;
}

sub export {
    my $self = shift;

    $self->audit_trail->add_to_export_logs( {
        staff => $self->result_source->schema->user->staff
    } );
}

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    # Convert all empty strings to nulls.
    $value = undef if defined( $value ) && $value eq '';

    return $self->next::method( $column, $value );
}

# parent: Custom user-facing accessor method for the 'parent' column.
#         On set, confirms that no circular graphs are in the making.
sub parent {
    my $self = shift;
    my ( $new_parent ) = @_;

    if ( @_ ) {
        if ( !$new_parent ) {
            $self->_parent( undef );
        }
        else {
            unless ( ref $new_parent ) {
                $new_parent =
                    $self->result_source->resultset->find( $new_parent );
            }

            if ( $self->in_storage ) {

                if ( $new_parent->id == $self->id ) {
                    croak( sprintf "Cannot set a CIDER object (ID %s) to be "
                               . "its own parent.",
                           $self->id,
                       );
                }

                if ( $new_parent->has_ancestor( $self ) ) {
                    croak( sprintf "Cannot set a CIDER object (ID %s) to be "
                               . "the parent of its ancestor (ID %s).",
                           $new_parent->id,
                           $self->id,
                       );
                }
            }

            # If we've made it this far, then this is a legal new parent.
            $self->_parent( $new_parent->id );
        }
    }

    return $self->_parent;
}

=head2 update_from_xml( $element, $hashref )

Update non-type-specific columns on this object from an XML element
and hashref.  The element is assumed to have been validated.  The
object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt, $hr ) = @_;

    if ( $elt->hasAttribute( 'parent' ) ) {
        my $parent_number = $elt->getAttribute( 'parent' );
        my $parent = undef;
        unless ( $parent_number eq '' ) {
            my $rs = $self->result_source->resultset;
            $parent = $rs->find( { number => $parent_number } );
            unless ( $parent ) {
                croak "Parent number '$parent_number' does not exist.";
            }
        }
        $self->parent( $parent );
    }

    $self->update_text_from_xml_hashref( $hr, 'title' );

    # If the object is already in storage, then we need to update it
    # here; otherwise we have to wait to insert it until after the
    # audit trail is set (when the type object is inserted).
    $self->update if $self->in_storage;

    return $self;
}

1;
