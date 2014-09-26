#!/usr/bin/perl

use strict;

package CGIForm;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIContainer;

our @ISA = qw(CGIContainer);

sub CGIForm::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIContainer->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGIForm";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIForm!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIForm::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # DO Something.
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIForm::build_carryovers
{
    my $self = shift;

    # Hidden session state vars...
    debugdump(DEBUG_TRACE, "carryovers", $self->{formdata}{carryovers});
    foreach my $var ( @{$self->{formdata}{carryovers}} ) {
        my $input = { type => "hidden", name => $$var{name}, value => $$var{value}, class => $$var{class}, };
        $self->add_atom(CGIInput->new($input));
    }
}

sub CGIForm::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    my $formdata = $self->{formdata};

    $self->output("<!-- %s -->", $self->class());
    $self->output("<form action='%s' method='%s'>", $$formdata{action}, $$formdata{method});

    $self->SUPER::render();

    $self->output("</form>");

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

