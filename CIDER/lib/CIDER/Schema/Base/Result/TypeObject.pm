package CIDER::Schema::Base::Result::TypeObject;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use CIDER::Logic::Utils qw( iso_8601_date );
use Regexp::Common qw( URI );
use Sub::Name qw( subname );

=head1 NAME

CIDER::Schema::Base::Result::TypeObject

=head1 DESCRIPTION

Generic base class for type-specific results, i.e. Collection,
Series, and Item.

=cut


my @proxy_fields = qw( parent number title
                       objects sets audit_trail
                     );

my @proxy_methods = qw( children number_of_children
                        ancestors has_ancestor descendants item_descendants
                        export
                      );

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
        { proxy => [ @proxy_fields ] }
    );
}


=head2 full_title

A concatenation of the object's number, title, and dates.

=cut

sub full_title {
    my $self = shift;

    my $number_title = join " ", $self->number, $self->title;
# XXX Commenting this out until derived fields are cached properly.
#    if ( my $dates = $self->dates ) {
#        return "$number_title, $dates";
#    }
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

sub _delete_proxy_fields {
    my ( $fields ) = @_;

    my $deleted = { };
    for my $field ( @proxy_fields ) {
        if ( exists $fields->{ $field } ) {
            $deleted->{ $field } = delete $fields->{ $field };
        }
    }
    return $deleted;
}

sub new {
    my $class = shift;
    my ( $fields ) = @_;

    my $obj = _delete_proxy_fields( $fields );
    my $row = $class->next::method( $fields );

    # If we're given an id already, it's because there's already an
    # Object (i.e. we're just changing its type object), so don't make
    # a new one.
    unless ( $fields->{ id } ) {
        $row->object( $row->new_related( 'object', $obj ) );
    }
    return $row;
}

sub insert {
    my $self = shift;

    unless ( $self->audit_trail ) {
        # The object was just created, so log its creation and add it
        # to the index.

        $self->audit_trail( $self->object->create_related( 'audit_trail', {} ) );
        $self->audit_trail->created_by(
            $self->result_source->schema->user->staff );

        $self->next::method( @_ );

        $self->result_source->schema->indexer->add( $self->object );
    }
    else {
        # Otherwise, we're just changing the object's type; treat it
        # as an update.
        $self->next::method( @_ );
        $self->_update;
    }

    return $self;
}

sub update {
    my $self = shift;
    my ( $fields ) = @_;

    my $obj = _delete_proxy_fields( $fields );
    $self->next::method( $fields );
    $self->object->update( $obj );
    $self->_update;
    return $self;
}

sub _update {
    my $self = shift;

    $self->audit_trail->add_to_modification_logs( {
        staff => $self->result_source->schema->user->staff
    } );

    $self->result_source->schema->indexer->update( $self->object );
}

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    # Convert all empty strings to nulls.
    $value = undef if defined( $value ) && $value eq '';

    return $self->next::method( $column, $value );
}

=head2 delete( [ $keep_object ] )

If $keep_object is true, then don't delete the associated Object
(i.e. we're just changing its type).  Otherwise, cascade the delete--
but delete self first, since its id is a foreign key.

=cut

sub delete {
    my $self = shift;
    my ( $keep_object ) = @_;

    $self->next::method;

    $self->object->delete unless $keep_object;

    return $self;
}


no strict 'refs';
for my $method ( @proxy_methods ) {
    my $name = join "::", __PACKAGE__, $method;
    *$name = subname $method => sub { shift->object->$method( @_ ) };
}

1;
