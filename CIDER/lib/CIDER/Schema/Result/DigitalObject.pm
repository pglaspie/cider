package CIDER::Schema::Result::DigitalObject;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::ItemClass';

use String::CamelCase qw( decamelize );

=head1 NAME

CIDER::Schema::Result::DigitalObject

=cut

__PACKAGE__->table( 'digital_object' );

__PACKAGE__->setup_item;

__PACKAGE__->add_columns(
    location =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    location =>
        'CIDER::Schema::Result::Location',
);

__PACKAGE__->add_columns(
    format =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    format =>
        'CIDER::Schema::Result::Format',
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar' },
    permanent_url =>
        { data_type => 'varchar', is_nullable => 1 },
    notes =>
        { data_type => 'text', is_nullable => 1 },
    rights =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    digital_object_relationships =>
        'CIDER::Schema::Result::DigitalObjectRelationship',
    'digital_object',
);

__PACKAGE__->add_columns(
    checksum =>
        { data_type => 'varchar', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    file_extension =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    file_extension =>
        'CIDER::Schema::Result::FileExtension',
);

__PACKAGE__->add_columns(
    original_filename =>
        { data_type => 'varchar', is_nullable => 1 },
    toc =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    stabilized_by =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    stabilized_by =>
        'CIDER::Schema::Result::Staff',
);

__PACKAGE__->add_columns(
    stabilization_date =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

__PACKAGE__->add_columns(
    stabilization_procedure =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    stabilization_procedure =>
        'CIDER::Schema::Result::StabilizationProcedure',
);

__PACKAGE__->add_columns(
    stabilization_notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    checksum_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    checksum_app =>
        'CIDER::Schema::Result::Application',
);

__PACKAGE__->add_columns(
    media_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    media_app =>
        'CIDER::Schema::Result::Application',
);

__PACKAGE__->add_columns(
    virus_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    virus_app =>
        'CIDER::Schema::Result::Application',
);

__PACKAGE__->has_many(
    other_apps =>
        'CIDER::Schema::Result::DigitalObjectApplication',
    'digital_object',
);

__PACKAGE__->add_columns(
    file_creation_date =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for (
        $self->digital_object_relationships,
        $self->other_apps,
    );

    return $self->next::method( @_ );
}

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->update_location_from_xml_hashref(
        $hr );
    $self->update_format_from_xml_hashref(
        $hr );
    $self->update_text_from_xml_hashref(
        $hr, 'pid' );
    $self->update_text_from_xml_hashref(
        $hr, permanent_url => 'permanentURL' );
    $self->update_text_from_xml_hashref(
        $hr, 'notes' );
    $self->update_text_from_xml_hashref(
        $hr, 'rights' );
    $self->update_text_from_xml_hashref(
        $hr, 'checksum' );
    $self->update_term_from_xml_hashref(
        $hr, 'file_extension' );
    $self->update_text_from_xml_hashref(
        $hr, 'original_filename' );
    $self->update_text_from_xml_hashref(
        $hr, toc => 'tableOfContents' );
    $self->update_text_from_xml_hashref(
        $hr, 'file_creation_date' );

    if ( exists $hr->{ stabilization } ) {
        my $stab =
            $self->xml_elements_to_hashref( @{ $hr->{ stabilization } } );

        if ( exists $stab->{ by } ) {
            my $staff = $self->xml_elements_to_hashref( @{ $stab->{ by } } );
            my $rs = $self->result_source
                ->related_source( 'stabilized_by' )->resultset;
            $self->stabilized_by( $rs->find_or_create( {
                first_name => $staff->{ firstName },
                last_name  => $staff->{ lastName }
            } ) );
        }

        $self->update_text_from_xml_hashref(
            $stab, stabilization_date => 'date' );
        $self->update_cv_from_xml_hashref(
            $stab, stabilization_procedure => 'code', 'procedure' );
        $self->update_text_from_xml_hashref(
            $stab, stabilization_notes => 'notes' );
    }

    my $apps = { };
    if ( exists $hr->{ applications } ) {
        $apps = $self->xml_elements_to_hashref( @{ $hr->{ applications } } );

        $self->update_application_from_xml_hashref(
            $apps, checksum_app => 'checksum' );
        $self->update_application_from_xml_hashref(
            $apps, media_app => 'mediaImage' );
        $self->update_application_from_xml_hashref(
            $apps, virus_app => 'virusCheck' );
    }

    $self->update_or_insert;

    # These need to be done after the row is inserted, so its id can
    # be used as a foreign key.

    $self->update_relationships_from_xml_hashref( $hr );

    $self->update_has_many_from_xml_hashref(
        $apps, other_apps => 'application', 'other' );

    return $self;
}

=head2 update_application_from_xml_hashref( $hr, $colname, $tag )

Update an Application authority list column from an XML element
hashref.  The application will be added to the authority list if it
doesn't already exist.  The $tag is also the function of the application.

=cut

# TO DO: refactor update_term_from_xml_hashref?

sub update_application_from_xml_hashref {
    my $self = shift;
    my ( $hr, $colname, $tag ) = @_;

    if ( exists( $hr->{ $tag } ) ) {
        my $rs = $self->result_source->related_source( $colname )->resultset;
	my $function = decamelize( $tag );
        my $obj = $rs->find_or_create( { name => $hr->{ $tag },
                                         function => $function } );
        $self->set_inflated_column( $colname => $obj );
    }
}

=head2 default_app( $column )

Find or create the default application for an application column.

=cut

sub default_app {
    my $self = shift;
    my ( $column ) = @_;

    my $rs = $self->result_source->related_source( $column )->resultset;
    my $attrs;
    if ( $column eq 'checksum_app' ) {
        $attrs = { function => 'checksum',
                   name     => 'Advanced Checksum Verifier' };
    } elsif ( $column eq 'media_app' ) {
        $attrs = { function => 'media_image',
                   name     => 'WinImage' };
    } elsif ( $column eq 'virus_app' ) {
        $attrs = { function => 'virus_check',
                   name     => 'Office Scan' };
    }
    return $rs->find_or_create( $attrs );
}

=head2 insert

Override insert to set default values.

=cut

sub insert {
    my $self = shift;

    $self->checksum_app( undef ) unless defined $self->checksum_app;
    $self->media_app   ( undef ) unless defined $self->media_app;
    $self->virus_app   ( undef ) unless defined $self->virus_app;

    return $self->next::method( @_ );
}

=head2 store_column( $column, $value )

Override store_column to set default values.

=cut

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    if ( !defined( $value ) || $value eq '' ) {
        if ( $column =~ /_app/ ) {
            $value = $self->default_app( $column )->id;
        }
    }

    return $self->next::method( $column, $value );
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
