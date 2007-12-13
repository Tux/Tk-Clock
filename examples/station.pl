#!/pro/bin/perl

use Tk;
use Tk::Clock;

my $m = MainWindow->new;
my $c = $m->Clock (-background => "White")->pack (-expand => 1, -fill => "both");
$c->config (
    useDigital	=> 0,
    useAnalog	=> 1,
    secsColor	=> "Red",
    handColor	=> "Black",
    tickColor	=> "Black",
    tickFreq	=> 1,
    tickDiff	=> 1,
    handCenter	=> 1,
    anaScale	=> 500,
    );

MainLoop;
