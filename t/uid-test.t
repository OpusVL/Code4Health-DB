use Test::Most;
use Test::DBIx::Class {
    schema_class => 'Code4Health::DB::Schema',
    fail_on_schema_break => 1,
    traits => [qw/Testpostgresql/],
}, 'Person';

Person->initdb;
is Person->next_uid, 10000;
is Person->next_uid, 10001;

done_testing;

