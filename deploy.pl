#!perl

use strict;
use warnings;
use 5.014;

use Pod::Usage;
use Try::Tiny;
use DBIx::Class::DeploymentHandler;
use Getopt::Long qw(:config gnu_getopt);
use File::ShareDir 'module_dir';
use File::Find;
use File::Path;
use List::Util qw/min/;

my %option = (
    help => sub { pod2usage(verbose => 2) },
);
GetOptions(\%option, 
    'target|t=s', 
    'help|h|?', 
    'connection-info|c=s', 
    'user|u=s', 
    'password|p=s', 
    'force|f',
    'prepare|ddl',
    'verbose|v',
    'dirty',
);

my $module = shift;
my $command = shift;

unless ($module && $command) {
    pod2usage(
        verbose => 0, 
        exitval => 1, 
        message => "Missing schema name or command"
    );
}

eval "require $module" or die $@;

sub schema () {
    state $schema = $module->connect({
        dsn => $option{'connection-info'} // '',
        user => $option{'user'},
        password => $option{'password'},
    });
}

sub version () {
    $option{target} // schema->schema_version
        or die "Could not determine version from $module";
}


sub dh() {
    state $dh = DBIx::Class::DeploymentHandler->new({ 
        schema => schema,
        force_overwrite  => $option{force},
        script_directory => module_dir($module) . '/sql',
        txn_wrap => !$option{dirty},
        to_version => version,
    });
}
my %command = (
    init => \&init,
    downgrade => \&downgrade,
    upgrade => \&upgrade,
    deploy => \&deploy,
    'set-version' => \&set_version,
    prepare => \&prepare,
    cleanup => \&cleanup,
);

unless ($command{$command}) {
    pod2usage(
        verbose => 0, 
        exitval => 1, 
        message => "Unknown command $command"
    );
}

$command{$command}->();

sub _ignoring_existing_files(&);

sub init {
    if ($option{prepare}) {
        _ignoring_existing_files {
            say "Creating version table SQL";
            dh->prepare_version_storage_install;
        };
    }

    say "Creating version table...";
    dh->install_version_storage({
        version => version
    });

    set_version();
}

sub set_version {
    try {
        dh->add_database_version({ 
            version => version 
        });
        say "Database set to version " . version;
    }
    catch {
        if (/Key.+already exists/) {
            say "Already on version " . version;
            return 0;
        }
        else {
            die $_;
        }
    };
}

sub downgrade {
    if ($option{prepare}) {
        say "Preparing downgrade SQL";
        # unlikely we'd be here without the deploy, but you never know.
        _ignoring_existing_files {
            dh->prepare_deploy;
        };

        _ignoring_existing_files {
            dh->prepare_downgrade({
                from_version => version,
                to_version => version - 1,
            });
        }
    }

    if (version == schema->schema_version) {
        say "Downgrading from " . version . " to " . (version - 1);
        dh->downgrade({
            from_version => version, 
            to_version   => version - 1
        });
    }
    else {
        dh->downgrade({
            from_version => version + 1,
            to_version   => version
        });
    }
}

sub upgrade {
    # We always prepare the upgrade for just one version. If we can't get
    # to $version-1 from where we are, someone else screwed up.
    if ($option{prepare}) {
        say "Preparing upgrade from " . (version - 1) . " to " . version;
        _ignoring_existing_files {
            dh->prepare_deploy;
        };

        _ignoring_existing_files {
            dh->prepare_upgrade({
                from_version => version - 1,
                to_version => version,
            });
        };
    }

    say sprintf "Upgrading %s -> %s", dh->database_version, version;
    dh->upgrade;
}

sub deploy {
    if ($option{prepare}) {
        _ignoring_existing_files {
            say "Preparing deployment SQL for version " . version;
            dh->prepare_deploy;
        };
    }
    
    say "Deploying version " . version;
    dh->install({
        version => version
    });
}

sub prepare {
    my ($to, $from) = split /-/, version;

    # If both are specified, it was --target 1-2; else it was --target 1
    ($to, $from) = ($from, $to) if defined $from and defined $to;

    if ($to eq 'version') {
        # Should we hack the version to 1? We can't anyway (this doesn't work)
        # but maybe the answer is no.

        # no strict 'refs'; local ${schema . '::VERSION'} = 1;
        say "Creating version table SQL.";
        dh->prepare_version_storage_install;
        return;
    }

    # This awkward logic means we can prepare [$from, $to] without loading the
    # schema, avoiding the need to connect
    if ((defined $from && defined $to) or
        $to != schema->schema_version)
    {
        $from //= schema->schema_version;

        if ($from == 0) {
            # prepare a deployment directly at $to
            return dh->prepare_deploy;
        }

        say "Creating SQL for $from -> $to";
        # Note this assumes we're using integer version numbers. DH might be
        # able to tell me what "one step" looks like
        warn "Preparing a step of more than one version is not advised"
            if abs($from - $to) != 1;

        # Note we don't prepare_deploy here, for two reasons. Firstly, we should
        # already have the two YAML files; secondly, in order to downgrade we
        # have to make sure we downgrade what the YAML says, not what the schema
        # module says, or we'll try to delete tables and columns that weren't
        # actually created.
        _ignoring_existing_files {
            if ($from > $to) {
                dh->prepare_downgrade({
                    from_version => $from,
                    to_version => $to,
                });
            }
            else {
                dh->prepare_upgrade({
                    from_version => $from,
                    to_version => $to,
                })
            }
        };
    }
    else { # to (--target) == schema version
        say sprintf "Creating SQL for %s -> %s", $to - 1, $to;
        _ignoring_existing_files {
            dh->prepare_deploy
        };
        _ignoring_existing_files {
            dh->prepare_upgrade({
                from_version => $to - 1,
                to_version => $to
            });
        };
    }
}

sub cleanup {
    find({
        wanted => sub {
                # Not datamabases
                return $File::Find::prune = 1 if /_source/;
                return $File::Find::prune = 1 if /_common/;

                # Keep upgrade doodahs
                return $File::Find::prune = 1 if /upgrade/;
                return $File::Find::prune = 1 if /downgrade/;

                # Keep the *first* deployment SQL. This should be 1 but in at least
                # one case we started at 4 (like star wars)
                if (/\d/) {
                    # No need to descend into deploy dirs
                    $File::Find::prune = 1;

                    opendir my $dir, $File::Find::dir or die "$File::Find::dir: $!";
                    my ($first) = min grep /\d/, readdir $dir;
                    close $dir;
                    if ($_ > $first) {
                        rmtree($_);
                        say "Unlinked $File::Find::name; (later than $first)" if $option{verbose};
                    }
                }
            }
        },
        module_dir($module) . '/sql'
    );
}

sub _ignoring_existing_files(&) {
    my $coderef = shift;
    try {
        $coderef->();
    }
    catch {
        if (/Cannot overwrite/) {
            if ($option{verbose}) {
                say "INFO: Ignoring message: $_";
            }
            return;
        }
        die $_;
    };
}

=head1 SYNOPSIS

    deploy.pl [--target|-t VERSION] [--connection-info|-c DSN] [--force|-f]
        [--prepare|--ddl] [--user|-u USER] [--password|-p PASSWORD]
        [--verbose|-v] SCHEMA COMMAND


=head1 DESCRIPTION

Works with DBIx::Class::DeploymentHandler to upgrade or downgrade the database
between versions.

I<SCHEMA> is the module name of the schema, e.g. C<MyApp::DBIC::Schema>.
I<COMMAND> is one of the commands listed below.

In general:

=over

=item If you don't have any DeploymentHandler infrastructure yet, use C<deploy>.

=item If you have the app's tables but not the versioning table, use C<init>.
You will need to version your schema first.

=item If you have both, use C<upgrade>.

=item If you have the DH versioning table but not the app's own tables, you
might as well just start again. That table holds no value.

=back

To perform an upgrade without releasing a new version of the schema, you can use
C<-f> to recreate the current version's source files, or C<downgrade> and then
C<upgrade> again.

=head1 COMMANDS

=head2 deploy

Deploys the entire lot at the target version. If you don't have the source files
for this yet, either use L<prepare> or provide the C<--prepare> option. 

=head2 set-version

If you have the tables but you've gone out of sync, use this with C<--target> to
set the current version in the versioning table.

=head2 upgrade

Upgrades one step at a time until the DB version equals the schema version.
Requires that you have the C<sql/DBTYPE/upgrade/X-Y/*> files in the module's
sharedir, where X-Y represents each stepwise increment up to the current
version.

If you don't have those, C<--prepare> or the L<prepare> command can create the
very latest step for you; but if you need previous versions, someone screwed up
and you'll have to attend to it manually.

=head2 downgrade

Currently not working.

In theory this requires you to specify C<--target $version --prepare> to work.

Destructive reverse of upgrade. Use at your own risk.

Caveats:  Custom SQL and scripts run on upgrade will need to be dealt with 
manually if necessary.

=head2 prepare

With prepare, C<--target> may be a range, in the form of 
I<< <version> >>-I<< <version> >>. This will prepare the upgrade files for this
version range. This requires the YAML files for those two versions.

If C<--target> is not a range, then we can only prepare the deployment files for
the version of the database we are currently on. Therefore, if the target
version is not the current version, we prepare the version files for the range
I<< <target> >>-I<< <current version> >>.

    # Requires you are on version 10. Produces _source/deploy/10 YAML
    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema prepare 10
    
    # Requires _source/deploy/9 and _source/deploy/10 YAML files. Prepares
    # */upgrade/9-10 SQL files
    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema prepare 9-10

    # As above, but a downgrade
    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema prepare 10-9

=head2 init

Deploys just the DH versioning table, and registers the current schema version
therein.

You should use this when converting an existing schema to DH. This means you
will have to convert your versioning system to use integers.

Note that you will have to use the C<--target> option, because the SQL that
creates this table will be in the deployment files, which exist only for the
first version; if you try to init with the current version, you will get an
error about SQL files that can't be found.

    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema --target 1 init

=head2 cleanup

Removes stuff not required for actual deployment. Everything this leaves behind
should be in version control.

Even though this doesn't use the database you currently still have to provide it
a connection string.

=head1 OPTIONS

=head2 --prepare

=head2 --ddl

When performing a command that requires SQL or DDL (YAML) source files, prepare
them first. The default is to assume that these files are already available in
the module's sharedir.

If the source files already exist, this will be noted on STDOUT and processing
continues. You may have them replaced by providing the C<--force> option.

You cannot prepare source files for a version you are not on. Past versions
should be in version control.

Note when I tried it it didn't produce source files with C<update>, so don't rely on this
to update your DDL files correctly for release - instead run C<prepare> first.

=head2 --force

=head2 -f

Force overwriting of source files. Use this to redeploy the current version
during development.

=head2 --connection-info=DSN

=head2 -c DSN

Provide a connection string (DSN) for the database.

    deploy.pl -c dbi:Pg:dbname=mydb

=head2 --target VERSION[-VERSION]

=head2 -t VERSION[-VERSION]

Target this version number. Not all commands accept a target. Some commands
accept a range.

Defaults to the current schema version.

The special target 'version' is used to prepare the version table files.

=head2 --user=USER

=head2 -u USER

Username with which to connect to the database. Not used if not provided.

=head2 --password=PASSWORD

=head2 -p PASSWORD

Password with which to connect to the database. Not used if not provided.

=head2 --verbose

=head2 -v

Report when existing files are ignored. Default is to silently ignore them. Has
no effect when C<--force> is used.

=head2 --dirty

This performs database operations without a transaction wrapping them.  In
normal operation if an operation fails the whole update fails causing the
database state to remain as it was before.  On a development machine where
things are slightly inconsistent (perhaps you created fields manually) it can be
useful to just force through the operations and live with whatever errors
occurred.  This generally shouldn't be done on production machines if possible.

=head1 EXAMPLE PROCEDURE

=head2 Development

=over

=item 1 Set the C<$VERSION> of your schema to the next integer.

=item 1 Make changes to your Result classes. These define your schema.

=item 1 If this is the first version, deploy. If not, upgrade.

    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema --prepare -f deploy
    deploy.pl -c dbi:Pg:dbname=mydb MyApp::DB::Schema --prepare -f upgrade

This will create YAML files that represent the schema (C<_source/deploy/*>), and
the SQL associated therewith (C<PostgreSQL/deploy/*> and
C<PostgreSQL/upgrade/*-*/>).

You may wish to create the SQL and YAML without running it.

    deploy.pl MyApp::DB::Schema -f prepare
    deploy.pl MyApp::DB::Schema -t version -f prepare

The special target 'version' creates the files for the DH versioning table
without installing it. Note that no connection string is required.

=item 1 If you have more changes to make, GOTO 2. The files will be overwritten
as needed.

=item 1 If you need to, you can edit the SQL files. If you re-run prepare, you
will lose these changes.

=item 1 Run cleanup. Commit what's left.

=item 1 Release all of this. GOTO 1.

=back

=head2 Production

=over

=item 1 Install the latest version of C<MyApp::DB::Schema>.

=item 1 If a new database, use C<deploy>. If not, use C<upgrade>

    deploy.pl -c dbi:Pg:dbname=mydb_prod MyApp::DB::Schema deploy
    deploy.pl -c dbi:Pg:dbname=mydb_prod MyApp::DB::Schema upgrade

=item 1 Log out. Make coffee.

=back

Production deployment relies on your having correctly created the necessary
deployment and upgrade SQL files and added them to the distribution. The script
ensures that the module's sharedir is used to create and find these files, so as
long as the deployment process is using sharedir (which it will, because of
Dist::Zilla), you should always have the required files, and DH will just
straight up run them.
