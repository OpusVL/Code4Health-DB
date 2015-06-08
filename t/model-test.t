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

# now check the optional parameter stuff
#
ok Person->prf_defaults->create({
    name => 'mobile',
    active => 1,
    required => 0,
    data_type => 'text',
    comment => 'Mobile phone number',
    default_value => '',
});
$person->prf_set('mobile', '07888 555111');
is $person->prf_get('mobile'), '07888 555111';

my $rs = Person->with_fields({
    mobile => '07888 555111'
});
is $rs->count, 1;
is $rs->first->username, 'test';

done_testing;
