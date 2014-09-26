#!/usr/bin/perl

use strict;

package CGISelect;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIAtom;

our @ISA = qw(CGIAtom);

sub CGISelect::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIAtom->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGISelect";

        $self->{options} = [] unless exists($self->{options});
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGISelect!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGISelect::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # TODO: stuff...
        $self->{selected} = $self->{app}->get_var($self->{name}) unless exists($self->{selected});

        debugprint(DEBUG_TRACE, "%s (%s) = %s", $self->{name}, $self->{selected}, $self->{options});
        debugdump(DEBUG_DUMP, "options", $self->{options});

    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGISelect::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<select name='%s' class='%s'>",
        $self->{name},
        $self->{cssclass},
    );

    debugprint(DEBUG_TRACE, "selected = '%s'", $self->{selected});

    foreach my $option ( @{$self->{options}} ) {

        debugdump(DEBUG_DUMP, "option", $option);

        # if this is the selected item, mark it...
        if ( $self->{selected} =~ /[A-Za-z]*/ ) {
            $$option{selected} = $self->{selected} eq $$option{value};
        }
        else {
            $$option{selected} = $self->{selected} == $$option{value};
        }

        $self->output("  <option %s value='%s'>",
            $$option{selected} ? "selected" : "",
            $$option{value});
        $self->output("    %s", $$option{name}); 
        $self->output("  </option>");
    }

    $self->output("</select>");

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

