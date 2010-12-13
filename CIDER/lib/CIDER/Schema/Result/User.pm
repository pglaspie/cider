package CIDER::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'char'
  is_nullable: 1
  size: 64

=cut
    
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "char", is_nullable => 1, size => 64 },
  "password",
  { data_type => "char", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 logs

Type: has_many

Related object: L<CIDER::Schema::Result::Log>

=cut

__PACKAGE__->has_many(
  "logs",
  "CIDER::Schema::Result::Log",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 object_sets

Type: has_many

Related object: L<CIDER::Schema::Result::ObjectSet>

=cut

__PACKAGE__->has_many(
  "sets",
  "CIDER::Schema::Result::ObjectSet",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many( map_user_role => 'CIDER::Schema::Result::UserRole',
                       'user_id' );
__PACKAGE__->many_to_many( roles => 'map_user_role',
                           'role' );

# sets_not_containing: Given a CIDER object, return the this users' sets which
# _don't_ contain that object.
sub sets_not_containing {
    my $self = shift;
    my ( $object ) = @_;

    # This isn't a very sexy way of doing this, and it won't scale well if
    # users build extremely large sets. In that case, come up with a sexy
    # way to do this in pure SQL, and then express it in DBIC.
    my $user_sets_rs = $self->sets;
    my $object_sets_rs = $object->sets;

    # I wanted to do it this way, but MySQL 5 doesn't support EXCEPT. :(
#    my $exceptions_rs = $user_sets_rs->except( $object_sets_rs );

    my @not_sets;
    my %object_is_in_set;

    while ( my $object_set = $object_sets_rs->next ) {
        $object_is_in_set{ $object_set->id } = 1;
    }
    
    while ( my $user_set = $user_sets_rs->next ) {
        unless ( $object_is_in_set{ $user_set->id } ) {
            push @not_sets, $user_set;
        }
    }
    
    return @not_sets;
}
    
1;
