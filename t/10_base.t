#!/pro/bin/perl

use strict;
use warnings;

use Test::More tests => 23;
use Test::NoWarnings;

BEGIN {
    use_ok ("Tk");
    use_ok ("Tk::Clock");
    }

my ($delay, $period, $m, $c) = (0, $ENV{TK_TEST_LENGTH} || 5000);
$m = eval { MainWindow->new  (-title => "clock"); } or
    skip_all ("No valid Tk environment");

ok ($c = $m->Clock (-background => "Black"),	"Clock Widget");
like ($c->config (
    tickColor => "Orange",
    handColor => "Red",
    secsColor => "Green",
    timeColor => "lightBlue",
    dateColor => "Gold",
    timeFont  => "Helvetica 6",
    dateFont  => "Helvetica 6",
    ), qr(^Tk::Clock=HASH), "config");
ok ($c->pack (-expand => 1, -fill => "both"), "pack");
# Three stupid tests to align the rest
is ($delay, 0, "Delay is 0");
like ($period, qr/^\d+$/, "Period is $period");

$delay += $period;
like ($delay, qr/^\d+$/, "First after $delay");

$c->after ($delay, sub {
    $c->configure (-background => "Blue4");
    ok ($c->config (
	tickColor  => "Yellow",
	useAnalog  => 1,
	useInfo    => 0,
	useDigital => 0,
	), "Blue4   Ad Yellow");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Tan4");
    ok ($c->config (
	useAnalog  => 0,
	useInfo    => 0,
	useDigital => 1,
	), "Tan4    aD");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Maroon4");
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 1,
	useDigital => 1,
	dateFormat => "m/d/y",
	timeFormat => "hh:MM A",
	), "Maroon4 AD m/d/y hh:MM A");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Red4");
    ok ($c->config (
	useAnalog  => 0,
	useInfo    => 0,
	useDigital => 1,
	dateFormat => "mmm yyy",
	timeFormat => "HH:MM:SS",
	), "Red4    aD mmm yyy HH:MM:SS");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Gray10");
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 1,
	useDigital => 1,
	digiAlign  => "right",
	), "Gray10  right digital");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Gray30");
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 0,
	useDigital => 1,
	digiAlign  => "left",
	), "Gray30  left digital");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Purple4");
    ok ($c->config (
	useAnalog  => 0,
	useInfo    => 0,
	useDigital => 1,
	dateFormat => "dddd\nd mmm yyy",
	timeFormat => "",
	), "Purple4 aD dddd\\nd mmm yyy ''");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Gray75");
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 1,
	useDigital => 0,
	anaScale   => 300,
	infoFormat => "Tk-Clock",
	), "Gray75  Ad scale 300");
    });

$delay += $period;
$c->after ($delay, sub {
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 0,
	useDigital => 0,
	anaScale   => 67,
	tickFreq   => 5,
	), "        Ad scale  67 tickFreq 5");
    });

$delay += $period;
$c->after ($delay, sub {
    ok ($c->config (
	useAnalog  => 1,
	useInfo    => 0,
	useDigital => 1,
	anaScale   => 100,
	tickFreq   => 5,
	dateFormat => "ww dd-mm",
	timeFormat => "dd HH:SS",
	), "        AD scale 100 tickFreq 5 ww dd-mm dd HH:SS");
    });

$delay += $period;
$c->after ($delay, sub {
    ok ($c->config ({
	anaScale   => 150,
	dateFont   => "Helvetica 9",
	}), "        Increase date font size");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->configure (-background => "Black");
    ok ($c->config ({
	useAnalog  => 1,
	useInfo    => 0,
	useDigital => 0,
	secsColor  => "Red",
	tickColor  => "White",
	handColor  => "White",
	handCenter => 1,
	tickFreq   => 1,
	tickDiff   => 1,
	anaScale   => 250,
	}), "        Station clock: hand centers and tick width");
    });

$delay += $period;
$c->after ($delay, sub {
    $c->destroy;
    ok (!Exists ($c), "Destroy Clock");
    $m->destroy;
    ok (!Exists ($m), "Destroy Main");
    exit;
    });

MainLoop;
