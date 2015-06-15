use Test::Most;
BEGIN {
    unless ($ENV{LDAP_HOST} && $ENV{LIVE_DB})
    {
        plan skip_all => "Set LDAP_HOST and LDAP_DN, LDAP_PASSWORD, LIVE_DB,LIVE_DB_USER,LIVE_DB_PASS to run these tests.";
    }
}
use Test::DBIx::Class {
    connect_info => [$ENV{LIVE_DB},$ENV{LIVE_DB_USER},$ENV{LIVE_DB_PASS}],
    schema_class => 'Code4Health::DB::Schema',
    deploy_db => 0,
}, 'Person';

my $schema = Person->result_source->schema;
$schema->host($ENV{LDAP_HOST});
$schema->dn($ENV{LDAP_DN});
$schema->user($ENV{LDAP_USER} || 'admin');
$schema->password($ENV{LDAP_PASSWORD});

ok my $user = Person->add_user({
    username => 'user',
    password => 'fake',
    full_name => 'A User',
    surname => 'User',
    email_address => 'user@opusvl.com',
    title => 'Mx',
    first_name => 'A',
});


done_testing;
