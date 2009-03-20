#!/pro/bin/perl

use strict;
use warnings;

use Test::More tests => 9;
use Test::NoWarnings;

BEGIN {
    use_ok ("Tk");
    use_ok ("Tk::Clock");
    }

my ($delay, $m, $c) = (10000);
ok ($m = MainWindow->new (-title => "clock"),	"MainWindow");
ok ($c = $m->Clock (-background => "Black"),	"Clock Widget");
like ($c->config (
    tickColor => "Orange",
    handColor => "Red",
    secsColor => "Green",
    timeColor => "lightBlue",
    dateColor => "Gold",
    timeFont  => "-misc-fixed-medium-r-normal--13-*-75-75-c-*-iso8859-1",
    autoScale => 1,
    ), qr(^Tk::Clock=HASH), "config");
ok ($c->pack (-expand => 1, -fill => "both"), "pack");

print "# Feel free to resize the clock now with your mouse!\n";

$c->after ($delay, sub {
    $c->destroy;
    ok (!Exists ($c), "Destroy Clock");
    $m->destroy;
    ok (!Exists ($m), "Destroy Main");
    exit;
    });

MainLoop;
