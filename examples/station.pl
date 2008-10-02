#!/pro/bin/perl

use Tk;
use Tk::Clock;

my @bw = qw( Black White );

use Getopt::Long qw(:config bundling nopermute);
GetOptions (
    "r|rev|wb|white-on-black" => sub { @bw = reverse @bw },
    ) or die "usage: station.pl [--white-on-black]\n";

my $m = MainWindow->new;

$m->configure (
    -foreground	=> $bw[0],
    -background	=> $bw[1],
    );

my $c = $m->Clock (
    -background	=> $bw[1],
    -relief	=> "flat",
  )->pack (
    -expand	=> 1,
    -fill	=> "both",
    -padx	=> "10",
    -pady	=> "10",
    );
$c->config (
    useDigital	=> 0,
    useAnalog	=> 1,
    secsColor	=> "Red",
    handColor	=> $bw[0],
    tickColor	=> $bw[0],
    tickFreq	=> 1,
    tickDiff	=> 1,
    handCenter	=> 1,
    anaScale	=> 500,
    );
$c->config (anaScale => 0);

MainLoop;
