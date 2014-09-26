#!/usr/bin/perl

use strict;

package TimCGI;

use TimUtil;
use TimApp;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(
    draw_error
    flip_class
    VARTYPE_INT
    VARTYPE_FLOAT
    VARTYPE_STRING
    VARTYPE_BOOL
    VARTYPE_BITMASK
    VARTYPE_ENUM
    E_CGI_NONE
    E_INVALID_VARTYPE
);

#
# Constants
#

use constant VARTYPE_INT	=> 1;
use constant VARTYPE_FLOAT	=> 2;
use constant VARTYPE_STRING	=> 3;
use constant VARTYPE_BOOL	=> 4;
use constant VARTYPE_BITMASK	=> 5;
use constant VARTYPE_ENUM	=> 6;

#
# Debug Mode Definitions
#

use constant DEBUG_CGI		=> 0x00000100;
use constant DEBUG_OUTPUT       => 0x00000200;

my %DebugModes = (
    (DEBUG_CGI)	=> {
        name	=> "cgi",
        title	=> "DEBUG_CGI",
    },
    (DEBUG_OUTPUT)        => {
        name    => "output",
        title   => "DEBUG_OUTPUT",
    },  
);

#
# Error Message Definitions
#

use constant E_CGI_NONE		=> 69000;
use constant E_INVALID_VARTYPE	=> 69001;

my %ErrorMessages = (
    (E_CGI_NONE)	=> {
        title	=> "E_CGI_NONE",
        message	=> "No CGI Error",
    },
    (E_INVALID_VARTYPE)	=> {
        title	=> "E_INVALID_VARTYPE",
        message	=> "Invalid VARTYPE specifier",
    },
);

#
# Parameter Definitions
#

my %ParamDefs = (
);

#
# Utility Routines...
#

sub TimCGI::draw_error
{
    my ($error) = @_;

    printf("Content-Type: text/html\n\n");
    printf("<html>\n");
    printf("  <head>\n");
    printf("    <title>An error occurred while processing your request</title>\n");
    printf("  </head>\n");
    printf("  <body>\n");
    printf("    <h1>An error occurred while processing your request</h1>\n");
    printf("    <p>%s</p>\n", error_message($error));
    printf("    <pre>\n");
    foreach my $line ( @TimUtil::ErrorLog ) {
        printf("    %s\n", $line);
    }
    printf("    </pre>\n");
    printf("  </body>\n");
    printf("</html>\n");  
}

sub flip_class
{
    my ($class) = @_;

    return $class eq "even" ? "odd" : "even";
}

sub parse_vars
{
    my ($vars) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    use CGI qw (:standard );

    debugdump(DEBUG_DUMP, "vars", $vars);

    foreach my $var ( keys(%{$vars}) ) {

        debugprint(DEBUG_TRACE, "Parsing '%s'...", $var);

        if ( my $param = param($var) ) {

            if ( $$vars{$var}{vartype} == VARTYPE_INT ) {
                $$vars{$var}{value} = $param;
            }
            else {
                debugprint(DEBUG_ERROR, "Invalid VARTYPE: '%s'", $$vars{$var}{vartype});
                $returnval = E_INVALID_VARTYPE;
            }
        }
    }

    no CGI;

    debugprint(DEBUG_TRACE, "Returning '%s'", error_message($returnval));

    return $returnval;
}

#
# Module initilization...
#

register_debug_modes(\%DebugModes);
register_error_messages(\%ErrorMessages);
register_params(\%ParamDefs);

# Done!

return SUCCESS;

