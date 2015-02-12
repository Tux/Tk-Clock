#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
my $check = 0;
my $opt_v = 0;
GetOptions (
    "c|check"		=> \$check,
    "v|verbose:1"	=> \$opt_v,
    ) or die "usage: $0 [--check]\n";

use lib "sandbox";
use genMETA;
my $meta = genMETA->new (
    from    => "Clock.pm",
    verbose => $opt_v,
    );

$meta->from_data (<DATA>);

if ($check) {
    $meta->check_encoding ();
    $meta->check_required ();
    $meta->check_minimum ([ "examples" ]);
    $meta->done_testing ();
    }
elsif ($opt_v) {
    $meta->print_yaml ();
    }
else {
    $meta->fix_meta ();
    }

__END__
--- #YAML:1.0
name:                    Tk-Clock
version:                 VERSION
abstract:                Clock widget with analog and digital display
license:                 perl
author:              
    - H.Merijn Brand <h.m.brand@xs4all.nl>
generated_by:            Author
distribution_type:       module
provides:
    Tk::Clock:
        file:            Clock.pm
        version:         VERSION
requires:     
    perl:                5.006
    Carp:                0
    Tk:                  402.000
    Tk::Widget:          0
    Tk::Derived:         0
    Tk::Canvas:          0
    Encode:              0
    POSIX:               0
recommends:     
    Tk:                  804.032
    Encode:              2.70
configure_requires:
    ExtUtils::MakeMaker: 0
test_requires:
    Test::More:          0.88
    Test::NoWarnings:    0
test_recommends:
    Test::More:          1.001014
resources:
    license:             http://dev.perl.org/licenses/
    repository:          https://github.com/Tux/Tk-Clock
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
