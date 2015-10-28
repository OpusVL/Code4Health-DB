package Code4Health::DB::Schema::Result::Community;

use DBIx::Class::Candy -autotable => v1, -components => [qw/TimeStamp InflateColumn::DateTime/];
use Moose;
use MooseX::NonMoose;
use Try::Tiny;
use Safe::Isa;

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column name => {
    data_type => 'varchar',
    is_nullable => 0,
};

column code => {
    data_type => 'varchar',
    is_nullable => 0,
};

column status => {
    data_type => 'varchar',
    is_nullable => 0,
    default_value => 'active',
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

has_many community_links => 'Code4Health::DB::Schema::Result::CommunityLink', 'community_id';
many_to_many people => community_links => 'person';

# FIXME: add a unique index on the code field.

1;

=head1 NAME

Code4Health::DB::Schema::Result::Community

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 id

=head2 name

=head2 status

=head2 created

=head2 updated

=head2 community_links


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
