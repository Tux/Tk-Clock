#!/usr/bin/perl

# Copyright PROCURA B.V. (c) 1999-2007 H.Merijn Brand

require 5.006;

use ExtUtils::MakeMaker;

my %wm = (
    NAME	  =>   "Tk::Clock",
    DISTNAME	  =>   "Tk-Clock",
    AUTHOR        =>   "H.Merijn Brand <h.m.brand\@xs4all.nl>",
    VERSION_FROM  =>   "Clock.pm",
    ABSTRACT_FROM =>   "Clock.pm",

    PREREQ_PM	  => { "Tk"	=> "402.000",
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
