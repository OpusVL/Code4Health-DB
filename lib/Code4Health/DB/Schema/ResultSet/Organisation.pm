package Code4Health::DB::Schema::ResultSet::Organisation;

use Moose;
use MooseX::NonMoose;
use Text::CSV;
extends 'DBIx::Class::ResultSet';
with 'OpusVL::Preferences::RolesFor::ResultSet::PrfOwner';
__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

my @csv_fields = qw/code name national_grouping high_level_health_geography address1 address2 address3 address4 address5 postcode open_date close_date unknown1 organisation_sub_type_code parent_organisation_code join_parent_date left_parent_date contact_phone_number unknown2 unknown3 unknown4 amended_record_indicator unknown5 unknown6 unknown7 unknown8 unknown9/;

sub import_csv
{
    my $self = shift;
    my $import_filename = shift;
    my $fh = shift;
    my $args = shift || {};
    my $csv_args = $args->{csv} // { binary => 1 };
    my $csv = Text::CSV->new($csv_args);
    $csv->column_names(@csv_fields);

    # NOTE: you can't use a transaction here because Preferences relies on
    # autopopulated values.
    while(my $row = $csv->getline_hr($fh))
    {
        $row->{import_file} = $import_filename;
        $self->update_or_create($row);
    }
    $csv->eof or die $csv->error_diag();
}

1;

=head1 NAME

Code4Health::DB::Schema::ResultSet::Organisation

=head1 DESCRIPTION

=head1 METHODS

=head2 BUILDARGS

=head2 import_csv

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
