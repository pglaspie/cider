package CIDER::Model::Import;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use CIDER::Logic::Importer;

has 'rngschema_file' => (
    is => 'rw',
    isa => 'Str',
);

has schema => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    my ( $c ) = @_;

    my $schema = $c->model( 'CIDERDB' )->schema;

    return $self->meta->clone_object(
        $self,
        schema => $schema,
        rngschema_file => $c->config->{ home } . '/schema/cider-import.rng',
    );
}

sub importer {
    my $self = shift;

    return CIDER::Logic::Importer->new(
        schema => $self->schema,
        rngschema_file => $self->rngschema_file,
    );
}

__PACKAGE__->meta->make_immutable;

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
