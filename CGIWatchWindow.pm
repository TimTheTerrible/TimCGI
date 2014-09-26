#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIWatchWindow;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGITable;

our @ISA = qw(CGITable);

sub CGIWatchWindow::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGITable->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGIWatchWindow";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIWatchWindow!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIWatchWindow::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        $self->{styles} = [
            {
                class		=> "ww_frame",
                tag		=> "TABLE",
                properties	=> [
                    "border: dashed #FFFFFF 1px",
                    "background: #888888",
                    "width: 100%",
                    "vertical-align: middle",
                    "text-align: left",
                ],
            },
            {
                class		=> "ww_cell",
                tag		=> "TD",
                properties	=> [
                    "font-size: 10pt",
                ],
            },
        ];

        # Build the table data...
        my $tabledata = {
            class	=> "ww_frame",
        };

        foreach my $var ( keys(%{$self->{app}{vars}}) ) {
            my $row = [ { class => "ww_cell", content => sprintf("%s: %s", $var, $self->{app}->get_var_packed($var)) }, ];
            push(@{$$tabledata{rows}}, $row);
        }

        $self->{tabledata} = $tabledata;
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

# Done!

return SUCCESS;

