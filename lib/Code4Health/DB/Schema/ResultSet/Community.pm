package Code4Health::DB::Schema::ResultSet::Community;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub active
{
    my $self = shift;
    return $self->search({ status => 'active' });
}

sub by_name
{
    my $self = shift;
    return $self->search(undef, { order_by => ['name'] });
}

sub lookup_code
{
    my $self = shift;
    my $code = shift;
    return $self->active->search({ code => $code })->single;
}

1;


=head1 NAME

Code4Health::DB::Schema::ResultSet::Community

=head1 DESCRIPTION

=head1 METHODS

=head2 active

=head2 by_name

=head2 lookup_code

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
