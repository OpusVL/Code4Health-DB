use Test::Most;
use Test::DBIx::Class {
    schema_class => 'Code4Health::DB::Schema',
    traits => [qw/Testpostgresql/],
}, 'Organisation', 'Person', 'Community';

ok my $org = Organisation->create({
    code => 'test',
    name => 'Test',
});

ok my $person = Person->create({
    username => 'test',
    full_name => 'Test Person',
    surname => 'Person',
    email_address => 'support@opusvl.com',
});

$person->primary_organisation_id($org->id);
$person->update;

is $org->people->count, 1;

ok my $person2 = Person->create({
    username => 'another',
    full_name => 'Another Person',
    surname => 'Person',
    email_address => 'support@opusvl.com',
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

ok my $community = Community->create({
    name => 'Hackers',
});
$person->create_related('community_links', { community_id => $community->id });
is $person->communities->count, 1;
is $community->people->count, 1;

$community->delete;
is $org->people->count, 2;

done_testing;
