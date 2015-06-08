use Test::Most;
use Test::DBIx::Class {
    schema_class => 'Code4Health::DB::Schema',
    fail_on_schema_break => 1,
}, 'Organisation', 'Person';

ok my $org = Organisation->create({
    code => 'test',
    name => 'Test',
});

ok my $person = Person->create({
    username => 'test',
    full_name => 'Test Person',
    surname => 'Person',
});

$person->primary_organisation_id($org->id);
$person->update;

is $org->people->count, 1;

ok my $person2 = Person->create({
    username => 'another',
    full_name => 'Another Person',
    surname => 'Person',
});

$person2->create_related('secondary_organisation_links', { organisation_id => $org->id });
is $org->people->count, 2;

done_testing;
