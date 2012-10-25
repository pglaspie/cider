package CIDER;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    Authentication

    Session
    Session::Store::File
    Session::State::Cookie

    Scheduler

    StackTrace

    Unicode::Encoding
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in cider.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

if ( defined $ENV{CIDER_SITE_CONFIG} ) {
    __PACKAGE__->config( 'Plugin::ConfigLoader' => {
        file => $ENV{CIDER_SITE_CONFIG},
    } );
}

__PACKAGE__->config(
    name => 'CIDER',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,

    default_view => 'TT',

    encoding => 'utf-8',

    authentication => {
        realms => {
            default => {
                class => 'SimpleDB',
                user_model => 'CIDERDB::User',
            },
        },
    },
    'Plugin::Session' => {
        flash_to_stash => 1,
        expires => 1000000,
        cookie_expires => 1000000,
    },
    stacktrace => {
        verbose => 2,
    },
    'Controller::HTML::FormFu' => {
        model_stash => {
            schema => 'CIDERDB',
        },
    },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

CIDER - Catalyst based application

=head1 SYNOPSIS

    script/cider_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<CIDER::Controller::Root>, L<Catalyst>

=head1 AUTHORS

Jason McIntosh, Doug Orleans

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
