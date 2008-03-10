#!/pro/bin/perl

package Tk::Clock;

use strict;
use warnings;

our $VERSION = "0.23";

use Carp;

use Tk::Widget;
use Tk::Derived;
use Tk::Canvas;

use vars qw( @ISA );
@ISA = qw/Tk::Derived Tk::Canvas/;

Construct Tk::Widget "Clock";

my $ana_base = 73;	# Size base for 100%

my %def_config = (
    handColor	=> "Green4",
    secsColor	=> "Green2",
    tickColor	=> "Yellow4",
    tickDiff	=> 0,
    handCenter	=> 0,

    timeZone	=> "",

    timeFont	=> "fixed",
    timeColor	=> "Red4",
    timeFormat	=> "HH:MM:SS",

    dateFont	=> "fixed",
    dateColor	=> "Blue4",
    dateFormat	=> "dd-mm-yy",

    useDigital	=> 1,
    useAnalog	=> 1,
    anaScale	=> 100,
    tickFreq	=> 1,
    ana24hour	=> 0,
    countDown	=> 0,

    digiAlign	=> "center",

    fmtd	=> sub {
	my ($d, $m, $y, $w) = @_;
	sprintf "%02d-%02d-%02d", $d, $m + 1, $y % 100;
	},
    fmtt	=> sub {
	my ($h, $m, $s) = @_;
	sprintf "%02d:%02d:%02d", $h, $m, $s;
	},

    _anaSize	=> $ana_base,	# Default size (height & width)
    _digSize	=> 26,		# Height
    );

sub _month ($$)
{
    [[  "1", "01", "Jan", "January"	],
     [  "2", "02", "Feb", "February"	],
     [  "3", "03", "Mar", "March"	],
     [  "4", "04", "Apr", "April"	],
     [  "5", "05", "May", "May"		],
     [  "6", "06", "Jun", "June"	],
     [  "7", "07", "Jul", "July"	],
     [  "8", "08", "Aug", "August"	],
     [  "9", "09", "Sep", "September"	],
     [ "10", "10", "Oct", "October"	],
     [ "11", "11", "Nov", "November"	],
     [ "12", "12", "Dec", "December"	]]->[$_[0]][$_[1]];
    } # _month

sub _wday ($$)
{
    [[ "Sun", "Sunday"		],
     [ "Mon", "Monday"		],
     [ "Tue", "Tuesday"		],
     [ "Wed", "Wednesday"	],
     [ "Thu", "Thursday"	],
     [ "Fri", "Friday"		],
     [ "Sat", "Saturday"	]]->[$_[0]][$_[1]];
    } # _wday

sub _min ($$)
{
    $_[0] <= $_[1] ? $_[0] : $_[1];
    } # _min

sub _max ($$)
{
    $_[0] >= $_[1] ? $_[0] : $_[1];
    } # _max

sub _resize ($)
{
    my $clock = shift;

    use integer;
    my $data = $clock->privateData;
    my $hght = $data->{useAnalog}  * $data->{_anaSize} +
	       $data->{useDigital} * $data->{_digSize} + 1;
    my $wdth = _max ($data->{useAnalog}  * $data->{_anaSize},
		     $data->{useDigital} * 72);
    my $dim  = "${wdth}x${hght}";
    $clock->cget (-height) == $hght &&
     $clock->cget (-width) == $wdth and return $dim;
    if ($clock->parent->isa ("MainWindow")) {
	my $geo = $clock->parent->geometry;
	my @geo = split m/\D/ => $geo;
	if ($geo[0] > 5 && $geo[1] > 5) {
	    $geo =~ s/^\d+x\d+//;
	    $clock->parent->geometry ("$dim$geo");
	    }
	}
    $clock->configure (
	-height => $hght,
	-width  => $wdth);
    $dim;
    } # _resize

# Callback when auto-resize is called
sub _resize_auto ($)
{
    my $clock = shift;
    my $data  = $clock->privateData;

    $data->{useAnalog} && $data->{anaScale} == 0 or return;

    my $geo   = $clock->geometry;
    my $owdth = $data->{useAnalog} * $data->{_anaSize};
    my ($gw, $gh) = split m/\D/, $geo;
    $data->{useDigital}   and $gh -= $data->{_digSize};
    my $nwdth = _min ($gw, $gh - 1);
    abs ($nwdth - $owdth) > 5 && $nwdth >= 10 or return;

    $data->{_anaSize} = $nwdth - 2;
    $clock->_destroyAnalog;
    $clock->_createAnalog;
    if ($data->{useDigital}) {
	# Otherwise the digital either overlaps the analog
	# or there is a gap
	$clock->_destroyDigital;
	$clock->_createDigital;
	}
    $clock->_resize;
    } # _resize_auto

sub _createDigital ($)
{
    my $clock = shift;

    my $data = $clock->privateData;
    my $wdth = _max ($data->{useAnalog}  * $data->{_anaSize},
		     $data->{useDigital} * 72);
    my ($pad, $anchor) = (5, "s");
    my ($x, $y) = ($wdth / 2, $data->{useAnalog} * $data->{_anaSize});
    if    ($data->{digiAlign} eq "left") {
	($anchor, $x) = ("sw", $pad);
	}
    elsif ($data->{digiAlign} eq "right") {
	($anchor, $x) = ("se", $wdth - $pad);
	}
    $clock->createText ($x, $y + $data->{_digSize},
	-anchor	=> $anchor,
	-width  => ($wdth - 2 * $pad),
	-font   => $data->{dateFont},
	-fill   => $data->{dateColor},
	-text   => $data->{dateFormat},
	-tags   => "date");
    $clock->createText ($x, $y + 13,
	-anchor	=> $anchor,
	-width  => ($wdth - 2 * $pad),
	-font   => $data->{timeFont},
	-fill   => $data->{timeColor},
	-text   => $data->{timeFormat},
	-tags   => "time");
#   $data->{Clock_h} = -1;
#   $data->{Clock_m} = -1;
#   $data->{Clock_s} = -1;
    $clock->_resize;
    } # _createDigital

sub _destroyDigital ($)
{
    my $clock = shift;

    $clock->delete ("date");
    $clock->delete ("time");
    } # _destroyDigital

sub _where ($$$$)
{
    my ($clock, $tick, $len, $anaSize) = @_;      # ticks 0 .. 59
    my ($x, $y, $angle);

    $clock->privateData->{countDown} and $tick = (60 - $tick) % 60;
    my $h = ($anaSize + 1) / 2;
    $angle = $tick * .104720;
    $x = $len  * sin ($angle) * $anaSize / 73;
    $y = $len  * cos ($angle) * $anaSize / 73;
    ($h - $x / 4, $h + $y / 4, $h + $x, $h - $y);
    } # _where

sub _createAnalog ($)
{
    my $clock = shift;

    my $data = $clock->privateData;

    my $h = ($data->{_anaSize} + 1) / 2 - 1;
    my $f = $data->{tickFreq} * 2;
    foreach my $dtick (0 .. 119) {
	$dtick % $f and next;
	my $l = $dtick % 30 == 0 ? $h / 5 :
		$dtick % 10 == 0 ? $h / 8 :
				   $h / 16;
	my $angle = ($dtick / 2) * .104720;
	my $x = sin $angle;
	my $y = cos $angle;
	$clock->createLine (
	    ($h - $l) * $x + $h + 1, ($h - $l) * $y + $h + 1,
	     $h       * $x + $h + 1,  $h       * $y + $h + 1,
	    -tags  => "tick",
	    -arrow => "none",
	    -fill  => $data->{tickColor},
	    -width => $data->{tickDiff} && $dtick % 10 == 0 ? 4.0 : 1.0,
	    );
	}
    $data->{Clock_h} = -1;
    $data->{Clock_m} = -1;
    $data->{Clock_s} = -1;

    $clock->createLine (
	$clock->_where (0, 22, $data->{_anaSize}),
	    -tags  => "hour",
	    -arrow => "none",
	    -fill  => $data->{handColor},
	    -width => $data->{_anaSize} / ($data->{handCenter} ? 35 : 26),
	    );
    if ($data->{handCenter}) {
	my $cntr = $data->{_anaSize} /  2;
	my $diam = $data->{_anaSize} / 30;
	$clock->createOval (($cntr - $diam) x 2, ($cntr + $diam) x 2,
	    -tags  => "hour",
	    -fill  => $data->{handColor},
	    -width => 0.
	    );
	}
    $clock->createLine (
	$clock->_where (0, 30, $data->{_anaSize}),
	    -tags  => "min",
	    -arrow => "none",
	    -fill  => $data->{handColor},
	    -width => $data->{_anaSize} / ($data->{handCenter} ? 60 : 30),
	    );
    $clock->createLine (
	$clock->_where (0, 34, $data->{_anaSize}),
	    -tags  => "sec",
	    -arrow => "none",
	    -fill  => $data->{secsColor},
	    -width => 0.8);
    if ($data->{handCenter}) {
	my $cntr = $data->{_anaSize} /  2;
	my $diam = $data->{_anaSize} / 35;
	$clock->createOval (($cntr - $diam) x 2, ($cntr + $diam) x 2,
	    -tags  => "sec",
	    -fill  => $data->{secsColor},
	    -width => 0.
	    );
	}

    $clock->_resize;
    } # _createAnalog

sub _destroyAnalog ($)
{
    my $clock = shift;

    $clock->delete ("tick");
    $clock->delete ("hour");
    $clock->delete ("min");
    $clock->delete ("sec");
    } # _destroyAnalog

sub Populate
{
    my ($clock, $args) = @_;

    my $data = $clock->privateData;
    %$data = %def_config;
    $data->{Clock_h} = -1;
    $data->{Clock_m} = -1;
    $data->{Clock_s} = -1;
    $data->{_time_}  = -1;

    if (ref $args eq "HASH") {
	my %args = %$args;
	foreach my $arg (keys %args) {
	    (my $attr = $arg) =~ s/^-//;
	    exists $data->{$attr} and $data->{$attr} = delete $args{$arg};
	    }
	$args = { %args };
	}

    $clock->SUPER::Populate ($args);

    $clock->ConfigSpecs (
        -width              => [ qw(SELF width              Width              72    ) ],
        -height             => [ qw(SELF height             Height             100   ) ],
        -relief             => [ qw(SELF relief             Relief             raised) ],
        -borderwidth        => [ qw(SELF borderWidth        BorderWidth        1     ) ],
        -highlightthickness => [ qw(SELF highlightThickness HighlightThickness 0     ) ],
        -takefocus          => [ qw(SELF takefocus          Takefocus          0     ) ],
        );

    $data->{useAnalog}  and $clock->_createAnalog;
    $data->{useDigital} and $clock->_createDigital;
    $clock->_resize;

    $clock->repeat (995, ["_run" => $clock]);
    } # Populate

sub config ($@)
{
    my $clock = shift;

    ref $clock or croak "Bad method call";
    @_ or return;

    my $conf;
    if (ref $_[0] eq "HASH") {
	$conf = shift;
	}
    elsif (scalar @_ % 2 == 0) {
	my %conf = @_;
	$conf = \%conf;
	}
    else {
	croak "Bad hash";
	}

    my $data = $clock->privateData;
    foreach my $conf_spec (keys %$conf) {
	(my $attr = $conf_spec) =~ s/^-//;
	defined $def_config{$attr} && defined $data->{$attr} or next;
	my $old = $data->{$attr};
	$data->{$attr} = $conf->{$conf_spec};
	if    ($attr eq "tickColor") {
	    $clock->itemconfigure ("tick", -fill => $data->{tickColor});
	    }
	elsif ($attr eq "handColor") {
	    $clock->itemconfigure ("hour", -fill => $data->{handColor});
	    $clock->itemconfigure ("min",  -fill => $data->{handColor});
	    }
	elsif ($attr eq "secsColor") {
	    $clock->itemconfigure ("sec",  -fill => $data->{secsColor});
	    }
	elsif ($attr eq "dateColor") {
	    $clock->itemconfigure ("date", -fill => $data->{dateColor});
	    }
	elsif ($attr eq "dateFont") {
	    $clock->itemconfigure ("date", -font => $data->{dateFont});
	    }
	elsif ($attr eq "timeColor") {
	    $clock->itemconfigure ("time", -fill => $data->{timeColor});
	    }
	elsif ($attr eq "timeFont") {
	    $clock->itemconfigure ("time", -font => $data->{timeFont});
	    }
	elsif ($attr eq "dateFormat") {
	    my %fmt = (
		"d"	=> '%d',	# 6
		"dd"	=> '%02d',	# 06
		"ddd"	=> '%3s',	# Mon
		"dddd"	=> '%s',	# Monday
		"m"	=> '%d',	# 7
		"mm"	=> '%02d',	# 07
		"mmm"	=> '%3s',	# Jul
		"mmmm"	=> '%s',	# July
		"y"	=> '%d',	# 98
		"yy"	=> '%02d',	# 98
		"yyy"	=> '%04d',	# 1998
		"yyyy"	=> '%04d',	# 1998
		"w"	=> '%d',	# 28 (week)
		"ww"	=> '%02d',	# 28
		);
	    my $fmt = $data->{dateFormat};
	    $fmt =~ m{[\%\@\$]} and croak "%, \@ and \$ not allowed in dateFormat";
	    my $xfmt = join "|", reverse sort keys %fmt;
	    my @fmt = split m/\b($xfmt)\b/, $fmt;
	    my $args = "";
	    $fmt = "";
	    foreach my $f (@fmt) {
		if (defined $fmt{$f}) {
		    $fmt .= $fmt{$f};
		    if ($f =~ m/^m+$/) {
			my $l = length ($f) - 1;
			$args .= ", Tk::Clock::_month (\$m, $l)";
			}
		    elsif ($f =~ m/^ddd+$/) {
			my $l = length ($f) - 3;
			$args .= ", Tk::Clock::_wday (\$wd, $l)";
			}
		    else {
			$args .= ', $' . substr ($f, 0, 1);
			$f =~ m/^y+$/ and
			    $args .= length ($f) < 3 ? " % 100" : " + 1900";
			}
		    }
		else {
		    $fmt .= $f;
		    }
		}
	    $data->{Clock_h} = -1;	# force update;
	    $data->{fmtd} = eval "
		sub
		{
		    my (\$d, \$m, \$y, \$wd, \$w) = \@_;
		    \$w = \$w / 7 + 1;
		    sprintf qq!$fmt!$args;
		    }";
	    }
	elsif ($attr eq "timeFormat") {
	    my %fmt = (
		"H"	=> '%d',	# 6
		"HH"	=> '%02d',	# 06
		"h"	=> '%d',	# 6	AM/PM
		"hh"	=> '%02d',	# 06	AM/PM
		"M"	=> '%d',	# 7
		"MM"	=> '%02d',	# 07
		"S"	=> '%d',	# 45
		"SS"	=> '%02d',	# 45
		"A"	=> '%s',	# PM
		"dd"	=> '%.2s',	# Mo
		"ddd"	=> '%.3s',	# Mon
		"dddd"	=> '%s',	# Monday
		);
	    my $fmt = $data->{timeFormat};
	    $fmt =~ m/[\%\@\$]/ and croak "%, \@ and \$ not allowed in timeFormat";
	    my $xfmt = join "|", reverse sort keys %fmt;
	    my @fmt = split m/\b($xfmt)\b/, $fmt;
	    my $arg = "";
	    $fmt = "";
	    foreach my $f (@fmt) {
		if ($f =~ m/^dd{1,3}$/) {
		    $fmt .= $fmt{$f};
		    $arg .= ", Tk::Clock::_wday (\$d, 1)";
		    }
		elsif (defined $fmt{$f}) {
		    $fmt .= $fmt{$f};
		    $arg .= ', $' . substr ($f, 0, 1);
		    }
		else {
		    $fmt .= $f;
		    }
		}
	    $data->{fmtt} = eval "
		sub
		{
		    my (\$H, \$M, \$S, \$d) = \@_;
		    my \$h = \$H % 12;
		    my \$A = \$H > 11 ? 'PM' : 'AM';
		    sprintf qq!$fmt!$arg;
		    }";
	    }
	elsif ($attr eq "tickFreq") {
#	    $data->{tickFreq} < 1 ||
#	    $data->{tickFreq} != int $data->{tickFreq} and
#		$data->{tickFreq} = $old;
	    unless ($data->{tickFreq} == $old) {
		$clock->_destroyAnalog;
		$clock->_createAnalog;
		}
	    }
	elsif ($attr eq "anaScale") {
	    $data->{anaScale} eq "auto" and $data->{anaScale} = 0;
	    if ($data->{anaScale} == 0) {	# 0 will be auto some time
		$clock->Tk::bind         ("Tk::Clock","<<ResizeRequest>>", \&_resize_auto);
		$clock->parent->Tk::bind ("<<ResizeRequest>>", \&_resize_auto);
		$clock->_resize_auto;
		}
	    else {
		my $new_size = int ($ana_base * $data->{anaScale} / 100.);
		unless ($new_size == $data->{_anaSize}) {
		    $data->{_anaSize} = $new_size;
		    $clock->_destroyAnalog;
		    $clock->_createAnalog;
		    if (exists $conf->{anaScale} && $data->{useDigital}) {
			# Otherwise the digital either overlaps the analog
			# or there is a gap
			$clock->_destroyDigital;
			$clock->_createDigital;
			}
		    $clock->after (5, ["_run" => $clock]);
		    }
		}
	    }
	elsif ($attr eq "useAnalog") {
	    if    ($old == 1 && $data->{useAnalog} == 0) {
		$clock->_destroyAnalog;
		$clock->_destroyDigital;
		$data->{useDigital} and $clock->_createDigital;
		}
	    elsif ($old == 0 && $data->{useAnalog} == 1) {
		$clock->_destroyDigital;
		$clock->_createAnalog;
		$data->{useDigital} and $clock->_createDigital;
		}
	    $clock->after (5, ["_run" => $clock]);
	    }
	elsif ($attr eq "useDigital") {
	    if    ($old == 1 && $data->{useDigital} == 0) {
		$clock->_destroyDigital;
		}
	    elsif ($old == 0 && $data->{useDigital} == 1) {
		$clock->_createDigital;
		}
	    $clock->after (5, ["_run" => $clock]);
	    }
	elsif ($attr eq "digiAlign") {
	    if ($data->{useDigital} && $old ne $data->{digiAlign}) {
		$clock->_destroyDigital;
		$clock->_createDigital;
		$clock->after (5, ["_run" => $clock]);
		}
	    }
	}
    $clock->_resize;
    $clock;
    } # config

sub _run ($)
{
    my $clock = shift;

    my $data = $clock->privateData;

    $data->{timeZone} and local $ENV{TZ} = $data->{timeZone};
    my $t = time;
    $t == $data->{_time_} and return;	# Same time, no update
    $data->{_time_} = $t;
    my @t = localtime $t;

    unless ($t[2] == $data->{Clock_h}) {
	$data->{Clock_h} = $t[2];
	$data->{useDigital} and
	    $clock->itemconfigure ("date",
		-text => &{$data->{fmtd}} (@t[3,4,5,6,7]));
	}

    unless ($t[1] == $data->{Clock_m}) {
        $data->{Clock_m} = $t[1];
	if ($data->{useAnalog}) {
	    my ($h24, $m24) = $data->{ana24hour} ? (24, 2.5)  : (12, 5);
	    $clock->coords ("hour",
		$clock->_where (($data->{Clock_h} % $h24) * $m24 + $t[1] / $h24, 22, $data->{_anaSize}));

	    $clock->coords ("min",
		$clock->_where ($data->{Clock_m}, 30, $data->{_anaSize}));
	    }
	}

    $data->{Clock_s} = $t[0];
    if ($data->{useAnalog}) {
	$clock->coords ("sec",
	    $clock->_where ($data->{Clock_s}, 34, $data->{_anaSize}));
	}
    $data->{useDigital} and
	$clock->itemconfigure ("time",
	    -text => &{$data->{fmtt}} (@t[2,1,0,6]));

    $data->{anaScale} == 0 and $clock->_resize_auto;
    } # _run

1;

__END__

=head1 NAME

Tk::Clock - Clock widget with analog and digital display

=head1 SYNOPSIS

use Tk
use Tk::Clock;

$clock = $parent->Clock (?-option => <value> ...?);

$clock->config (	# These reflect the defaults
    useDigital	=> 1,
    useAnalog	=> 1,
    anaScale	=> 100,
    ana24hour	=> 0,
    handColor	=> "Green4",
    secsColor	=> "Green2",
    handCenter	=> 0,
    tickColor	=> "Yellow4",
    tickFreq	=> 1,
    tickDiff    => 0,
    timeZone	=> "",
    timeFont	=> "fixed",
    timeColor	=> "Red4",
    timeFormat	=> "HH:MM:SS",
    dateFont	=> "fixed",
    dateColor	=> "Blue4",
    dateFormat	=> "dd-mm-yy",
    digiAlign   => "center",
    );

=head1 DESCRIPTION

Create a clock canvas with both an analog- and a digital display. Either
can be disabled by setting useAnalog or useDigital to 0 resp.

Legal dateFormat characters are d and dd for date, ddd and dddd for weekday,
m, mm, mmm and mmmm for month, y and yy for year, w and ww for weeknumber and
any separators :, -, / or space.

Legal timeFormat characters are H and HH for hour, h and hh for AM/PM hour,
M and MM for minutes, S and SS for seconds, A for AM/PM indicator, d and dd
for day-of-the week in two or three characters resp. and any separators :,
-, . or space.

Meaningful values for tickFreq are 1, 5 and 15 showing all ticks, tick
every 5 minutes or the four main ticks only, though any positive integer
will do (put a tick on any tickFreq minute). When setting tickDiff to a
true value, the major ticks will use a thicker line than the minor ticks.

The analog clock can be enlaged or reduced using anaScale for which the
default of 100% is about 72x72 pixels. Setting anaScale to 0, will try to
resize the widget to it's container automatically.

For digiAlign, "left", "center", and "right" are the only supported values.
Any other value will be interpreted as the default "center".

When using C<pack> for your geometry management, be sure to pass
C<-expand =&gt; 1, -fill =&gt; "both"> if you plan to resize with
C<anaScale> or enable/disable either analog or digital after the
clock was displayed.

=head1 BUGS

If the system load's too high, the clock might skip some seconds.

Due to the fact that the year is expressed in 2 digit's, this
widget is not Y2K compliant in the default configuration.

There's no check if either format will fit in the given space.

=head1 TODO

* Using POSIX' strftime () for dateFormat. Current implementation
  would probably make this very slow.
* Full support for multi-line date- and time-formats with auto-resize.
* Countdown clock API, incl action when done.
* Better docs for the attributes

=head1 AUTHOR

H.Merijn Brand <h.m.brand@xs4all.nl>

Thanks to Larry Wall for inventing perl.
Thanks to Nick Ing-Simmons for providing perlTk.
Thanks to Achim Bohnet for introducing me to OO (and converting
    the basics of my clock.pl to Tk::Clock.pm).
Thanks to Sriram Srinivasan for understanding OO though his Panther book.
Thanks to all CPAN providers for support of different modules to learn from.
Thanks to all who have given me feedback.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1999-2008 H.Merijn Brand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
