package Code4Health::DB::Schema::ResultSet::Person;

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';
with 'OpusVL::Preferences::RolesFor::ResultSet::PrfOwner';

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

sub add_user
{
    my $self = shift;
    my $data = shift;
    my $schema = $self->result_source->schema;
    my $password = delete $data->{password};
    my $username = $data->{username};
    my $fullname = $data->{full_name};
    my $surname = $data->{surname};

    my $user = $self->search({ email_address => $username })->first;
    return ($user, 1) if $user;

    $user = $self->create($data);
    my $ldap = $schema->ldap_client;
    my $guard = $schema->txn_scope_guard;
    my $user_id = $self->next_uid;
    $ldap->add_user($username, $fullname, $surname, $password, $self->group_id, $user_id);
    $guard->commit;
    return $user;
}

has group_id => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_group_id');

sub _build_group_id
{
    my $self = shift;
    my $schema = $self->result_source->schema;
    my $ldap = $schema->ldap_client;
    my $info = $ldap->get_group_info('Person');
    return $info->{gidNumber};
}

sub next_uid
{
    my $self = shift;

    my $next_uid;
    my $query = 'select nextval(?);';
    $self->result_source->storage->dbh_do(sub {
        my ($storage, $dbh) = @_;
        my $result = $dbh->selectcol_arrayref($query, {}, 'next_uid');
        $next_uid = $result->[0];
    });
    return $next_uid;
}

sub initdb
{
    my $self = shift;
    # setup sequence
    my $query = 'CREATE SEQUENCE next_uid MINVALUE 10000 MAXVALUE 50000';
    $self->result_source->storage->dbh_do(sub {
        my ($storage, $dbh) = @_;
        $dbh->do($query);
    });
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Code4Health::DB::Schema::ResultSet::Person

=head1 DESCRIPTION

=head1 METHODS

=head2 BUILDARGS

=head2 add_user

Create a user.  Use this method rather than create directly to ensure the
corresponding LDAP user is created.

=head2 initdb

Called when a new database is setup.

=head2 next_uid

Returns the next userid.  This is stored in the postgres database as a sequence.

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

