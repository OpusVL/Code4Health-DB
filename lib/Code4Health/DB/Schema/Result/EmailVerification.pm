package Code4Health::DB::Schema::Result::EmailVerification;

use DBIx::Class::Candy -autotable => v1, -components => ['TimeStamp'];
use Moose;
use MooseX::NonMoose;

primary_column hash => {
    data_type => 'text',
};

column expiry => {
    data_type => 'timestamp',
};

column email => {
    data_type => 'text',
};


1;

=head1 NAME

Code4Health::DB::Schema::Result::EmailVerification

=head1 DESCRIPTION

=head1 METHODS

=head1 ATTRIBUTES

=head2 hash

The generated unique hash

=head2 expiry

When the hash is no longer valid

=head2 email

Email address it is for (where the reset email was sent)

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
