#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIContainer;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIAtom;

our @ISA = qw(CGIAtom);

sub CGIContainer::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIAtom->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "atom";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIContainer!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIContainer::init
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

sub CGIContainer::add_atom
{
    my $self = shift;
    my ($atom) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");
    debugprint(DEBUG_TRACE, "%s Adding atom '%s'...", $self->{class}, $$atom{class});

    if ( UNIVERSAL::isa($atom, "CGIAtom") ) {

        if ( ($returnval = $atom->init($self)) == E_NO_ERROR ) {
            push(@{$self->{atoms}}, $atom);
        }
        else {
            debugprint(DEBUG_ERROR, "Atom '%s' failed to initialize!", $atom->{class});
        }
    }
    else {
        $returnval = E_INVALID_OBJECT;
        debugprint(DEBUG_ERROR, "WTF!?!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIContainer::init_atoms
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "%s Entering...", $self->{class});

    debugprint(DEBUG_ERROR, "DEPRECATED!!!");
    return;

    $owner = $self unless ref($owner);

    foreach my $atom ( @{$self->{atoms}} ) {

        if ( UNIVERSAL::isa($atom, "CGIAtom") ) {
            last unless ($returnval = $atom->init($owner)) == E_NO_ERROR;
        }
        else {
            $returnval = E_INVALID_OBJECT;
            debugprint(DEBUG_ERROR, "WTF!?!");
            last;
        }
    }

    debugprint(DEBUG_TRACE, "%s Returning %s (%d)", $self->{class}, error_message($returnval), $returnval);

    return $returnval;
}

sub CGIContainer::styles
{
    my $self = shift;
    my $result;

    $result .= $self->SUPER::styles();

    foreach my $atom ( @{$self->{atoms}} ) {
        $result .= $atom->styles();
    }

    return $result;
}

sub CGIContainer::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<!-- %s -->", $self->class());
    foreach my $atom ( @{$self->{atoms}} ) {
        debugprint(DEBUG_TRACE, "Rendering '%s'...", $$atom{class});
        $self->output($atom->render());
    }

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

