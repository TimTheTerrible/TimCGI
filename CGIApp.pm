#!/usr/bin/perl

use strict;

#
# CGIApp
#

package CGIApp;

use TimUtil;
use TimObj;
use TimApp;
use TimCGI;
use TimCGI::CGIWatchWindow;

our @ISA = qw(TimApp);

sub CGIApp::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = TimApp->new($record);

    if ( ref($self) ) {
        bless($self, $class);
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to create CGIApp!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, $class)?"SUCCESS":"FAILURE"));

    return $self;
}

sub CGIApp::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {

        # Set up internal state...
        $self->{protocol} = "http";
        $self->{host} = CGI::virtual_host();
        $self->{urlbase} = "";
        $self->{cgibase} = "cgi-bin";

        # Parse the HTTP vars...
        if ( ($returnval = $self->parse_vars($self->{vars})) == E_NO_ERROR ) {
            # ...
        }
        else {
            debugprint(DEBUG_ERROR, "Failed to parse vars!");
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIApp::run
{
    my $self = shift;
    my ($options) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");


    if ( ($returnval = $self->build_page($options)) == E_NO_ERROR ) {

        # TODO: need an if ( $self->{vars}{something like debug} ) here...
        # Add a watch window at the bottom of the page...
        #my $watchwindow = CGIWatchWindow->new();
        #$self->{page}->add_atom($watchwindow);

        $returnval = $self->draw_page($options);
    }
    else {
        debugprint(DEBUG_ERROR, "Failed to build page!");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

#
# This function must be overridden to create a useful app.
#
sub CGIApp::build_page
{
    my $self = shift;
    my ($options) = @_; 
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    $self->{page} = CGIPage->new();

    $self->{page}->add_atom(CGIAtom->new({text=>"Hello, World!"}));

    if ( ($returnval = $self->{page}->init($self)) == E_NO_ERROR ) {
        # TODO: Build a nice demo page...
    }
    else {
    }

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

#
# This function should be used as-is by most apps; override only if neccessary.
#
sub CGIApp::draw_page
{
    my $self = shift;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( UNIVERSAL::isa($self->{page}, "CGIPage") ) {
        printf("%s\n", join("\n", @{$self->{page}->render()}));
        #map(printf("%s\n", $_), @{$self->{page}->render()});
    }
    else {
        $returnval = E_INVALID_OBJECT;
        debugprint(DEBUG_ERROR, "How the fuck did I get this far with no fucking CGIPage object?!?");
    }

    debugprint(DEBUG_TRACE, "Returning %s (%d)", error_message($returnval), $returnval);

    return $returnval;
}

sub CGIApp::register_vars
{
    my $self = shift;
    my ($vars) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    foreach my $var ( keys(%{$vars}) ) {

        debugprint(DEBUG_TRACE, "Registering '%s'...", $var);

        unless ( exists($self->{vars}{$var}) ) {
            $self->{vars}{$var} = $$vars{$var};
        }
        else {
            $returnval = E_INVALID_ARGS;
        }
    }

    debugprint(DEBUG_TRACE, "Returning '%s'", error_message($returnval));

    return $returnval;
}

sub CGIApp::parse_vars
{
    my $self = shift;
    my ($vars) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    use CGI qw (:standard );

    debugdump(DEBUG_DUMP, "vars", $vars);

    foreach my $var ( keys(%{$vars}) ) {

        debugprint(DEBUG_TRACE, "Parsing '%s'...", $var);

        if ( my $param = param($var) ) {

            debugprint(DEBUG_TRACE, "Got '%s'", $param);

            if (
                ($$vars{$var}{type} == VARTYPE_INT) or
                ($$vars{$var}{type} == VARTYPE_STRING) or
                ($$vars{$var}{type} == VARTYPE_FLOAT)
               ) {
                debugprint(DEBUG_TRACE, "Setting '%s' to '%s'!", $$vars{$var}{name}, $param);
                $$vars{$var}{value} = $param;
            }
            elsif ( $$vars{$var}{type} == VARTYPE_ENUM ) {
                $$vars{$var}{value} = $$vars{$var}{selectors}{$param};
            }
            else {
                debugprint(DEBUG_ERROR, "Invalid VARTYPE: '%s'", $$vars{$var}{vartype});
                $returnval = E_INVALID_VARTYPE;
            }
        }
    }

    no CGI;

    debugdump(DEBUG_DUMP, "vars", $vars);

    debugprint(DEBUG_TRACE, "Returning '%s'", error_message($returnval));

    return $returnval;
}

sub CGIApp::get_var
{
    my $self = shift;
    my($varname) = @_;
    my $result;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( my $var = $self->{vars}{$varname} ) {
        debugdump(DEBUG_DUMP, "var", $var);

        # VARTYPE doesn't matter here, really, but trap invalid types anyway...
        if (
            ($$var{type} == VARTYPE_INT) or
            ($$var{type} == VARTYPE_STRING) or
            ($$var{type} == VARTYPE_ENUM) or
            ($$var{type} == VARTYPE_FLOAT)
           ) {
            $result = exists($$var{value}) ? $$var{value} : $$var{default};
        }
        else {
            debugprint(DEBUG_ERROR, "Invalid Vartype: '%s'", $$var{type});
            $result = undef;
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Invalid variable name: '%s'", $varname);
        $result = undef;
    }

    debugprint(DEBUG_TRACE, "Returning '%s' for '%s'", $result, $varname);

    return $result;
}

sub CGIApp::get_var_packed
{
    my $self = shift;
    my($varname) = @_;
    my $result;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( my $var = $self->{vars}{$varname} ) {
        debugdump(DEBUG_DUMP, "var", $var);

        my $value = exists($$var{value}) ? $$var{value} : $$var{default};

        # VARTYPE *does* matter here...
        if (
            ($$var{type} == VARTYPE_INT) or
            ($$var{type} == VARTYPE_FLOAT) or
            ($$var{type} == VARTYPE_STRING)
           ) {

            $result = $value;
        }
        elsif ( $$var{type} == VARTYPE_BOOL ) {
            $value ? $result = "TRUE" : $result = "FALSE";
        }
        elsif ( $$var{type} == VARTYPE_ENUM ) {

            foreach my $selector ( keys(%{$$var{selectors}}) ) {
                $result = $selector if $$var{selectors}{$selector} == $value;
            }
        }
        else {
            debugprint(DEBUG_ERROR, "Invalid Vartype: '%s'", $$var{type});
            $result = undef;
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Invalid variable name: '%s'", $$var{name});
        $result = undef;
    }

    debugprint(DEBUG_TRACE, "Returning '%s' for '%s'", $result, $varname);

    return $result;
}

sub CGIApp::import_vars
{
    my $self = shift;
    my ($vars) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    debugdump(DEBUG_DUMP, "vars", $vars);

    foreach my $var ( keys(%$vars) ) {

        debugprint(DEBUG_TRACE, "Checking '%s'...", $var);

        if ( exists($self->{vars}{$var}) ) {
            debugprint(DEBUG_TRACE, "'%s' matched '%s', saving...", $var, $self->{vars}{$var}{name});
            $self->{vars}{$var}{value} = $$vars{$var};
        }
    }

    debugprint(DEBUG_TRACE, "Returning '%s'", error_message($returnval));

    return $returnval;
}

sub CGIApp::build_url
{
    my $self = shift;
    my($options) = @_;
    my $args = "";

    debugprint(DEBUG_TRACE, "Entering...");

    # Build a list of vars from previous invocations...
    unless ( $$options{clear} ) {
        foreach my $var ( keys(%{$self->{vars}}) ) {
    
            if ( ( not exists($$options{$var}) ) and exists($self->{vars}{$var}{value}) ) {
    
                $$options{$var} = $self->get_var_packed($var);
            }
        }
    }

    # Put together the list of args...
    foreach my $key ( keys(%$options) ) {
        next if $key =~ /scriptname|clear/;

        $args .= "&" if $args ne "";
        $args .= sprintf("%s=%s", $key, $$options{$key});
    }

    # TODO: fix this so it can produce non-script URIs too...
    # Build the URL...
    my $result = sprintf("%s://%s/%s/%s?%s",
        $self->get_property($self->{class}, "protocol","http"),
        $self->get_property($self->{class}, "host","localhost"),
        $self->get_property($self->{class}, "cgibase",""),
        $$options{scriptname} ? $$options{scriptname} : $self->{scriptname},
        $args,
    );

    # Neatness counts...
    $result =~ s/\?$//g;

    debugprint(DEBUG_TRACE, "Returning '%s'", $result);

    return $result;
}

# Done!

return SUCCESS;

