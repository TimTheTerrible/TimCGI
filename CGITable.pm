#!/usr/bin/perl

use strict;

package CGITable;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIContainer;

our @ISA = qw(CGIContainer);

sub CGITable::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIContainer->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "TimCGI::CGITable";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGITable!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGITable::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # Search the table data for CGIAtoms and add them...
        foreach my $row ( @{$self->{tabledata}{rows}} ) {

            foreach my $cell ( @{$row} ) {

                if ( UNIVERSAL::isa($$cell{content}, "CGIAtom") ) {

                    $self->add_atom($$cell{content});
                }
            }
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGITable::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    my $table = $self->{tabledata};
    debugprint(DEBUG_TRACE, "Rendering %s rows", scalar(@{$$table{rows}}));
    debugdump(DEBUG_DUMP, "table", $table);

    $self->output("<!-- %s -->", $self->{class});
    $self->output("<table class='%s'>", $$table{class});

    $self->draw_row($$table{header}, "TH") if defined($$table{header});

    foreach my $row ( @{$$table{rows}} ) {

        debugdump(DEBUG_DUMP, "row", $row);

        $self->draw_row($row);
    }

    $self->draw_row($$table{footer}, "TH") if defined($$table{footer});

    $self->output("</table>");

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

sub CGITable::draw_row
{
    my $self = shift;
    my ($row,$alt_tag) = @_;
    my $tag = "TD";
    my @attrs = qw(colspan rowspan align width height);

    $self->output("  <tr>");
    foreach my $cell ( @{$row} ) {

        # Collect the tag's attributes and lay them out...
        my $attr_string;
        foreach my $attr ( @attrs ) {
            $attr_string .= sprintf(" %s='%s'", $attr, $$cell{$attr}) if exists($$cell{$attr});
        }

        $self->output("    <%s %s class='%s'>", $alt_tag ? $alt_tag : $tag, $attr_string, $$cell{class});

        if ( UNIVERSAL::isa($$cell{content}, "CGIAtom") ) {
             $self->output($$cell{content}->render());
        }
        else {
            # TODO: For some unknown reason CGIAtom::output() reacts stupidly to $$cell{content} == undef() or 0...
            #$self->output(defined($$cell{content}) ? $$cell{content} : "&nbsp;<!-- cell contained undef -->");
            if ( exists($$cell{content}) ) {
                $self->output("      %s", $$cell{content});
            }
            else {
                $self->output("      &nbsp;");
            }
        }

        $self->output("    </%s>", $alt_tag ? $alt_tag : $tag);
    }
    $self->output("  </tr>");
}

# Done!

return SUCCESS;

