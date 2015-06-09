package Code4Health::DB::Schema::Result::Person;

use DBIx::Class::Candy -autotable => v1, -components => ['TimeStamp'];
use Moose;
use MooseX::NonMoose;
with 'OpusVL::Preferences::RolesFor::Result::PrfOwner';

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
    data_type => 'integer',
    is_nullable => 1,
    is_foreign_key => 1,
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

belongs_to primary_organisation => 'Code4Health::DB::Schema::Result::Organisation',
    {
        'foreign.id' => 'self.primary_organisation_id'
    };

has_many secondary_organisation_links => 'Code4Health::DB::Schema::Result::SecondaryOrganistationLink', 'person_id';
many_to_many secondary_organisations => secondary_organisation_links => 'organisation';

1;

=head1 NAME

Code4Health::DB::Schema::Result::Person

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 id

=head2 created

=head2 updated

=head2 primary_organisation_id

=head2 prf_owner_type_id

=head2 prf_owner

=head2 prf_owner_type

=head2 primary_organisation

=head2 secondary_organisation_links

=head2 username

=head2 surname

=head2 full_name

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
