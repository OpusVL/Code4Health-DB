#!/usr/bin/env perl

use strict;
use warnings;
use 5.014;

use Code4Health::DB::Schema;
use Try::Tiny;
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
my $version = $option{target} || $schema->schema_version;

my %command = (
    init => \&init,
    downgrade => \&downgrade,
    upgrade => \&upgrade,
    deploy => \&deploy,
    'set-version' => \&set_version,
);

$command{$command || 'upgrade'}->($dh);

sub init {
    my $dh = shift;

    # Create source files for this version
    $dh->prepare_install;

    # Create the versioning table
    $dh->install_version_storage;

    # Register this version in the versioning table
    $dh->add_database_version({ 
        version => $schema->schema_version 
    });
}

sub set_version {
    my $dh = shift;

    try {
        $dh->prepare_install;
    }
    catch {
        if (/Cannot overwrite/) {
            say "Source files for version $version already exist.";
            return 0;
        }
        else {
            die $_;
        }
    };

    try {
        $dh->add_database_version({ 
            version => $schema->schema_version 
        });
        say "Database set to version $version";
    }
    catch {
        if (/Key.+already exists/) {
            say "Already on version $version";
            return 0;
        }
        else {
            die $_;
        }
    };
}

sub downgrade {
    my $dh = shift;
    $dh->prepare_downgrade;
    $dh->downgrade({
        to_version => $version
    });
}

sub upgrade {
    my $dh = shift;
    $dh->prepare_deploy;
    $dh->prepare_upgrade({
        to_version => $version
    });
    $dh->upgrade({
        to_version => $version
    });
}

sub deploy {
    my $dh = shift;

    # Create source files for this version
    $dh->prepare_install;

    # Install everything.
    $dh->install({
        version => $version
    });
}
