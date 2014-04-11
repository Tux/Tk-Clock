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
    timeFormat	=> "h:MM:SS A",
    dateColor	=> "lightBlue",
    dateFormat	=> "dd-mm-yyyy",
    dateFont	=> "fixed 18",
    timeFont	=> "fixed 24",
    localOffset => $ARGV[0]||0,
    );
$c->pack;

MainLoop;
