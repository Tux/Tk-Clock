#!/pro/bin/perl

use strict;
use warnings;

use Test::More tests => 21;
use Test::NoWarnings;

BEGIN {
    use_ok ("Tk");
    use_ok ("Tk::Clock");
    }

my ($delay, $period, $m, $c) = (0, 5000);
ok ($m = MainWindow->new (-title => "clock", -background => "Black"),	"MainWindow");

my %defconfig = (
    useDigital	=> 1,
    autoScale	=> 1,
    useAnalog	=> 1,
    useInfo	=> 1,
    anaScale	=> 200,
    ana24hour	=> 0,
    secsColor	=> "Green",
    tickColor	=> "Blue",
    tickFreq	=> 1,
    timeFont	=> "-misc-fixed-medium-r-normal--15-*-75-75-c-*-iso8859-1",
    timeColor	=> "lightBlue",
    timeFormat	=> "HH:MM:SS",
    dateFont	=> "-misc-fixed-medium-r-normal--15-*-75-75-c-*-iso8859-1",
    dateColor	=> "#cfb53b",
    infoFont	=> "{DejaVu Sans} 12",
    );

ok (my $c1 = $m->Clock (-background => "Black"),	"Clock Local TimeZone");
like ($c1->config ((
    %defconfig,
    infoFormat => "Omega",
    handColor  => "Red",
    timeZone   => $ENV{TZ} || undef,
    dateFormat => "Local",
    )), qr(^Tk::Clock=HASH), "config");
ok ($c1->grid (-column => 0, -row => 0, -sticky => "news"), "grid");

ok (my $c2 = $m->Clock (-background => "Black"),	"Clock GMT");
like ($c2->config (
    %defconfig,
    infoFormat => "Hc:Mc:Sc",
    infoFont   => "{DejaVu Sans} 10",
    timerValue => 12345,	# 04:25:45
    handColor  => "Orange",
    timeZone   => "GMT",
    dateFormat => "London (GMT)",
    ), qr(^Tk::Clock=HASH), "config");
ok ($c2->grid (-column => 0, -row => 1, -sticky => "news", -padx => 20), "grid");

ok (my $c3 = $m->Clock (-background => "Black"),	"Clock MET-1METDST");
like ($c3->config (
    %defconfig,
    infoFormat => "HH:MM:SS",
    handColor  => "Yellow",
    timeZone   => "MET-1METDST",
    dateFormat => "Amsterdam (MET)",
    ), qr(^Tk::Clock=HASH), "config");
ok ($c3->grid (-column => 1, -row => 0, -sticky => "news", -pady => 20), "grid");

ok (my $c4 = $m->Clock (-background => "Black"),	"Clock Tokyo");
like ($c4->config (
    %defconfig,
    infoFormat => "Tissot",
    handColor  => "Yellow",
    timeZone   => "Asia/Tokyo",
    dateFormat => "Asia/Tokyo",
    ), qr(^Tk::Clock=HASH), "config");
ok ($c4->grid (-column => 1, -row => 1, -sticky => "news", -padx => 20, -pady => 20), "grid");

for (0..1) {
    $m->gridColumnconfigure ($_, -weight => 1);
    $m->gridRowconfigure    ($_, -weight => 1);
    }

$delay += 5 * $period;
$c3->after ($delay, sub {
    $_->destroy for $c1, $c2, $c3, $c4;
    ok (!Exists ($_), "Destroy Clock") for $c1, $c2, $c3, $c4;
    $m->destroy;
    ok (!Exists ($m), "Destroy Main");
    exit;
    });

MainLoop;
