package Code4Health::DB::Schema::ResultSet::EmailVerification;

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::ResultSet';

use Data::UUID;
use Digest::SHA1 qw/sha1_hex/;

sub generate {
    my ($self, $email) = @_;

    my $uuid = Data::UUID->new->create_str;
    my $hash = sha1_hex($email . $uuid);

    return $self->create({
        hash => $hash,
        email => $email,
        expiry => DateTime->now->add(days => 3),
    });
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Code4Health::DB::Schema::ResultSet::EmailVerification

=head1 DESCRIPTION

=head1 METHODS

=head2 generate ($email_address)

Generates a verification hash and saves it against the given email address.

Expires in 3 days.

=head1 ATTRIBUTES

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

