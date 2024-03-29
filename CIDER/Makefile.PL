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
requires 'Catalyst::Plugin::Session::State::Cookie' => '0.17';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::DBIC::Schema' => '0.50';
requires 'Catalyst::View::TT';
requires 'Test::WWW::Mechanize::Catalyst' => '0.56';
requires 'Moose';
requires 'MooseX::MethodAttributes' => '0.25';
requires 'Class::Method::Modifiers';
requires 'Text::CSV';
requires 'Text::CSV::Slurp';
requires 'Lucy' => '0.2.2';
requires 'SQL::Translator' => '0.11006';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'CatalystX::Component::Traits' => '0.16';
requires 'Catalyst::Controller::HTML::FormFu';
requires 'HTML::FormFu::Model::DBIC' => '0.09002';
requires 'namespace::autoclean' => '0.13';
requires 'DBIx::Class' => '0.08195';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::MaterializedPath' => '0.002000';
requires 'Locale::Codes';
requires 'Config::General';
requires 'XML::LibXML';
requires 'String::CamelCase';
requires 'DateTime::Format::ISO8601';
requires 'DBD::mysql';
requires 'Readonly' => '1.03';
requires 'JSON::XS' => '2.32';
requires 'FindBin::libs' => '1.63';
requires 'HTML::FormHandler' => '0.40013';
requires 'HTML::FormHandler::Model::DBIC' => '0.23';
test_requires 'Test::More' => '0.88';
test_requires 'Test::Exception';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
