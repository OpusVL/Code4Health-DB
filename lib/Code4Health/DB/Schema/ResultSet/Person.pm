package Code4Health::DB::Schema::ResultSet::Person;

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

__PACKAGE__->meta->make_immutable;
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

