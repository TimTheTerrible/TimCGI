!/usr/bin/perl

use strict;

package CGIBody;

use TimUtil;
use TimObj;

our @ISA = qw(CGIAtom);

sub CGIBody::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIAtom->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "body";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIBody!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIBody::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # Style info...
        $self->{styles} = [
            {
                class		=> "body",
                tag		=> "DIV",
                properties	=> [
                    "border: dashed #00FF00 1px",
                    "background: #888888",
                    "position: fixed",
                    "width: auto",
                    "height: auto",
                    "top: 96px",
                    "right: 10em",
                    "bottom: 100px",
                    "left: 10em",
                    "font-size: 10px",
                ],
            },
        ];
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIBody::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<!-- %s -->", $self->class());
    $self->output("<div class='body'>");

    foreach my $atom ( @{$self->{atoms}} ) {
        $self->output($atom->render());
    }

    $self->output("</div>");

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

