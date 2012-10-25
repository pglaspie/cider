package CIDER::Schema::Result::CollectionLanguage;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Locale::Language;

=head1 NAME

CIDER::Schema::Result::CollectionLanguage

=cut

__PACKAGE__->load_components( 'ConvertEmptyToNull' );

__PACKAGE__->table( 'collection_language' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    collection =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    collection =>
        'CIDER::Schema::Result::Collection',
);

__PACKAGE__->add_columns(
    language =>
        { data_type => 'char', size => 3 },
);
use overload '""' => sub { shift->language() }, fallback => 1;

=head1 METHODS

=cut

=head2 language_name

Returns the full English name of a collection language.  (As opposed
to the 'language' field, which contains the three-letter ISO language
code.)

=cut

sub language_name {
    my $self = shift;

    return code2language( $self->language, LOCALE_LANG_ALPHA_3 );
}

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub delete {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
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
