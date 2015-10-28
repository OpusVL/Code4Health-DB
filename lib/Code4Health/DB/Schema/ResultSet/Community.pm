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

1;

