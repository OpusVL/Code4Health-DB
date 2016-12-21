package Code4Health::DB::Schema::Result::Person;

use DBIx::Class::Candy -autotable => v1, -components => [qw/TimeStamp InflateColumn::DateTime/];
use Moose;
use MooseX::NonMoose;
use Try::Tiny;
use Safe::Isa;
use List::Util qw/any/;
with 'OpusVL::Preferences::RolesFor::Result::PrfOwner';
with 'OpusVL::AppKitX::PasswordReset::RolesFor::Result';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column created => {
    data_type => 'timestamp',
    is_nullable => 0,
    set_on_create => 1,
};

column updated => {
    data_type => 'timestamp',
    is_nullable => 0,
    set_on_create => 1,
    set_on_update => 1,
};

column username => {
    data_type => 'varchar',
    is_nullable => 0,
};

column surname => {
    data_type => 'varchar',
    is_nullable => 1,
};

column title => {
    data_type => 'varchar',
    is_nullable => 1,
};

column first_name => {
    data_type => 'varchar',
    is_nullable => 1,
};

column full_name => {
    data_type => 'varchar',
    is_nullable => 1,
};

column email_address => {
    data_type => 'varchar',
    is_nullable => 0,
};

column primary_organisation_id => {
    data_type => 'text',
    is_nullable => 1,
    is_foreign_key => 1,
};

column primary_organisation_other => {
    data_type => 'text',
    is_nullable => 1,
};

column prf_owner_type_id => {
    data_type      => 'integer',
    is_nullable    => 1,
    is_foreign_key => 1
};

column password_reset_hash => {
    data_type => 'text',
    is_nullable => 1,
};

column password_reset_expiry => {
    data_type => 'timestamp',
    is_nullable => 1,
};

column registrant_category => {
    data_type => 'text',
    is_nullable => 1,
};

column registrant_category_other => {
    data_type => 'text',
    is_nullable => 1,
};

column email_preferences => {
    data_type => 'text[]',
    is_nullable => 1,
};

column show_membership => {
    data_type => 'boolean',
    is_nullable => 0,
    default_value => 0
};

column is_community_admin => {
    data_type => 'boolean',
    is_nullable => 0,
    default_value => 0
};

belongs_to prf_owner => 'OpusVL::Preferences::Schema::Result::PrfOwner',
    {
        'foreign.prf_owner_id'      => 'self.id',
        'foreign.prf_owner_type_id' => 'self.prf_owner_type_id'
    };

belongs_to prf_owner_type => 'OpusVL::Preferences::Schema::Result::PrfOwnerType',
    {
        'foreign.prf_owner_type_id' => 'self.prf_owner_type_id'
    };

belongs_to primary_organisation => 'Code4Health::DB::Schema::Result::Organisation',
    {
        'foreign.code' => 'self.primary_organisation_id'
    };

has_many secondary_organisation_links => 'Code4Health::DB::Schema::Result::SecondaryOrganisationLink', 'person_id';
has_many community_links => 'Code4Health::DB::Schema::Result::CommunityLink', 'person_id';
many_to_many secondary_organisations => secondary_organisation_links => 'organisation';
many_to_many communities => community_links => 'community';

sub check_password
{
    my $self = shift;
    my $password = shift;
    return try {
            $self->_ldap_client->authenticate($self->username, $password);
        }
        catch {
            if ($_->$_isa('failure::code4health::ldap::authenticationfailure')
                || $_->$_isa('failure::code4health::ldap::noobject')) 
            {
                return 0;
            }

            $_->throw
        }
    ;
}

after delete => sub {
    my $self = shift;
    return try {
        $self->_ldap_client->remove_user($self->username)
    }
    catch { } # What do I do
};

around update => sub {
    my $orig = shift;
    my $self = shift;
    my $columns = shift;

    if ($columns and my $pass = delete $columns->{password}) {
        $self->_ldap_client->set_password($self->username, $pass);
    }

    $self->$orig($columns);
};

sub add_to_group
{
    my $self = shift;
    my $group_name = shift;
    return $self->_ldap_client->add_to_group($group_name, $self->username);
}

sub remove_from_group
{
    my $self = shift;
    my $group_name = shift;
    return $self->_ldap_client->remove_from_group($group_name, $self->username);
}

sub member_of_community
{
    my $self = shift;
    my $community_code = shift;
    return $self->communities->search({ code => $community_code })->count > 0;
}


has ldap_info => (is => 'ro', lazy => 1, builder => '_build_ldap_info');
has groups => (is => 'ro', lazy => 1, builder => '_build_groups');

sub _build_ldap_info
{
    my $self = shift;
    return try {
        $self->_ldap_client->get_user_info($self->username)
    }
    catch {
        +{}
    }
}

sub _build_groups
{
    my $self = shift;
    return $self->ldap_info->{groups} || [];
}

sub _ldap_client
{
    my $self = shift;
    return $self->result_source->schema->ldap_client;
}

sub primary_organisation_name {
    my $self = shift;

    if ($self->primary_organisation_id) {
        return $self->primary_organisation->name;
    }

    return $self->primary_organisation_other;
}

sub vanilla_roles
{
    my $self = shift;
    my $groups = $self->groups;
    my @roles;
    if(grep { /Moderator/ } @$groups)
    {
        push @roles, 'moderator';
    }
    if(grep { /Verified/ } @$groups)
    {
        push @roles, 'member';
    }
    unless(@roles)
    {
        push @roles, 'applicant';
    }
    return join ',', @roles;
}

sub _get_community
{
    my $self = shift;
    my $code = shift;
    return 0 unless $code;
    my $schema = $self->result_source->schema;
    my $c = $schema->resultset('Community');
    return $c->active->search({ code => $code })->single;
}

sub join_community
{
    my $self = shift;
    my $code = shift;
    my $community = $self->_get_community($code);
    unless($community)
    {
        return { error => 'Unable to find community' };
    }
    my $error = '';
    try
    {
        $self->create_related('community_links', { community_id => $community->id });
    }
    catch
    {
        if($_ =~ /duplicate key value violates/)
        {
            $error = 'duplicate';
        }
        else
        {
            die $_;
        }
    };
    if($error eq 'duplicate')
    {
        return { error => sprintf('Already a member of %s Community', $community->name) };
    }
    return { success => sprintf('Joined %s Community', $community->name) };
}

sub leave_community
{
    my $self = shift;
    my $code = shift;
    my $community = $self->_get_community($code);
    unless($community)
    {
        return { error => 'Unable to find community' };
    }
    $self->search_related('community_links', { community_id => $community->id })->delete;
    return { success => sprintf('Left %s Community', $community->name) };
}

sub is_verified
{
    my $self = shift;
    return any {$_ eq 'Verified'} $self->groups;
}

1;

=head1 NAME

Code4Health::DB::Schema::Result::Person

=head1 DESCRIPTION

=head1 METHODS

=head2 primary_organisation_name

If the user has a primary organisation from the Organisations table, its name is returned.

Otherwise, the value of primary_organisation_other is returned.

The return value may thus be C<undef>, if neither is set.

=head2 vanilla_roles

List of roles within vanilla this Person should have.

=head1 ATTRIBUTES

=head2 id

=head2 created

=head2 updated

=head2 primary_organisation_id

FK into Organisations table. Actually the ODS code. Nullable.

=head2 primary_organisation_other

Provides the name of the "Other" organisation the user belongs to.

Conceptually overridden by C<primary_organisation_id>. See
L<C<primary_organisation_name>>.

=head2 prf_owner_type_id

=head2 prf_owner

=head2 prf_owner_type

=head2 primary_organisation

=head2 secondary_organisation_links

=head2 username

=head2 surname

=head2 full_name

=head2 check_password

Method provided to hook into Catalyst Auth system.

=head2 ldap_info

Returns all the ldap about the user.  Note that this is
a cached attribute.

=head2 groups

Returns an arrayref of groups the user is a member of.

    $user->groups; 
    # ['Person', 'Verified']

Note that this is cached the first time you call it.

=head2 add_to_group

    $user->add_to_group('Verified');

=head2 remove_from_group

    $user->remove_from_group('Moderator');

=head2 member_of_community

    $user->member_of_community('opusvl');

Returns true if the person is a member of the community with that code.

=head2 join_community

Pass it a community code.

Returns a hash containing a key of either error or success.

=head2 leave_community

Pass it a community code.

Returns a hash containing a key of either error or success.

=head2 is_verified

Returns a true value if the user's email address has been verified. This
involves them being in the C<Verified> group in LDAP.

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
