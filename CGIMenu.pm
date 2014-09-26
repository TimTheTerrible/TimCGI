#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIMenu;

use TimUtil;
use TimObj;

our @ISA = qw(CGIAtom);

sub CGIMenu::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = CGIAtom->new($record);

    if ( ref($self) ) {
        bless($self, $class);

        # Set up internal state...
        $self->{class} = "menu";
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIMenu!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIMenu::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # TODO: find a menu somewhere and set it up :-/
        $self->{menus} = [
            {
                text	=> "Home",
                href	=> $self->{app}->build_url(""),
                title	=> "Return to the Home Page",
            },
            {
                text	=> "Help",
                href	=> $self->{app}->build_url("help"),
                title	=> "View the Help Page",
            },
        ];

        # Style info...
        $self->{styles} = [
            {
                class		=> "menu",
                tag		=> "DIV",
                properties	=> [
                    "border: dashed #FF0000 1px",
                    "background: #888888",
                    "position: fixed",
                    "width: 10em",
                    "height: auto",
                    "top: 96px",
                    "right: auto",
                    "bottom: 100px",
                    "left: 0",
                ],
            },
            {
                class		=> "menubox",
                tag		=> "TABLE",
                properties	=> [
                    "border: solid black 1px",
                    "width: 40%",
                    "margin: 5px",
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

sub CGIMenu::render
{
    my $self = shift;

    debugprint(DEBUG_TRACE, "%s rendering...", $self->{class});

    $self->output("<!-- %s -->", $self->class());
    $self->output("<div class='menu'>");
    $self->output("  <table class='menubox'>");

    foreach my $menu ( @{$self->{menus}} ) {
        $self->output("    <tr>");
        $self->output("      <td class='menuitem'>");
        $self->output("        <a href='%s' title='%s'>%s</a>", $$menu{href}, $$menu{title}, $$menu{text});
        $self->output("      </td>");
        $self->output("    </tr>");
    }

    $self->output("  </table>");
    $self->output("</div>");

    debugprint(DEBUG_TRACE, "%s is done rendering.", $self->{class});

    return $self->{output};
}

# Done!

return SUCCESS;

