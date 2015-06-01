#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Compile;
my $test = Test::Compile->new();
$test->all_files_ok();

use Code4Health::DB;

diag( "Testing Code4Health::DB $Code4Health::DB::VERSION, Perl $], $^X" );
done_testing;
