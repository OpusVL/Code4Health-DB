package Code4Health::DB::Schema;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::Schema';
with 'OpusVL::AppKit::RolesFor::Schema::DataInitialisation';
with 'OpusVL::Preferences::RolesFor::Schema';
__PACKAGE__->setup_preferences_schema;


__PACKAGE__->load_namespaces();

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Code4Health::DB::Schema

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
