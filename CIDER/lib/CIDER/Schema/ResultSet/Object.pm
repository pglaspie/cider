package CIDER::Schema::ResultSet::Object;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Carp qw/croak/;

sub root_objects {
    my $self = shift;
    my $resultset = $self->search(
        { parent => undef },
        { order_by => 'title' },
    );

    if ( wantarray ) {
        return map { $_->type_object } $resultset->all;
    }
    else {
        return $resultset;
    }
}

# TO DO: move these to ResultSet::TypeObject?

sub update {
    my $self = shift;

    my $ret = $self->next::method( @_ );

    # TO DO: update audit trail?

    $self->result_source->schema->indexer->update_rs( $self );

    return $ret;
}

sub delete {
    my $self = shift;

    my $ret = $self->next::method( @_ );

    $self->result_source->schema->indexer->remove_rs( $self );

    return $ret;
}

1;

