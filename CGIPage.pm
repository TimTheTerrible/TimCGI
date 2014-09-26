#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIPage;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIContainer;

our @ISA = qw(CGIContainer);

sub CGIPage::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIContainer->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGIPage";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIPage!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIPage::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {
        # ...
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIPage::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("Content-Type: text/html"); # Add an extra \n for HTML parsers...
    $self->output("");
    $self->output("<html>");
    $self->output("  <head>");
    $self->output("    <title>%s</title>", $self->{title});
    $self->output("    <style type='text/css'>");
    $self->output($self->styles());
    $self->output("    </style>");
    $self->output("  </head>");
    $self->output("  <body class='mainpage'>");

    # Draw our atoms...
    foreach my $atom ( @{$self->{atoms}} ) {
        #$self->output($self->indent($atom->render()));
        $self->output($atom->render());
    }

    $self->output("  </body>");
    $self->output("</html>");  

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

