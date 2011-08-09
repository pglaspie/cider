package CIDER::Logic::Importer;

use Moose;
use XML::LibXML;
use Carp;

use CIDER::Schema;

has 'schema' => (
    is => 'rw',
    isa => 'DBIx::Class',
);

sub import_from_xml {
    my $self = shift;
    my ( $handle ) = @_;

    # TO DO: catch errors while reading?
    binmode $handle;
    my $doc = XML::LibXML->load_xml( IO => $handle, line_numbers => 1 );

    # TO DO: validate against the RELAX-NG schema

    my $schema = $self->schema;

    # All rows are inserted at once, or none at all if there are errors.
    $schema->txn_begin;
    $schema->indexer->txn_begin;

    my ( $created, $updated ) = ( 0, 0 );
    for my $cmd ( $doc->documentElement->nonBlankChildNodes ) {
        my $create = $cmd->nodeName eq 'create';

        for my $elt ( $cmd->nonBlankChildNodes ) {
            my $type = $elt->localname;
            my $class = ucfirst $elt->localname;
            my $rs = $schema->resultset( $class );

            eval {
                if ( $create ) {
                    $rs->create_from_xml( $elt );
                    $created++;
                } else {
                    $rs->update_from_xml( $elt );
                    $updated++;
                }
            };
            if ( $@ ) {
                my $err = $@;

                $schema->txn_rollback;
                $schema->indexer->txn_rollback;

                my $line = $elt->line_number;
                croak "XML import failed at line $line:\n$err\n";
            }
        }
    }

    $schema->txn_commit;
    $schema->indexer->txn_commit;

    return $created, $updated;
}

1;
