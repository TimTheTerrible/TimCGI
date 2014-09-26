#!/usr/bin/perl

use strict;

package CGIInput;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIAtom;

our @ISA = qw(CGIAtom);

sub CGIInput::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIAtom->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGIInput";
        debugprint(DEBUG_TRACE, "\$self->{name} = '%s'", $self->{name});
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIInput!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIInput::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {
        # TODO: stuff...
        debugprint(DEBUG_TRACE, "\$self->{name} = '%s'", $self->{name});
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIInput::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<input type='%s' name='%s' value='%s' class='%s'%s>",
        $self->{type},
        $self->{name},
        $self->{value},
        $self->{cssclass},
        $self->{type} eq "image" ? sprintf(" src='%s'", $self->{src}) : "",
    );

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

