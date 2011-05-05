package CIDER::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::Object

=cut

__PACKAGE__->table("object");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 date_from

  data_type: 'date'
  is_nullable: 0

=head2 date_to

  data_type: 'date'
  is_nullable: 0

=head2 bulk_date_from

  data_type: 'date'
  is_nullable: 1

=head2 bulk_date_to

  data_type: 'date'
  is_nullable: 1

=head2 record_creator

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 history

  data_type: 'text'
  is_nullable: 1

=head2 scope

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 organization

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 processing_status

  data_type: 'tinyint'
  is_foreign_key: 1
  is_nullable: 1

=head2 has_physical_documentation

  data_type: 'enum'
  extra: {list => [0,1]}
  is_nullable: 1

=head2 processing_notes

  data_type: 'text'
  is_nullable: 1

=head2 volume_count

  data_type: 'integer'
  is_nullable: 1

=head2 volume_extent

  data_type: 'integer'
  is_nullable: 1

=head2 volume_unit

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 location

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 type

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 format

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 funder

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 handle

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 checksum

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 original_filename

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 accession_by

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 accession_date

  data_type: 'date'
  is_nullable: 1

=head2 accession_procedure

  data_type: 'text'
  is_nullable: 1

=head2 accession_number

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 stabilization_by

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 stabilization_date

  data_type: 'date'
  is_nullable: 1

=head2 stabilization_procedure

  data_type: 'text'
  is_nullable: 1

=head2 stabilization_notes

  data_type: 'text'
  is_nullable: 1

=head2 virus_app

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 checksum_app

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 media_app

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 other_app

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 toc

  data_type: 'text'
  is_nullable: 1

=head2 rsa

  data_type: 'text'
  is_nullable: 1

=head2 technical_metadata

  data_type: 'text'
  is_nullable: 1

=head2 file_creation_date

  data_type: 'date'
  is_nullable: 1

=head2 lc_class

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 file_extension

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 parent

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 number

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 title

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 personal_name

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 corporate_name

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 topic_term

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 geographic_term

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 circa

  data_type: 'boolean'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "date_from",
  { data_type => "date", is_nullable => 0 },
  "date_to",
  { data_type => "date", is_nullable => 0 },
  "bulk_date_from",
  { data_type => "date", is_nullable => 1 },
  "bulk_date_to",
  { data_type => "date", is_nullable => 1 },
  "record_creator",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "history",
  { data_type => "text", is_nullable => 1 },
  "scope",
  { data_type => "char", is_nullable => 1, size => 255 },
  "organization",
  { data_type => "char", is_nullable => 1, size => 255 },
  "processing_status",
  { data_type => "tinyint", is_foreign_key => 1, is_nullable => 1 },
  "has_physical_documentation",
  { data_type => "enum", extra => { list => [0, 1] }, is_nullable => 1 },
  "processing_notes",
  { data_type => "text", is_nullable => 1 },
  "volume_count",
  { data_type => "integer", is_nullable => 1 },
  "volume_extent",
  { data_type => "integer", is_nullable => 1 },
  "volume_unit",
  { data_type => "char", is_nullable => 1, size => 16 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "location",
  { data_type => "char", is_nullable => 1, size => 255 },
  "type",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "format",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "funder",
  { data_type => "char", is_nullable => 1, size => 128 },
  "handle",
  { data_type => "char", is_nullable => 1, size => 128 },
  "checksum",
  { data_type => "char", is_nullable => 1, size => 64 },
  "original_filename",
  { data_type => "char", is_nullable => 1, size => 255 },
  "accession_by",
  { data_type => "char", is_nullable => 1, size => 255 },
  "accession_date",
  { data_type => "date", is_nullable => 1 },
  "accession_procedure",
  { data_type => "text", is_nullable => 1 },
  "accession_number",
  { data_type => "char", is_nullable => 1, size => 128 },
  "stabilization_by",
  { data_type => "char", is_nullable => 1, size => 255 },
  "stabilization_date",
  { data_type => "date", is_nullable => 1 },
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
  "file_creation_date",
  { data_type => "date", is_nullable => 1 },
  "lc_class",
  { data_type => "char", is_nullable => 1, size => 255 },
  "file_extension",
  { data_type => "char", is_nullable => 1, size => 16 },
  "parent",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "number",
  { data_type => "char", is_nullable => 0, size => 255 },
  "title",
  { data_type => "char", is_nullable => 0, size => 255 },
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
  "circa",
  { data_type => "boolean", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 parent

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "CIDER::Schema::Result::Object",
  { id => "parent" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 objects

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "objects",
  "CIDER::Schema::Result::Object",
  { "foreign.parent" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 personal_name

Type: belongs_to

Related object: L<CIDER::Schema::Result::AuthorityName>

=cut

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

=head2 corporate_name

Type: belongs_to

Related object: L<CIDER::Schema::Result::AuthorityName>

=cut

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

=head2 topic_term

Type: belongs_to

Related object: L<CIDER::Schema::Result::AuthorityName>

=cut

__PACKAGE__->belongs_to(
  "topic_term",
  "CIDER::Schema::Result::AuthorityName",
  { id => "topic_term" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 geographic_term

Type: belongs_to

Related object: L<CIDER::Schema::Result::AuthorityName>

=cut

__PACKAGE__->belongs_to(
  "geographic_term",
  "CIDER::Schema::Result::AuthorityName",
  { id => "geographic_term" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 processing_status

Type: belongs_to

Related object: L<CIDER::Schema::Result::ProcessingStatus>

=cut

__PACKAGE__->belongs_to(
  "processing_status",
  "CIDER::Schema::Result::ProcessingStatus",
  { id => "processing_status" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 date_qualifier

Type: belongs_to

Related object: L<CIDER::Schema::Result::ItemDateQualifier>

=cut

__PACKAGE__->belongs_to(
  "date_qualifier",
  "CIDER::Schema::Result::ItemDateQualifier",
  { id => "date_qualifier" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 type

Type: belongs_to

Related object: L<CIDER::Schema::Result::ItemType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "CIDER::Schema::Result::ItemType",
  { id => "type" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 format

Type: belongs_to

Related object: L<CIDER::Schema::Result::ItemFormat>

=cut

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

=head2 record_creator

Type: belongs_to

Related object: L<CIDER::Schema::Result::RecordCreator>

=cut

__PACKAGE__->belongs_to(
  "record_creator",
  "CIDER::Schema::Result::RecordCreator",
  { id => "record_creator" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 processing_status

Type: belongs_to

Related object: L<CIDER::Schema::Result::ProcessingStatus>

=cut

__PACKAGE__->belongs_to(
  "processing_status",
  "CIDER::Schema::Result::ProcessingStatus",
  { id => "processing_status" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 object_set_objects

Type: has_many

Related object: L<CIDER::Schema::Result::ObjectSetObject>

=cut

__PACKAGE__->has_many(
  "object_set_objects",
  "CIDER::Schema::Result::ObjectSetObject",
  { "foreign.object" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 restriction_objects

Type: has_many

Related object: L<CIDER::Schema::Result::RestrictionObject>

=cut

__PACKAGE__->has_many(
  "restriction_objects",
  "CIDER::Schema::Result::RestrictionObject",
  { "foreign.object" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->many_to_many('sets' => 'object_set_objects', 'object_set');

=head2 logs

Type: has_many

Related object: L<CIDER::Schema::Result::Log>

=cut

__PACKAGE__->has_many(
    logs => "CIDER::Schema::Result::Log",
    'object',
);

=head2 creation_log

Type: has_one

Related object: L<CIDER::Schema::Result::Log>

=cut

__PACKAGE__->has_one(
    creation_log => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'create' },
      proxy => {
          creator => 'user',
          date_created => 'date',
      },
    },
);

=head2 modification_logs

Type: has_many

Related object: L<CIDER::Schema::Result::Log>

=cut

__PACKAGE__->has_many(
    modification_logs => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'update' } },
);

=head2 export_logs

Type: has_many

Related object: L<CIDER::Schema::Result::Log>

=cut

__PACKAGE__->has_many(
    export_logs => "CIDER::Schema::Result::Log",
    'object',
    { where => { action => 'export' } },
);


sub inflate_result {
    my $self = shift;

    my $result = $self->next::method(@_);

    if ( $result->record_creator ) {
        $self->ensure_class_loaded( 'CIDER::Schema::Result::Collection' );
        bless $result, 'CIDER::Schema::Result::Collection';
    }
    elsif ( $result->type ) {
        $self->ensure_class_loaded( 'CIDER::Schema::Result::Item' );
        bless $result, 'CIDER::Schema::Result::Item';
    }
    else {
        $self->ensure_class_loaded( 'CIDER::Schema::Result::Series' );
        bless $result, 'CIDER::Schema::Result::Series';
    }

    return $result;
}

sub children {
    my $self = shift;

    my $object_rs = $self->result_source->schema->resultset('Object');

    return $object_rs
           ->search( { parent => $self->id }, { order_by => 'title' } )
           ->all;
}

sub number_of_children {
    my $self = shift;

    my $object_rs = $self->result_source->schema->resultset('Object');

    return $object_rs
           ->search( { parent => $self->id } )
           ->count;
}

sub ancestors {
    my $self = shift;
    my ( $ancestors_ref ) = @_;
    $ancestors_ref ||= [];

    if ( my $parent = $self->parent ) {
        push @$ancestors_ref, $parent;
        $parent->ancestors( $ancestors_ref );
    }
    else {
        return;
    }
    return reverse @$ancestors_ref;
}

# has_ancestor: Returns 1 if the given object is an ancestor of this object.
sub has_ancestor {
    my $self = shift;
    my ( $possible_ancestor ) = @_;

    for my $ancestor ( $self->ancestors ) {
        if ( $ancestor->id == $possible_ancestor->id ) {
            return 1;
        }
    }

    return 0;
}

# Override the DBIC delete() method to work recursively on our kids,
# as well as object-set relations.
sub delete {
    my $self = shift;

    for my $child ( $self->children ) {
        $child->delete;
    }
    for my $link ( $self->object_set_objects ) {
        $link->delete;
    }
    
    $self->next::method( @_ );
}

sub cider_type {
    my $self = shift;

    my $class = ref $self;
    my ( $type ) = $class =~ /::(.\w+)$/;
    $type = lc $type;

    return $type;
}

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    my $user = $self->result_source->schema->user;

    $self->creator( $user ) if defined( $user );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    my $user = $self->result_source->schema->user;

    $self->add_to_modification_logs( { user => $user } ) if defined( $user );

    return $self;
}

sub export {
    my $self = shift;

    my $user = $self->result_source->schema->user;

    $self->add_to_export_logs( { user => $user } ) if defined( $user );
}

sub date_available {
    my $self = shift;

    my $rs = $self->export_logs->search( undef, {
        order_by => { -desc => 'timestamp' }
    } );
    return $rs->first->date;
}

1;
