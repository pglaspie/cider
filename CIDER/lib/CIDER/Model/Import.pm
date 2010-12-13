package CIDER::Model::Import;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

# The args to pass to the searcher constuctor -- most crucially the path to
__PACKAGE__->config(
    schema_class => 'CIDER::Schema',
    connect_info => [ 'dbi:SQLite:t/db/cider.db', '', '' ],
);

__PACKAGE__->config(
    class => 'CIDER::Importer',
    args  => {
        schema_class => __PACKAGE__->config->{ schema_class },
        connect_info => __PACKAGE__->config->{ connect_info },
    },
);

__PACKAGE__->meta->make_immutable;

1;
