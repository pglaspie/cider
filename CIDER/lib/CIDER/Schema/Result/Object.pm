package CIDER::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Class::Method::Modifiers qw( around );
use List::Util qw( minstr maxstr );
use Carp qw( croak );

use CIDER::Logic::Utils;

=head1 NAME

CIDER::Schema::Result::Object

=cut

__PACKAGE__->table( 'object' );

 __PACKAGE__->load_components( 'MaterializedPath', 'UpdateFromXML', );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    parent =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1,
          accessor => '_parent',
        },
    date_from =>
        { data_type => 'varchar', size => 10,
          is_nullable => 1,
        },
    date_to =>
        { data_type => 'varchar', size => 10,
          is_nullable => 1,
        },
    accession_numbers =>
        { data_type => 'text',
          is_nullable => 1,
        },
    restriction_summary =>
        { data_type => 'varchar', size => 4,
          is_nullable => 1,
        },

    parent_path => {
       data_type => 'varchar',
       size      => 255,
       is_nullable => 1,
    },
);

__PACKAGE__->belongs_to(
    parent =>
        'CIDER::Schema::Result::Object',
);

__PACKAGE__->has_many(
    objects =>
        'CIDER::Schema::Result::Object',
    'parent',
    { cascade_update => 0, cascade_delete => 0, join_type => 'left', }
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

sub materialized_path_columns {
    return {
       parent => {
          parent_column                => 'parent',
          parent_fk_column             => 'id',
          materialized_path_column     => 'parent_path',
          include_self_in_path         => 0,
          include_self_in_reverse_path => 1,
          parent_relationship          => 'parent',
          children_relationship        => 'objects',
          full_path                    => 'raw_ancestors',
          reverse_full_path            => 'raw_descendants',
       },
    }
 }

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

__PACKAGE__->has_many(
    object_locations =>
        'CIDER::Schema::Result::ObjectLocation',
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

=head2 number_of_children

The number of child objects that this object contains. (Running this method is faster
than running children() and then counting the results yourself.)

=cut

sub number_of_children {
    my $self = shift;

    # If this object came as a result of children_sketch() or similar, than this object
    # will have a special 'number_of_children' pseudo-column available, populated with
    # the result of a COUNT(*) db query.
    # Otherwise, we'll just run a fresh query to get the number of children.
    my $number;
    eval { $number = $self->get_column( 'number_of_children' ) };

    if ( $@ ) {
        return $self->objects->count;
    }
    else {
        return $number;
    }
}

sub ancestors {
    my $self = shift;

    my $raw_ancestors = $self->raw_ancestors;
    return map { $_->type_object } $raw_ancestors->all;
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
    return map { $_->type_object } $self->raw_descendants->all;
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
# Furthermore, call update_parent() to recalculate derived fields.
sub delete {
    my $self = shift;

    $self->type_object->delete if $self->type_object;

    $_->delete for ( $self->children,
                     $self->object_set_objects,
                     $self->object_locations,
                   );

    $self->next::method( @_ );

    $self->result_source->schema->indexer->remove( $self );

    # Recursively recalculate ancestors' derived columns.
    $self->update_parent;

    return $self;
}

# update: After performing the DB update, call update_parent(). This will update the
#         parent object's derived fields.
sub update {
    my $self = shift;

    my %dirty_columns = $self->get_dirty_columns;

    $self->next::method( @_ );

    # Recursively recalculate ancestors' derived columns.
    if ( %dirty_columns ) {
        $self->update_parent;
    }

    return $self;
}

# insert: After performing the DB update, call update_parent(). This will update the
#         parent object's derived fields.
sub insert {
    my $self = shift;

    $self->next::method( @_ );

    # Recursively recalculate ancestors' derived columns.
    $self->update_parent;

    return $self;
}

# update_parent: Set the value of various derived fields on this object's parent object
#                (if it has one). Calls update() at the end, which in turn calls this
#                method again, thus allowing for updates to bubble up the object's
#                lineage.
# XXX: These should ideally be performed by database triggers, not in Perl. Consider
#      this a prototype behavior.
sub update_parent {
    my $self = shift;

    my $parent = $self->parent;
    return unless $parent;

    my $dbh = $self->result_source->schema->storage->dbh;

    my @siblings_date_from =
        grep { defined }
        @{ $dbh->selectcol_arrayref('select date_from from object where parent = '
                                 . $parent->id ) };

    my @siblings_date_to =
        grep { defined }
        @{ $dbh->selectcol_arrayref('select date_to from object where parent = '
                                 . $parent->id ) };

    my @siblings_accession_numbers =
        grep { defined }
        @{ $dbh->selectcol_arrayref('select distinct accession_numbers from object where '
                                 . 'parent = '
                                 . $parent->id ) };

    my @siblings_restriction_summary =
        @{ $dbh->selectcol_arrayref('select restriction_summary from object where '
                                 . 'parent = '
                                 . $parent->id ) };

    # Set the parent's date_from to the earliest date_from among its children.
    my $earliest_date = minstr( @siblings_date_from );
    if ( $earliest_date ) {
        if ( not( $parent->date_from ) || ( $parent->date_from ne $earliest_date ) ) {
            $parent->date_from( $earliest_date );
        }
    }
    else {
        if ( defined $parent->date_from ) {
            $parent->date_from( undef );
        }
    }

    # Set the parent's date_to to the latest date_to among its children.
    my $latest_date = maxstr( @siblings_date_to );
    if ( $latest_date ) {
        if ( not($parent->date_to) || ( $parent->date_to ne $latest_date ) ) {
            $parent->date_to( $latest_date );
        }
    }
    else {
        if ( defined $parent->date_to ) {
           $parent->date_to( undef );
        }
    }

    # Set the parent's restrictions.
    my $parent_restriction_summary;
    my @none_restrictions =
        grep { not(defined) || $_ eq 'none' } @siblings_restriction_summary;
    my @all_restrictions =
        grep { defined && $_ eq 'all' } @siblings_restriction_summary;

    if ( @none_restrictions == @siblings_restriction_summary ) {
        $parent_restriction_summary = 'none';
    }
    elsif ( @all_restrictions == @siblings_restriction_summary ) {
        $parent_restriction_summary = 'all';
    }
    else {
        $parent_restriction_summary = 'some';
    }

    if ( not( $parent->restriction_summary)
         || ( $parent->restriction_summary ne $parent_restriction_summary ) ) {
         $parent->restriction_summary( $parent_restriction_summary );
    }

    # Set the parent's accession-number list.
    my $accession_numbers = ( join '; ', @siblings_accession_numbers );
    if ( $accession_numbers
         && ( not( $parent->accession_numbers )
              || $parent->accession_numbers ne $accession_numbers
            )
        ) {
        $parent->accession_numbers( $accession_numbers );
    }

    # Lock it in. (And, in so doing, bubble up to next ancestor, if there is one.)
    if ( $parent->get_dirty_columns ) {
        $parent->update;

    }
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

=head2 full_title

A concatenation of the object's number, title, and dates.

=cut

sub full_title {
    my $self = shift;

    my $number_title = join " ", $self->number, $self->title;
    if ( my $dates = $self->dates ) {
        return "$number_title, $dates";
    }
    return $number_title;
}

=head2 dates

The date or dates of an object, as a single string.

=cut

sub dates {
    my $self = shift;

    if ( my $from = $self->date_from ) {
        my $to = $self->date_to;
        if ( $to && $to ne $from ) {
            return "$from&ndash;$to";
        }
        else {
            return $from;
        }
    }
}

# Returns a DBIC resultset with one row per child object, but every such object will be
# enhanced with additional data suitable for rendering a detailed list without the need
# to run any further DB queries. See root/display_object.tt for usage example.
sub children_sketch {
    my $self = shift;

    my $class_rs = $self->objects->search(
        undef,
        $OBJECT_SKETCH_SEARCH_ATTRIBUTES,
    );

    return $class_rs;

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
