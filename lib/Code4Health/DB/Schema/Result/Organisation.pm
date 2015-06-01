package Code4Health::DB::Schema::Result::Organisation;

use DBIx::Class::Candy -autotable => v1;
use Moose;
use MooseX::NonMoose;
with 'OpusVL::Preferences::RolesFor::Result::PrfOwner';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
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



1;
