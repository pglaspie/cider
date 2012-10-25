package CIDER::View::TT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    CATALYST_VAR => 'c',
    render_die => 1,
    WRAPPER => 'wrapper.tt',
);

=head1 NAME

CIDER::View::TT - TT View for CIDER

=head1 DESCRIPTION

TT View for CIDER.

=head1 SEE ALSO

L<CIDER>

=head1 AUTHOR

Jason McIntosh

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
