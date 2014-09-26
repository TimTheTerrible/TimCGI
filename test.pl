#!/usr/bin/perl

use strict;

package TestApp;

use TimUtil;
use TimCGI;
use TimCGI::CGIForm;
use TimCGI::CGITable;
use TimCGI::CGIInput;
use TimCGI::CGISelect;

our @ISA = qw(CGIApp);

sub TestApp::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    if ( ($returnval = $self->SUPER::init($owner)) == E_NO_ERROR ) {
        # Do something...
    }
    else {
        debugprint(DEBUG_TRACE, "Call to SUPER::init() failed!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

sub TestApp::read_config
{
    my $self = shift;
    my ($options) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    $self->{config} = {
        title	=> "CGIApp TestApp",
    };

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

sub TestApp::build_page
{
    my $self = shift;
    my ($options) = @_;  
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    # Create a page...
    my $pagestyles = [
        {
            class		=> "mainpage",
            tag		=> "BODY",
            properties	=> [
                "background: #555555",
                "color: #FFFFFF",
                "font-family: Tahoma, Impact, Lucida, Verdana, Arial, Helvetica, sans-serif",
            ],  
        },
    ];
    $self->{page} = CGIPage->new({styles => $pagestyles});

    if ( ($returnval = $self->{page}->init($self)) == E_NO_ERROR ) {

        # Create a form to put in the page...
        my $formdata = {
            action	=> $self->build_url(),
            method	=> "GET",
        };
        my $form = CGIForm->new({ formdata => $formdata });

        # Add the form to the page...
        $self->{page}->add_atom($form);

        # Create some inputs to put into the table data...
        my $inputstyles = [
            {   
                class           => "test",
                tag             => "INPUT",
                properties      => [
                    "background: white",
                    "color: black",
                    "vertical-align: middle",
                    "text-align: center",
                    "margin: 1px",
                    "padding: 1px",
                ],  
            },
        ];
        my $input = CGIInput->new(
            {
                type	=> 'text',
                name	=> 'blarp',
                value	=> $self->{app}->get_var("blarp"),
                class	=> 'test',
                styles	=> $inputstyles
            }
        );
        my $submit = CGIInput->new(
            {
                type	=> 'submit',
                name	=> 'action',
                value	=> 'update',
                class	=> 'test',
                styles	=> $inputstyles
            }
        );
        my $selectdata = {
            name	=> 'cheese',
            class	=> 'test',
            options	=> [
                { name	=> 'Hvarti',	value	=> 1, },
                { name	=> 'Tilset',	value	=> 2, },
                { name	=> 'Jarlsburg',	value	=> 3, }
            ]
        };
        my $select = CGISelect->new($selectdata);

        my $urldata = {
            text => sprintf("<a href='%s'>Reset</a>", $self->build_url({clear => TRUE})),
        };
        my $url = CGIAtom->new($urldata);

        # Build the table data, inserting the inputs into it...
        my $tabledata = {
            class	=> "test",
            rows	=> [
                [
                    { class	=> "test", content	=> $input, colspan	=> 3, },
                ],
                [
                    { class	=> "test", content	=> "2:1", },
                    { class	=> "test", content	=> $select, colspan	=> 2, },
                ],
                [
                    { class	=> "test", content	=> "3:1", },
                    { class	=> "test", content	=> $submit, rowspan => 2, },
                    { class	=> "test", content	=> "3:3", },
                ],
                [
                    { class	=> "test", content	=> "4:1", },
                    { class	=> "test", content	=> $url, },
                ],
            ],
        };

        # Set up the style data for the table...
        my $tablestyles = [
            {   
                class           => "test",
                tag             => "TABLE",
                properties      => [
                    "border: dashed green 1px",
                    "background: gray",
                    "width: 100%",
                    "height: 100%",
                ],  
            },  
            {   
                class           => "test",
                tag             => "TD",
                properties      => [
                    "background: white",
                    "color: black",
                    "vertical-align: middle",
                    "text-align: center",
                    "margin: 1px",
                    "padding: 1px",
                ],  
            },  
        ];

        # Create the table...
        my $table = CGITable->new({ styles => $tablestyles, tabledata => $tabledata });

        # Add the table to the form...
        $form->add_atom($table);

    }    
    else {
        debugprint(DEBUG_ERROR, "Page failed to initialize!");
    }    

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

package main;

use TimUtil;
use TimObj;
use TimCGI;
use TimCGI::CGIApp;
use TimCGI::CGIPage;

use constant ACTION_NONE	=> 0;
use constant ACTION_BROWSE	=> 1;
use constant ACTION_VIEW	=> 2;
use constant ACTION_EDIT	=> 3;

my %VarDefs = (
    blarp	=> {
        name		=> "Blarp",
        type		=> VARTYPE_STRING,
        default		=> "snarf",
        value		=> "snarf",
    },
    foo		=> {
        name		=> "Foo",
        type		=> VARTYPE_STRING,
        default		=> "bar",
    },
    cheese		=> {
        name		=> "Foo",
        type		=> VARTYPE_INT,
        default		=> 3,
    },
    action	=> {
        name		=> "Action",
        type		=> VARTYPE_ENUM,
        default		=> "none",
        value		=> ACTION_VIEW,
        selectors	=> {
            none	=> ACTION_NONE,
            browse	=> ACTION_BROWSE,
            view	=> ACTION_VIEW,
            edit	=> ACTION_EDIT,
        },
    },
);

sub main::main
{
    my $returnval = E_NO_ERROR;

    my $app = TestApp->new({ scriptname => "test.pl", vars => \%VarDefs });

    if ( UNIVERSAL::isa($app, "TestApp") ) {

        if ( ($returnval = $app->init()) == E_NO_ERROR ) {

            if ( ($returnval = $app->run()) == E_NO_ERROR ) {
                # Success?
            }
            else {
                TimCGI::draw_error();
            }
        }
        else {
            debugprint(DEBUG_ERROR, "App failed to initialize!");
        }
    }
    else {
        $returnval = E_INVALID_OBJECT;
        debugprint(DEBUG_ERROR, "Failed to instantiate App object!");
        debugdump(DEBUG_DUMP, "App", $app);
        TimCGI::draw_error($returnval);
    }

    exit($returnval);
}

exit(main());

