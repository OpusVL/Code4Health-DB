use Test::Most;
use Test::DBIx::Class {
    schema_class => 'Code4Health::DB::Schema',
    traits => [qw/Testpostgresql/],
}, 'Organisation';

use FindBin;
my $file = "$FindBin::Bin/eauth.csv";
open my $fh, '<:encoding(utf8)', $file;
Organisation->import_csv("eauth.csv", $fh);
close $fh;
is Organisation->count, 52, 'Records imported';

done_testing;
