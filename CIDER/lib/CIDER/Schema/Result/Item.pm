package CIDER::Schema::Result::Item;

use strict;
use warnings;

use base 'CIDER::Schema::Base::TypeObject';

=head1 NAME

CIDER::Schema::Result::Item

=cut

__PACKAGE__->table( 'item' );

__PACKAGE__->setup_object;

__PACKAGE__->add_columns(
  "creator",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "circa",
  { data_type => "boolean", is_nullable => 0, default_value => 0 },
  "date_from",
  { data_type => "varchar", size => 10 },
  "date_to",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "restrictions",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "accession_by",
  { data_type => "char", is_nullable => 1, size => 255 },
  "accession_date",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "accession_procedure",
  { data_type => "text", is_nullable => 1 },
  "accession_number",
  { data_type => "char", is_nullable => 1, size => 128 },
  "location",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "dc_type",
  { data_type => "integer", is_foreign_key => 1 },
  "format",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "personal_name",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "corporate_name",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "topic_term",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "geographic_term",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "checksum",
  { data_type => "char", is_nullable => 1, size => 64 },
  "original_filename",
  { data_type => "char", is_nullable => 1, size => 255 },
  "file_creation_date",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "stabilization_by",
  { data_type => "char", is_nullable => 1, size => 255 },
  "stabilization_date",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "stabilization_procedure",
  { data_type => "text", is_nullable => 1 },
  "stabilization_notes",
  { data_type => "text", is_nullable => 1 },
  "virus_app",
  { data_type => "char", is_nullable => 1, size => 128 },
  "checksum_app",
  { data_type => "char", is_nullable => 1, size => 128 },
  "media_app",
  { data_type => "char", is_nullable => 1, size => 128 },
  "other_app",
  { data_type => "char", is_nullable => 1, size => 128 },
  "toc",
  { data_type => "text", is_nullable => 1 },
  "rsa",
  { data_type => "text", is_nullable => 1 },
  "technical_metadata",
  { data_type => "text", is_nullable => 1 },
  "lc_class",
  { data_type => "char", is_nullable => 1, size => 255 },
  "file_extension",
  { data_type => "char", is_nullable => 1, size => 16 },
);

__PACKAGE__->belongs_to(
  "creator",
  "CIDER::Schema::Result::AuthorityName",
  { id => "creator" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "restrictions",
  "CIDER::Schema::Result::ItemRestrictions",
  { id => "restrictions" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
    location => "CIDER::Schema::Result::Location",
    # The next line should not be necessary, but omitting it leads to
    # any relations defined afterward (e.g. restrictions) being
    # ignored!!  TO DO: track this down? bug in DBIx?
    { barcode => 'location' },
);

__PACKAGE__->belongs_to(
  "dc_type",
  "CIDER::Schema::Result::ItemType",
  { id => "dc_type" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "format",
  "CIDER::Schema::Result::ItemFormat",
  { id => "format" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "personal_name",
  "CIDER::Schema::Result::AuthorityName",
  { id => "personal_name" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "corporate_name",
  "CIDER::Schema::Result::AuthorityName",
  { id => "corporate_name" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "topic_term",
  "CIDER::Schema::Result::TopicTerm",
  { id => "topic_term" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->belongs_to(
  "geographic_term",
  "CIDER::Schema::Result::GeographicTerm",
  { id => "geographic_term" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'item';
}

1;
