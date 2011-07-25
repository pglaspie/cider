package CIDER::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers qw(around);
use List::Util qw(min max);

use Carp qw( croak );

=head1 NAME

CIDER::Schema::Result::Object

=cut

__PACKAGE__->table("object");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parent",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1,
    accessor => '_parent'},
  "number",
  { data_type => "char", is_nullable => 0, size => 255 },
  "title",
  { data_type => "char", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( [ 'number' ] );

__PACKAGE__->belongs_to(
  "parent",
  "CIDER::Schema::Result::Object",
  { id => "parent" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->has_many(
  "objects",
  "CIDER::Schema::Result::Object",
  { "foreign.parent" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->might_have(
    collection => 'CIDER::Schema::Result::Collection',
);

__PACKAGE__->might_have(
    series => 'CIDER::Schema::Result::Series',
);

__PACKAGE__->might_have(
    item => 'CIDER::Schema::Result::Item',
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

    return $self->type_object->type;
}

__PACKAGE__->has_many(
  "object_set_objects",
  "CIDER::Schema::Result::ObjectSetObject",
  { "foreign.object" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->many_to_many('sets' => 'object_set_objects', 'object_set');

__PACKAGE__->has_many(
    logs => "CIDER::Schema::Result::Log",
    'object',
);

__PACKAGE__->has_one(
    creation_log => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'create' },
      proxy => {
          created_by => 'user',
          date_created => 'date',
      },
    },
);

__PACKAGE__->has_many(
    modification_logs => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'update' } },
);

__PACKAGE__->has_many(
    export_logs => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'export' } },
);


sub children {
    my $self = shift;

    my $object_rs = $self->result_source->schema->resultset('Object');

    return $object_rs
           ->search( { parent => $self->id }, { order_by => 'title' } )
           ->all;
}

sub number_of_children {
    my $self = shift;

    my $object_rs = $self->result_source->schema->resultset('Object');

    return $object_rs
           ->search( { parent => $self->id } )
           ->count;
}

sub ancestors {
    my $self = shift;
    my ( $ancestors_ref ) = @_;
    $ancestors_ref ||= [];

    if ( my $parent = $self->parent ) {
        push @$ancestors_ref, $parent;
        $parent->ancestors( $ancestors_ref );
    }
    else {
        return;
    }
    return reverse @$ancestors_ref;
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

sub descendants {
    my $self = shift;

    return $self, map { $_->descendants } $self->children;
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $_->delete for ( $self->children,
                     $self->type_object,
                     $self->object_set_objects,
                     $self->logs,
                   );

    $self->next::method( @_ );

    $self->result_source->schema->indexer->remove( $self );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->add_to_modification_logs( {
        user => $self->result_source->schema->user
    } );

    $self->result_source->schema->indexer->update( $self );

    return $self;
}

sub export {
    my $self = shift;

    $self->add_to_export_logs( {
        user => $self->result_source->schema->user
    } );
}

sub date_available {
    my $self = shift;

    my $rs = $self->export_logs->search( undef, {
        order_by => { -desc => 'timestamp' }
    } );
    return $rs->first->date;
}

=head2 date_from
=head2 date_to

Collections, series, and items with children do not have dates.  The
date_from and date_to accessors return the earliest/latest dates of
an object's children.

=cut

# TO DO: fix this to handle ISO-8601 partial dates (e.g. YYYY or YYYY-MM).

# for my $method ( qw(date_from date_to) ) {
#     around $method => sub {
#         my ( $orig, $self ) = ( shift, shift );

#         my $date = $orig->( $self, @_ );
#         return $date if defined $date;

#         my @dates = map { $_->$method } $self->children;
#         return ( $method eq 'date_from' ) ? min @dates : max @dates;
#     };
# }

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
    my ( $self, $new_parent ) = @_;

    if ( $new_parent ) {
        unless ( ref $new_parent ) {
            $new_parent = $self->result_source->schema->
                                 resultset('Object')->find( $new_parent );
        }

        if ( $new_parent->has_ancestor( $self ) ) {
            croak( sprintf "Cannot set a CIDER object (ID %s) to be "
                       . "the parent of its ancestor (ID %s).",
                   $new_parent->id,
                   $self->id,
               );
        }

        # If we've made it this far, then this is a legal new parent.
        $self->_parent( $new_parent->id );
    }

    return $self->_parent;
}

1;
