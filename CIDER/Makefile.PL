#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'CIDER';
all_from 'lib/CIDER.pm';

requires 'Catalyst::Runtime' => '5.80029';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::DBIC::Schema' => '0.50';
requires 'Moose';
requires 'Class::Method::Modifiers';
requires 'Text::CSV';
requires 'Text::CSV::Slurp';
requires 'KinoSearch' => '0.31';
requires 'SQL::Translator' => '0.11006';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'CatalystX::Component::Traits' => '0.16';
requires 'HTML::FormFu::Model::DBIC';
requires 'namespace::autoclean';
requires 'DBIx::Class::TimeStamp';
requires 'Locale::Codes';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'XML::LibXML';
test_requires 'Test::More' => '0.88';
test_requires 'Test::Exception';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
