package CIDER::Importer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp qw (croak);

has 'schema' => (
    is => 'rw',
    isa => 'DBIx::Class',
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my ( $args_ref ) = @_;

    unless ( ref $args_ref eq 'HASH'
             && defined $args_ref->{schema_class}
             && defined $args_ref->{connect_info}
         ) {
        croak "You must call CIDER::Importer's constructor with a hashref "
              . "containing 'schema_class' and 'connect_info' keys.";
    }

    my $schema_class = $args_ref->{schema_class};
    eval "require $schema_class";
    if ( $@ ) {
        croak "require() failed for schema class $schema_class: $@";
    }

    unless ( ref $args_ref->{connect_info} eq 'ARRAY' ) {
        croak "The value of the connect_info key must be an array reference.";
    }
    my $schema = $schema_class->connect( @{ $args_ref->{connect_info} } );

    return $class->$orig( schema => $schema );
};
    
sub import_from_csv {
    my $self = shift;
    my ($handle) = @_;
    
    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $handle ) );
    
    my $schema = $self->schema;
    my $object_rs = $schema->resultset( 'Object' );
    my $row_number = 0;
    while ( my $row = $csv->getline_hr( $handle ) ) {
        $row_number++;

        # If the 'id' field has no value, remove it completely, so that the
        # DB can properly assign a fresh one.
        unless ( $row->{ id } ) {
            delete $row->{ id };
        }

        # Perform the actual update-or-insertion.
        my $object;
        eval { $object = $object_rs->update_or_new( $row ); };
        if ( $@ ) {
            croak "CSV import failed at data row $row_number:\n$@\n";
        }
        unless ( $object->in_storage ) {
            eval { $object->insert; };
            if ( $@ ) {
                croak "CSV import failed at data row $row_number:\n$@\n";
            }
        }
    }
}
1;
