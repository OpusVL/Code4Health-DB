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
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Code4Health-DB',
   license    => '',
   #repository => 'git://github.com/OpusVL/Code4Health-DB.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Code4Health-DB',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
