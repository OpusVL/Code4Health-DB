package Code4Health::DB::Form::Communities::PostUpdate;

=head1 NAME

Code4Health::DB::Form::Communities::PostUpdate

=head1 DESCRIPTION

A form for posting a community update. Its function is to collect these four
pieces of information, but the idea is just to stick them together into a single
markdown page and forget about it.

=head1 FIELDS

=head2 title

=head2 update

Both required

=head2 future_plans

=head2 help (How can you help?)

Both optional

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => ( is => 'rw', default => sub { 'Bootstrap3' } );
has '+is_html5' => ( default => 1 );

#has_field 'community' => (
#    type => 'Text',
#    element_attr => {
#        readonly => 'readonly'
#    },
#);

has_field 'title' => ( 
    type => 'Text', 
    required => 1 
);
has_field 'update' => (
    type => 'TextArea' ,
    required => 1 
);
has_field 'future_plans' => (
    type => 'TextArea',
);
has_field 'help' => (
    type => 'TextArea',
    label => "How can the community get involved?",
);

has_field 'submit' => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => "Submit post",
    element_attr => { class => ['btn', 'btn-primary'] }
);

has_field 'preview' => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => "Preview post",
    element_attr => { class => ['btn', 'btn-primary'] }
);

=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

no HTML::FormHandler::Moose;
1;
__END__
