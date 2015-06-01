#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;


BEGIN {
    use_ok( 'Code4Health::DB' ) || print "Bail out!\n";
}
use_ok 'Code4Health::DB::Schema';

diag( "Testing Code4Health::DB $Code4Health::DB::VERSION, Perl $], $^X" );
done_testing;
