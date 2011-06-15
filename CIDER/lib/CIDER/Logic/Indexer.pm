package CIDER::Logic::Indexer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp;

use CIDER::Schema;

has schema => (
    is => 'rw',
    isa => 'DBIx::Class',
);

has path_to_index => (
    is => 'ro',
    isa => 'Str',
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my ( $connect_info, $path_to_index ) = @_;

    my $schema = CIDER::Schema->connect( $connect_info );

    return $class->$orig( schema => $schema,
                          path_to_index => $path_to_index );
};

sub make_index {
    my $self = shift;

    my $object_rs = $self->schema->resultset( 'Object' );

    # Create the index schema.
    # We'll try to have all the indexes share the same one...
    my $index_schema = KinoSearch::Plan::Schema->new;
    my $polyanalyzer = KinoSearch::Analysis::PolyAnalyzer->new(
        language => 'en',
    );

    # Define some basic types. Just being coarse for now.
    my $text_type = KinoSearch::Plan::FullTextType->new(
        analyzer => $polyanalyzer,
        sortable => 1,
    );

    my $unstored_text = KinoSearch::Plan::FullTextType->new(
        analyzer => $polyanalyzer,
        sortable => 0,
        stored   => 0,
    );

    my $string_type = KinoSearch::Plan::StringType->new( sortable => 1 );
    my $storage_only = KinoSearch::Plan::StringType->new( indexed => 0 );
    my $index_only = KinoSearch::Plan::StringType->new( stored => 0 );
    my $int_type    = KinoSearch::Plan::Int32Type->new;

    # Define the fields.
    my @text_fields = qw(
                            accession_by
                            accession_number
                            accession_procedure
                            arrangement
                            checksum
                            checksum_app
                            description
                            file_extension
                            funder
                            handle
                            history
                            lc_class
                            media_app
                            notes
                            number
                            organization
                            original_filename
                            other_app
                            permanent_url
                            pid
                            processing_notes
                            publication_status
                            rsa
                            stabilization_by
                            stabilization_notes
                            stabilization_procedure
                            technical_metadata
                            title
                            toc
                            virus_app
                    );

    for my $field ( @text_fields ) {
        $index_schema->spec_field( name => $field, type => $text_type );
    }

    $index_schema->spec_field( name => 'id', type => $storage_only );
    $index_schema->spec_field( name => 'set', type => $unstored_text );


    # Create one indexer object for each index.
    my $indexer = KinoSearch::Index::Indexer->new(
        index => $self->path_to_index,
        schema => $index_schema,
        create => 1,
        truncate => 1,
    );

    my $count = $object_rs->count;

    # Start looping through the objects.
    # Each will get a document in the searchable index.
    while ( my $object = $object_rs->next ) {
        my $doc = {
            id => $object->id || '',
        };

        for my $field ( @text_fields ) {
            $doc->{ $field } = $object->$field || '';
        }

        my @sets = $object->sets;
        my $sets = join ' ', map { $_->id } @sets;
        $doc->{ set } = $sets || '';

        $indexer->add_doc( $doc );
    }

    $indexer->commit;

    return $count;
}

sub normalize {
    my ( $name ) = @_;
    $name =~ s/\s+\W+\s+/_/g;
    $name =~ s/\s+/_/g;
    $name =~ s/\W//g;
    $name = lc $name;
    return $name;
}

1;
