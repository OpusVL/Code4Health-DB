#!/usr/bin/env perl

use strict;
use warnings;
use 5.014;

use Code4Health::DB::Schema;
use DBIx::Class::DeploymentHandler;
use Getopt::Long qw(:config gnu_getopt);

my %option;
my $command = shift;

GetOptions(\%option, 'target=f');

my $schema = Code4Health::DB::Schema->connect({
    dsn => 'dbi:Pg:host=localhost;dbname=code4health',
    user => 'alastair.mcgowan',
    password => 'amdpass'
});
my $dh = DBIx::Class::DeploymentHandler->new({ schema => $schema });

my %command = (
    install => \&install,
    downgrade => \&downgrade,
    upgrade => \&upgrade,
    deploy => \&deploy,
);

my $version = $option{target} || $schema->schema_version;
$command{$command || 'upgrade'}->($dh);

sub install {
    my $dh = shift;
    #$dh->prepare_version_storage_install;
    $dh->prepare_install({
        version => $version
    });
    $dh->install_version_storage;
    $dh->add_database_version({ 
        version => $version 
    });
}

sub downgrade {
    my $dh = shift;
    $dh->downgrade;
}

sub upgrade {
    my $dh = shift;
    $dh->prepare_upgrade({
        to_version => $version
    });
    $dh->upgrade({
        to_version => $version
    });
}

sub deploy {
    my $dh = shift;
    $dh->prepare_install({
        version => $version
    });
    $dh->install_version_storage;
    $dh->install({
        version => $version
    });
}
