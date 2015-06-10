use Test::Most;
BEGIN {
    unless ($ENV{LDAP_HOST})
    {
        plan skip_all => "Set LDAP_HOST and LDAP_DN and LDAP_PASSWORD to run these tests.";
    }
}
use Test::DBIx::Class {
    schema_class => 'Code4Health::DB::Schema',
    fail_on_schema_break => 1,
    traits => [qw/Testpostgresql/],
}, 'Person';

my $schema = Person->result_source->schema;
$schema->initdb;
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

ok $user->check_password('fake');

$user->delete;

done_testing;
