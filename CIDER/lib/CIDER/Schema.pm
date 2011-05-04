package CIDER::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-02 16:49:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9E4noPv7F0YFb1t8JbIGlg

# The 'user' field is used when adding to the audit trail.  Make sure
# it's set before inserting or updating any objects!

__PACKAGE__->mk_classdata( 'user' );

1;
