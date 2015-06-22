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
