#!/pro/bin/perl

use strict;
use warnings;

use Tk;
use Tk::Clock;

my @bw = reverse qw( Black White );

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
    -padx	=> "30",
    -pady	=> "30",
    -side	=> "left",
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
    anaScale	=> 800,
    );
$c->config (anaScale => 0);

my $f = $m->Frame (
    -background	=> "Black",
   )->pack (
    -expand	=> 1,
    -fill	=> "both",
    -side	=> "left",
    );

my ($rest, $end, $secs, $left) = ("");

my $l = $f->Label (
    -textvariable	=> \$rest,
    -font		=> "{Helvetica} 240 bold",
    -background		=> "Black",
   )->pack (
    -expand	=> 1,
    -padx	=> 30,
    -pady	=> 30,
    -fill	=> "both",
    -side	=> "top",
    );
my $r = $f->Frame (
    -background	=> "Black",
   )->pack (
    -expand	=> 1,
    -fill	=> "both",
    -side	=> "top",
    );
$r->Label (
    -textvariable	=> \$secs,
    -width		=> 30,
    -background		=> "Black",
    -foreground		=> "Yellow",
   )->pack (
    -fill	=> "both",
    -side	=> "left",
    );
$r->Label (
    -textvariable	=> \$left,
    -width		=> 30,
    -background		=> "Black",
    -foreground		=> "Yellow",
   )->pack (
    -fill	=> "both",
    -side	=> "left",
    );

sub rest
{
    use integer;
    my $now = time;

    $now > $end and return;

    $secs = $end - $now;
    $rest = int (($secs + 10) / 60);

    $l->configure (
	-background	=> "Black",
	-foreground	=>
	    $rest >  5 ? "Green4" :
	    $rest >  3 ? "Yellow" :
	    $secs > 60 ? "Orange" : "Red");

    $left = sprintf "%02d:%02d", $secs / 60, $secs % 60;
    $secs == 60 and $l->bell for 1..2;
    $secs  < 60 and $rest = $secs;

    if ($rest) {
	$l->after (100, \&rest);
	return;
	}

    $l->bell for 1..10;
    $l->configure (-background	=> "Red");
    $l->after (30000, sub { $l->configure (-background => "Black") });
    $rest = "";
    } # rest

sub start
{
    my ($val, $x, $prev, $idx, $act) = @_;
    $val eq $prev and return;
    $val or return;
    #print STDERR "New val: (@_)\n";
    unless ($val =~ m/^[0-9]+$/ && $val > 0 && $val <= 60) {
	$rest = "";
	$end  = 999999999;
	return $val;
	}
    $end = time + (60 * $val);
    rest ();
    return $val;
    } # start

my $p = $f->Frame (
    -background	=> "Black",
   )->pack (
    -expand	=> 1,
    -fill	=> "both",
    -side	=> "top",
    );
foreach my $d (5, 10, 15, 20, 25, 30) {
    $p->Button (
	-text			=> $d,
	-relief			=> "flat",
	-borderwidth		=> 1,
	-activebackground	=> "Gray10",
	-activeforeground	=> "Red2",
	-highlightthickness	=> 1,
	-highlightcolor		=> "Red2",
	-background		=> "Black",
	-foreground		=> "Red2",
	-command		=> sub { start ($d, 0, "", 0, 0) },
       )->pack (
	-expand	=> 1,
	-fill	=> "both",
	-side	=> "left",
	);
    }

$f->Entry (
    -validate	=> "all",
    -vcmd	=> \&start,
   )->pack (
    -fill	=> "both",
    -side	=> "top",
   )->bind (
    Enter	=> \&start,
    );

MainLoop;
