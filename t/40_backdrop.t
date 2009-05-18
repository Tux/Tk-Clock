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

    ok (my $m = MainWindow->new, "Main window");
    ok (my $c = $m->Clock (-relief	=> "flat"),	"base clock");
    ok (my $p = $m->Photo (-file => "t/eye.png"),	"Photo");
    ok ($c->config (
	backDrop	=> $p,
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

    $c->after (5000, sub { $_->destroy for $c, $m; exit; });

    MainLoop;
    }
