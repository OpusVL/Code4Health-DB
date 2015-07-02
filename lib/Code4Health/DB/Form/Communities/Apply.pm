package Code4Health::DB::Form::Communities::Apply;

#--
# Boilerplate
#--
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => ( is => 'rw', default => sub { 'Bootstrap3' } );
has '+is_html5' => ( default => 1 );

#--
# Field definitions
#--

has_field 'checked_exists' => (
    type        => 'Checkbox',
    label       => q{Have you double checked our existing communities page to make sure it doesn't
already exist?},
    required    => 1,
);

has_field 'name' => ( type => 'Text' );
has_field 'postcode' => ( type => 'Text' );
has_field 'email_address' => ( type => 'Email' );
has_field 'telephone' => ( type => 'Text' );
has_field 'community_type' => ( type => 'Select', label => 'What type of community are you creating?' );
has_field 'community_type_comments' => ( type => 'TextArea' );
has_field 'member_details_1' => ( type => 'TextArea' );
has_field 'member_details_2' => ( type => 'TextArea' );
has_field 'member_details_3' => ( type => 'TextArea' );
has_field 'community_aims'   => ( type => 'TextArea', label => 'Brief outline of community aims' );
has_field 'submit'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => 'Submit response',
    element_attr => { class => ['btn', 'btn-primary'] }
);

#--
# Options
#--

sub options_community_type {
    return (
        "Area based" => "Area based (Please provide region)",
        "Specialism based" => "Specialism based (Please provide specialism)",
        "Function based" => "Function based (Please provide function)",
        "Other" => "Other (Please give details)",
    );
}

#--
# Footer
#--
no HTML::FormHandler::Moose;
1;
__END__
