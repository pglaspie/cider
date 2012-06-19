use warnings;
use strict;

use CIDER::Schema;
use DBI;

use 5.10.0;

# Might need to be populated before running; don't commit with real
# credentials
my @db_creds = ('', '', '');

my $schema = CIDER::Schema->connect( @db_creds );
my $raw_dbh = DBI->connect( @db_creds );

my $leaf_ids = $raw_dbh->selectcol_arrayref( 'select t1.id from object as t1 left join object as t2 on t1.id = t2.parent where t2.id is null;');

#my $rs = $schema->resultset( 'Object' );
my $rs = $schema->resultset( 'Item' );

my $object_location_rs = $schema->resultset( 'ObjectLocation' );

for my $leaf_id ( @$leaf_ids ) {
    my $leaf = $rs->find( $leaf_id );
    if ( $leaf ) {
        say $leaf->title;
        if ( $leaf->date_from ) {
            $leaf->object->date_from( $leaf->date_from );
        }
        if ( $leaf->date_to ) {
            $leaf->object->date_to( $leaf->date_to );
        }
        if ( $leaf->accession_number ) {
            $leaf->object->accession_numbers( $leaf->accession_number );
        }

        $leaf->define_restriction_summary;

        $leaf->object->update;

        # Blow away and then rebuild all locations relating to this object.
        my @deletables = $object_location_rs->search( { object => $leaf->object->id } );
             foreach ( @deletables ) {
            $_->delete;
         }

        my @classes = $leaf->classes;
        for my $class ( @classes ) {
            if ( $class->can( 'location' ) ) {
                $object_location_rs->create( { object => $leaf->object->id,
                                               location => $class->location->id,
                                               referent_object => $leaf->object->id,
                                            } );
            }
        }

    }

}
