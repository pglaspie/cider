package CIDER::Schema::Result::ObjectLocation;

# This class runs a linking table between objects and locations.
# It allows objects at arbitrary depth to have a many-to-many relationship with all the
# locations used by all of the items they contain, and to also know which items these
# are.

# It overrides the DBIC insert and delete methods so as to share information with the
# related object's parent row... an action that will continue bubbling up until it
# reaches the appropriate top-level object.

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("object_location");

__PACKAGE__->add_columns(
  "object",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "location",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "referent_object",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  'id',
  {
    data_type => 'integer',
    is_auto_increment => 1,
  },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
    object => 'CIDER::Schema::Result::Object',
    { id => 'object' },
);

__PACKAGE__->belongs_to(
    location => 'CIDER::Schema::Result::Location',
    { id => 'location', },
);

#__PACKAGE__->belongs_to(
#    referent_object => 'CIDER::Schema::Result::Object',
#    { id => 'object', },
#);

sub insert {
    my $self = shift;

    my $parent = $self->object->parent;

    $self->next::method( @_ );

    if ( $parent ) {
        my $rs = $self->result_source->resultset;

        $rs->create( {
            object => $self->object->parent->id,
            location => $self->location->id,
            referent_object => $self->referent_object,
        } );
    }
}

sub delete {
    my $self = shift;

    my $parent = $self->object->parent;

    $self->next::method( @_ );

    if ( $parent ) {
        my $rs = $self->result_source->resultset;
        # We want to delete only one from the parent... not all that match.
        my ( $deletable ) = $rs->search( {
            object => $self->object->parent->id,
            location => $self->location->id,
        } );
        if ( $deletable ) {
            $deletable->delete;
        }
    }
}

1;

