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
    code => 'hackers',
    name => 'Hackers',
});
ok my $alt = Community->create({
    code => 'alt',
    name => 'Alternative',
});
$person->create_related('community_links', { community_id => $community->id });
is $person->communities->count, 1;
ok $person->member_of_community('hackers');
ok !$person->member_of_community('alt');
is $community->people->count, 1;

$community->delete;
is $org->people->count, 2;
ok !$person->member_of_community('hackers');
my $res = $person->join_community('alt');
eq_or_diff $res, { success => 'Joined Alternative Community' };
$res = $person->join_community('alt');
ok $person->member_of_community('alt');
eq_or_diff $res, { error => 'Already a member of Alternative Community' };
$res = $person->join_community('hackers');
eq_or_diff $res, { error => 'Unable to find community' };
$res = $person->leave_community('alt');
eq_or_diff $res, { success => 'Left Alternative Community' };
$res = $person->leave_community('alt');# don't really care
eq_or_diff $res, { success => 'Left Alternative Community' };
$res = $person->leave_community('hackers');
eq_or_diff $res, { error => 'Unable to find community' };

done_testing;
