#!/usr/bin/perl

# Copyright PROCURA B.V. (c) 1999-2008 H.Merijn Brand

require 5.006;

use ExtUtils::MakeMaker;

my %wm = (
    NAME	  =>   "Tk::Clock",
    DISTNAME	  =>   "Tk-Clock",
    AUTHOR        =>   "H.Merijn Brand <h.m.brand\@xs4all.nl>",
    VERSION_FROM  =>   "Clock.pm",
    ABSTRACT_FROM =>   "Clock.pm",

    PREREQ_PM	  => { "Tk"		=> "402.000",
		       "Tk::Canvas"	=> 0,
		       "Tk::Derived"	=> 0,
		       "Tk::Widget"	=> 0,
		       "Carp"		=> 0,
		       "Test::More"	=> 0,
		       },

    dist	  => { COMPRESS	=> "gzip -9f",
		       SUFFIX	=> ".gz",
		       }
    );
$ExtUtils::MakeMaker::VERSION > 6.30 and $wm{LICENSE} = "perl";

my $rv = WriteMakefile (%wm);

1;

package MY;

sub postamble
{
    join "\n" =>
	'cover test_cover:',
	'	cover -delete',
	'	HARNESS_PERL_SWITCHES=-MDevel::Cover $(MAKE) test',
	'	cover',
	'';
    } # postamble
