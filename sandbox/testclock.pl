#!/pro/bin/perl

use Tk;
use Tk::Clock;

my @bw = qw( White Black );

my $m = MainWindow->new;

$m->configure (
    -foreground	=> $bw[0],
    -background	=> $bw[1],
    );

my $c = $m->Clock (
    -background	=> $bw[1],
    -relief	=> "flat",
  )->pack (
    -anchor	=> "c",
    -expand	=> 1,
    -fill	=> "both",
    -padx	=> "10",
    -pady	=> "10",
    );
$c->config (
    useDigital	=> 1,
    useAnalog	=> 1,
    useSecHand  => 0,
    handColor	=> $bw[0],
    tickColor	=> $bw[0],
    tickFreq	=> 1,
    tickDiff	=> 1,
    handCenter	=> 1,
    anaScale	=> 500,
    autoScale	=> 1,
    useInfo	=> 1,
    infoColor	=> "Yellow",
    timeColor	=> "Yellow",
    dateColor	=> "Yellow",
    infoFormat  => "mmmm",
    handColor   => "Gray60",
    timeZone    => "Europe/Budapest",
    useLocale   => "hu_HU.utf8",
    timeFont    => "{DejaVu Sans Mono} 10",
    timeFormat  => "", #"Hungary/Budapest",
    localOffset => -2 * 86400,
    infoFont    => "{DejaVu Sans Mono} 18",
    dateFont    => "{DejaVu Sans Mono} 18",
    dateFormat  => "ddd dddd",
    );

MainLoop;
