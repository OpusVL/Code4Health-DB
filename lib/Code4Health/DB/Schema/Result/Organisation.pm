package Code4Health::DB::Schema::Result::Organisation;

use DBIx::Class::Candy -autotable => v1, -components => ['TimeStamp'];
use Moose;
use MooseX::NonMoose;
with 'OpusVL::Preferences::RolesFor::Result::PrfOwner';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column import_file => {
    data_type => 'varchar',
    is_nullable => 1,
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

column code => {
    data_type => 'varchar',
    is_nullable => 1,
};

column name => {
    data_type => 'varchar',
    is_nullable => 1,
};

column national_grouping => {
    data_type => 'varchar',
    is_nullable => 1,
};

column high_level_health_geography => {
    data_type => 'varchar',
    is_nullable => 1,
};

column address1 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column address2 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column address3 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column address4 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column address5 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column postcode => {
    data_type => 'varchar',
    is_nullable => 1,
};

column open_date => {
    data_type => 'varchar',
    is_nullable => 1,
};

column close_date => {
    data_type => 'varchar',
    is_nullable => 1,
};

column organisation_sub_type_code => {
    data_type => 'varchar',
    is_nullable => 1,
};

column parent_organisation_code => {
    data_type => 'varchar',
    is_nullable => 1,
};

column join_parent_date => {
    data_type => 'varchar',
    is_nullable => 1,
};

column left_parent_date => {
    data_type => 'varchar',
    is_nullable => 1,
};

column contact_phone_number => {
    data_type => 'varchar',
    is_nullable => 1,
};

column amended_record_indicator => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown1 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown2 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown3 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown4 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown5 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown6 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown7 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown8 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column unknown9 => {
    data_type => 'varchar',
    is_nullable => 1,
};

column prf_owner_type_id => {
    data_type      => 'integer',
    is_nullable    => 1,
    is_foreign_key => 1
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


has_many secondary_organisation_links => 'Code4Health::DB::Schema::Result::SecondaryOrganisationLink', 'organisation_id';
many_to_many people_as_secondary_org => secondary_organisation_links => 'person';
has_many people_as_primary_org => 'Code4Health::DB::Schema::Result::Person', 'primary_organisation_id';

sub people
{
    my $self = shift;
    my $secondary = $self->people_as_secondary_org;
    return $self->people_as_primary_org->union_all([$secondary]);
}

1;

=head1 NAME

Code4Health::DB::Schema::Result::Organisation

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 id

=head2 import_file

=head2 created

=head2 updated

=head2 code

=head2 name

=head2 national_grouping

=head2 high_level_health_geography

=head2 address1

=head2 address2

=head2 address3

=head2 address4

=head2 address5

=head2 postcode

=head2 open_date

=head2 close_date

=head2 organisation_sub_type_code

=head2 parent_organisation_code

=head2 join_parent_date

=head2 left_parent_date

=head2 contact_phone_number

=head2 amended_record_indicator

=head2 unknown1

=head2 unknown2

=head2 unknown3

=head2 unknown4

=head2 unknown5

=head2 unknown6

=head2 unknown7

=head2 unknown8

=head2 unknown9

=head2 prf_owner

=head2 prf_owner_type

=head2 people

All the people associated with this organisation.

=head2 people_as_primary_org

People who have this as their primary organisation.

=head2 people_as_secondary_org

People who have this organisation as a secondary organisation.

=head2 secondary_organisation_links

Links to the secondary organisations

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
