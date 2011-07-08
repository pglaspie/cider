package CIDER::Controller::Authority;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

CIDER::Controller::Authority - Catalyst Controller for authority lists

=head1 DESCRIPTION

Catalyst Controller for browsing and editing authority lists.

=head1 METHODS

=cut

my $list_ids = [ qw( name geographic_term topic_term format ) ];

my $list_names = {
    name            => 'Names',
    geographic_term => 'Geographic Terms',
    topic_term      => 'Topic Terms',
    format          => 'Formats',
};

my $class_names = {
    name            => 'AuthorityName',
    geographic_term => 'GeographicTerm',
    topic_term      => 'TopicTerm',
    format          => 'ItemFormat',
};

=head2 index

Display links to the various authority list pages.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ list_ids } = $list_ids;
    $c->stash->{ list_names } = $list_names;
}

=head2 authority

Chain root action that gets an authority list resultset by id.

=cut

sub authority :Chained :CaptureArgs(1) {
    my ( $self, $c, $list_id ) = @_;

    my $list_class = $class_names->{ $list_id }
        || $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );

    my $rs = $c->model( "CIDERDB::$list_class" );

    $c->stash->{ list_name } = $list_names->{ $list_id };
    $c->stash->{ list } = $rs->search( undef, { order_by => 'name' } );
}

=head2 browse

Browse the authority names in an authority list.

=cut

sub browse :Chained( 'authority' ) :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;
}

=head1 AUTHOR

Doug Orleans,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
