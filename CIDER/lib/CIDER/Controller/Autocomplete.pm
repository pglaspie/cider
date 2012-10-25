package CIDER::Controller::Autocomplete;
use Moose;
use namespace::autoclean;
use JSON::XS qw( encode_json );

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

sub authority_name :Local :Args(0) {
    my ( $self, $c ) = @_;

    return $c->forward( 'return_autocomplete_json', [ 'AuthorityName' ] );
}

sub topic_term :Local :Args(0) {
    my ( $self, $c ) = @_;

    return $c->forward( 'return_autocomplete_json', [ 'TopicTerm' ] );
}

sub geographic_term :Local :Args(0) {
    my ( $self, $c ) = @_;

    return $c->forward( 'return_autocomplete_json', [ 'GeographicTerm' ] );
}

sub location :Local :Args(0) {
    my ( $self, $c ) = @_;

    return $c->forward( 'return_autocomplete_json', [ 'Location', 'barcode' ] );
}

sub return_autocomplete_json :Private {
    my ( $self, $c, $schema_name, $column_name ) = @_;

    $column_name ||= 'name';

    my $term = $c->req->params->{ term };
    $c->log->debug( "***Schema: $schema_name ***Term: $term");

    my $result_set = $c->model( "CIDERDB::$schema_name" )
                       ->search( { $column_name => { like => "%$term%" } } );

    $c->log->debug("Sending back " . $result_set->count . " things.");

    # JQuery's autocomplete expects an array of hashrefs, each with keys "label" and
    # "value". So that's what it'll get.
    my $results_ref = [
        map {
            { label => $_->name_and_note,
              value => $_-> id, }
        } $result_set->all
    ];

    my $json = encode_json( $results_ref );

    $c->res->body( $json );
    $c->res->content_type( 'text/json' );
    $c->detach;
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
