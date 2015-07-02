package Code4Health::DB::Form::Supporters::Apply;

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

has_field 'name' => ( type => 'Text' );
has_field 'postcode' => ( type => 'Text' );
has_field 'email_address' => ( type => 'Email' );
has_field 'telephone' => ( type => 'Text' );
has_field 'service_type' => ( type => 'Select', label => 'What type of community are you creating?' );
has_field 'service_type_comments' => ( type => 'TextArea' );
has_field 'how_it_contributes' => (
    type    => 'TextArea',
    label   => 'Please detail how this contributes to the growth of the community'
);
has_field 'future_support' => (
    type    => 'TextArea',
    label   => 'What future support will you provide to a community?',
);
has_field 'vat_number' => (
    type    => 'Text',
    label   => 'Companies House and VAT Reg number (if known)'
);
has_field 'public_indemnity_details' => (
    type    => 'Text',
    label   => 'Details of Public Indemnity and Public liability (if known)',
);

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

sub options_service_type {
    return (
        "Training"      => "Training",
        "Development"   => "Development",
        "Other"         => "Other (Please specify)",
    );
}

#--
# Footer
#--
no HTML::FormHandler::Moose;
1;
__END__
