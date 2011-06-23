package CIDER::Logic::Importer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp;

use CIDER::Schema;

has 'schema' => (
    is => 'rw',
    isa => 'DBIx::Class',
);

sub import_from_csv {
    my $self = shift;
    my ($handle) = @_;

    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $handle ) );

    my $schema = $self->schema;
    my $object_rs = $schema->resultset( 'Object' );

    # All rows are inserted at once, or none at all if there are errors.
    $schema->txn_begin;
    $schema->indexer->txn_begin;

    my $row_number = 0;
    while ( my $row = $csv->getline_hr( $handle ) ) {
        $row_number++;

        my $object;
        if ( $row->{ id } ) {
            $object = $object_rs->find( $row->{ id } );
        }
        else {
            # If the 'id' field has no value, remove it completely, so
            # that the DB can properly assign a fresh one.
            delete $row->{ id };
        }

        # TO DO: do we need to handle parent specially?

        # TO DO: check cider_type?
        # Do we need cider_type, or can we always deduce it?

        # Perform the actual update-or-insertion.
        eval {
            if ( $object ) {
                $object->update( $row );
            }
            else {
                $object = $object_rs->create( $row );
            }
        };
        if ( $@ ) {

            $schema->txn_rollback;
            $schema->indexer->txn_rollback;

            croak "CSV import failed at data row $row_number:\n$@\n";
        }
    }

    $schema->txn_commit;
    $schema->indexer->txn_commit;

    return $row_number;
}
1;
