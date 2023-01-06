#!/pro/bin/perl

use 5.018003;
use warnings;

use Tk;
use Tk::Clock;

my $fg0 = "Black";

my $mw = MainWindow->new;
my $clock = $mw->Clock (-borderwidth => 1)->pack;
$clock->config (
    useDigital  => 1,
    useAnalog   => 0,
    useSecHand  => 0,
    digiAlign   => "right",
    dateColor   => $fg0,
    timeColor   => $fg0,
    dateFont    => "{DejaVu Sans Mono} 15",
    timeFont    => "{DejaVu Sans Mono} 8",
    dateFormat  => "d.m.yyyy",
    autoScale   => 1,
    );

use Data::Peek;
$mw->after ( 5, sub { $clock->itemconfigure ("date", -fill => "Red") });

MainLoop;
