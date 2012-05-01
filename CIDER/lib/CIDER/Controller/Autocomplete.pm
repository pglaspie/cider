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

1;
