#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIAtom;

use TimUtil;
use TimObj;
use TimCGI;

our @ISA = qw(TimObj);

sub CGIAtom::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = TimObj->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "CGIAtom";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIAtom!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIAtom::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        debugprint(DEBUG_TRACE, "My Element Class: '%s'", $self->{class});

        # Prepare the output list...
        $self->{output} = [];

        # Hook the CGIPage object...
        if ( UNIVERSAL::isa($self->{app}->{page}, "CGIPage") ) {

            $self->{page} = $self->{app}->{page};
        }
        else {
            $returnval = E_INVALID_OBJECT;
            debugprint(DEBUG_ERROR, "\$self->{app} has no CGIPage!?!");
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIAtom::styles
{
    my $self = shift;

    my $result = ""; 
    foreach my $style ( @{$self->{styles}} ) { 

        my $properties = ""; 
        foreach my $property ( @{$$style{properties}} ) { 
            $properties .= sprintf("\t%s;\n", $property);
        }   

        $result .= sprintf("%s.%s\n\t{\n%s\t}\n",
            $$style{tag}, $$style{class}, $properties,
        );  
    }   

    return $result;
}

sub CGIAtom::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<!-- %s -->", $self->class());
    $self->output($self->{text});

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

#
# Private utility functions - NEVER override these
#
sub CGIAtom::output
{
    my $self = shift;

    # Did we get an array of pre-formatted lines to tack on the end?
    if ( ref($_[0]) ) {
        my @lines = @{$_[0]};
        # Lesson Learned: while() won't work on arrays that contain "0"s...
        while ( defined(my $line = shift(@lines)) ) {
            push(@{$self->{output}}, $line);
        }
    }
    # ...or did we get a format specifier and some arguments?
    else {
        my ($fmt,@args) = @_;
        my $fmt_safe = $fmt; $fmt_safe =~ s/%/%%/g;

        my $line = sprintf($fmt, @args);

        if ( $line eq "" ) {
            push(@{$self->{output}}, "");
        }
        else {

            foreach my $part ( split("\n", $line) ) {
                push(@{$self->{output}}, $part);
            }
        }
    }

    #debugprint(DEBUG_OUTPUT, "Returning.");

    return scalar(@{$self->{output}});
}

sub CGIAtom::indent
{
    my $self = shift;
    # Fuck you, Perl; fuck you.
    return map({"  " . $_} @{$_[0]});
}

# Done!

return SUCCESS;

