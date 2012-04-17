#!/pro/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::NoWarnings;

BEGIN {
    use_ok ("Tk");
    use_ok ("Tk::PNG");
    use_ok ("Tk::Photo");
    use_ok ("Tk::Clock");
    }

SKIP: {
    $Tk::PNG::VERSION or skip "Cannot load Tk::PNG", 7;

    my $delay = $ENV{TK_TEST_LENGTH} || 5000;
    my $m = eval { MainWindow->new  (-title => "clock"); } or
	skip_all ("No valid Tk environment");

    ok (my $c  = $m->Clock (-relief => "flat"),		"base clock");
    ok (my $p1 = $m->Photo (-file   => "t/eye.png"),	"Photo 1");
    ok (my $p2 = $m->Photo (-file   => "t/eye2.png"),	"Photo 2");
    ok ($c->config (
	backDrop	=> $p1,
	timeFont	=> "{Liberation Mono} 11",
	dateFont	=> "{Liberation Mono} 11",
	timeFormat	=> " ",
	dateFormat	=> "ddd, dd mmm yyyy",
	dateColor	=> "Navy",
	handColor	=> "#ffe0e0",
	useSecHand	=> 0,
	tickColor	=> "Blue",
	tickDiff	=> 1,
	handCenter	=> 1,
	anaScale	=> 330,
	),						"config ()");
    ok ($c->pack,					"pack");

    $c->after (    $delay, sub { $c->config (backDrop => $p2) });

    $c->after (2 * $delay, sub { $_->destroy for $c, $m; exit; });

    MainLoop;
    }
