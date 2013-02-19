package CIDER::Logic::Utils;

use strict;
use warnings;

use base qw( Exporter );
our @EXPORT    = qw( iso_8601_date $OBJECT_SKETCH_SEARCH_ATTRIBUTES );
our @EXPORT_OK = qw( iso_8601_date $OBJECT_SKETCH_SEARCH_ATTRIBUTES );

use Readonly;

# $OBJECT_SKETCH_SEARCH_ATTRIBUTES is a hashref suitable for passing as the second arg
# to a DBIC ResultSet's search() method. It returns a "sketch" of a list of objects in
# one table, allowing other templates to build a detailed visual representation of this
# object-list without having to run any additional DB queries to fetch more object info.
Readonly our $OBJECT_SKETCH_SEARCH_ATTRIBUTES =>
        {
            distinct => 1,
            join => [
                { item => [ qw( file_folders containers bound_volumes
                        three_dimensional_objects audio_visual_media documents
                        physical_images digital_objects browsing_objects ) ] },
                  'objects',
                  'collection',
                  'item',
                  'series',
            ],
            columns => [
                'me.id', 'me.number', 'me.date_from', 'me.date_to', 'me.parent', 'me.title',
            ],
            +select => [
                { count => 'item.id', -as => 'items' },
                { count => 'collection.id', -as => 'collections' },
                { count => 'series.id', -as => 'serieses' },
                { count => 'file_folders.id', -as => 'file_folders' },
                { count => 'containers.id', -as => 'containers' },
                { count => 'bound_volumes.id', -as => 'bound_volumes' },
                { count => 'three_dimensional_objects.id', -as => 'three_dimensional_objects' },
                { count => 'audio_visual_media.id', -as => 'audio_visual_media' },
                { count => 'documents.id', -as => 'documents' },
                { count => 'physical_images.id', -as => 'physical_images' },
                { count => 'digital_objects.id', -as => 'digital_objects' },
                { count => 'browsing_objects.id', -as => 'browsing_objects' },
                { count => 'objects.id', -as => 'children' },
            ],
            +as => [
                'is_item',
                'is_collection',
                'is_series',
                'is_file_folders',
                'is_containers',
                'is_bound_volumes',
                'is_three_dimensional_objects',
                'is_audio_visual_media',
                'is_documents',
                'is_physical_images',
                'is_digital_objects',
                'is_browsing_objects',
                'number_of_children',
            ],
            order_by => [ 'me.number', ],
        };

=head1 FUNCTIONS

=head2 iso_8601_date( $date )

Returns true iff $date is undefined, empty, or a valid ISO-8601 format
date string, i.e. YYYY, YYYY-MM, or YYYY-MM-DD, with month in 1..12
and date in 1..31.

=cut

sub iso_8601_date {
    my ( $date ) = @_;

    return !defined( $date ) || $date eq ''
        || $date =~ /^\d{4}(?:-(\d{2})(?:-(\d{2}))?)?$/
        && ( !defined( $1 )
             || ( $1 >= 1 && $1 <= 12
                  && ( !defined( $2 )
                       || ( $2 >= 1 && $2 <= 31 ) ) ) );
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
