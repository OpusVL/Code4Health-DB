package Code4Health::DB::Schema::Result::SecondaryOrganistationLink;

use DBIx::Class::Candy -autotable => v1, -components => ['TimeStamp'];
use Moose;
use MooseX::NonMoose;

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column person_id => {
    data_type => 'integer',
    is_nullable => 0,
    is_foreign_key => 1,
};

column organisation_id => {
    data_type => 'integer',
    is_nullable => 0,
    is_foreign_key => 1,
};

column created => {
    data_type => 'timestamp',
    is_nullable => 0,
    set_on_create => 1,
};

belongs_to person => 'Code4Health::DB::Schema::Result::Person',
    {
        'foreign.id' => 'self.person_id'
    };


belongs_to organisation => 'Code4Health::DB::Schema::Result::Organisation',
    {
        'foreign.id' => 'self.organisation_id'
    };


=head1 NAME

Code4Health::DB::Schema::Result::SecondaryOrganistationLink

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 id

=head2 person_id

=head2 organisation_id

=head2 created

=head2 person

=head2 organisation


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
