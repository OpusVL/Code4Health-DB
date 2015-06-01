use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Code4Health-DB';
all_from 'lib/Code4Health/DB.pm';
author   q{OpusVL <support@opusvl.com>};
license  'opusvl';

perl_version 5.006;

tests_recursive('t');

resources (
   license    => '',
   repository => 'ssh://git/srv/git/Code4Health-DB',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Code4Health-DB',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
   'Test::Compile' => 0,
);

requires (
  'DBIx::Class' => 0,
  'DBIx::Class::Candy' => 0,
  'OpusVL::AppKit' => 0,
  'OpusVL::Preferences' => 0,
);

install_as_cpan;
auto_install;
WriteAll;
