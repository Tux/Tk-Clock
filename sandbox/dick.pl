#!/pro/bin/perl

use Tk;
use Tk::Clock;

my $m = MainWindow->new ();

#$m->overrideredirect (1);    #no xterm decorations
my $c = $m->Clock (-background => "Black");
$c->config (
    useAnalog	=> 0,
    useDigital	=> 1,
    digiAlign	=> "center",
    timeColor	=> "lightBlue",
    timeFormat	=> "hh:MM:SS A",
    dateColor	=> "lightBlue",
    dateFormat	=> "dd-mm-yyyy",
    dateFont	=> "fixed 24",
    timeFont	=> "fixed 18",
    );
$c->pack;

MainLoop;
