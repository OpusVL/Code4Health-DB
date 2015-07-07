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

GetOptions(\%option, 'target=f', 'help|h|?');

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
    help => \&help,
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
        version => $schema->schema_version
    });
}

sub help {
    say <<EOHELP
Usage: 
    $0 <command> [--target n] [--help|-h|-?]

Default command is upgrade.

Works with DBIx::Class::DeploymentHandler to upgrade or downgrade the database
between versions.

To go between versions, source files (YAML format) are created by DH to
represent the database at each version.  Then it can diff these structures and
produce SQL for the various versions.

Options:
    --target n
        Targets version n. If omitted, targets the schema_version in
        Code4Health::DB::Schema

Commands:
    init
        Sets up DeploymentHandler's table and YAML files for the current
        version. You can't use --target for this because that would require you
        to actually have the schema files checked out to that version.

    upgrade
        Upgrades to the targetted version.

    downgrade
        Downgrades to the targetted version, with variable success.

    set-version
        Tells DeploymentHandler that the database is currently on the targetted
        version.

    deploy
        Deploys the entire database at the current version. --target is ignored
        here because the code is used to produce this; you have to check out the
        right version of the files to deploy that version.

EOHELP
}
