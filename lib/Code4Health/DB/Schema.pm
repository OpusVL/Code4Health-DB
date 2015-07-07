package Code4Health::DB::Schema;

use Moose;
use namespace::autoclean;
use Code4Health::LDAP;

extends 'DBIx::Class::Schema';
with 'OpusVL::AppKit::RolesFor::Schema::DataInitialisation';
with 'OpusVL::Preferences::RolesFor::Schema';

__PACKAGE__->load_components('DeploymentHandler::VersionStorage::Standard::Component');
__PACKAGE__->setup_preferences_schema;

has host => (is => 'rw', isa => 'Str');
has dn => (is => 'rw', isa => 'Str');
has user => (is => 'rw', isa => 'Str', default => 'admin');
has password => (is => 'rw', isa => 'Str');

has ldap_client => (is => 'ro', lazy => 1, builder => '_setup_ldap_client');

sub _setup_ldap_client
{
    my $self = shift;
    my $ldap = Code4Health::LDAP->new({ 
        host => $self->host,
        dn => $self->dn,
        user => $self->user,
        password => $self->password,
    });
    return $ldap;
}

sub schema_version { 2 }

__PACKAGE__->load_namespaces();

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Code4Health::DB::Schema

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 schema_version

Provides the version of the schema to DeploymentHandler. Increment this if you
ever change the shape of the schema.

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
