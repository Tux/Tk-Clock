requires   "Carp";
requires   "Encode";
requires   "POSIX";
requires   "Tk"                       => "402.000";
requires   "Tk::Canvas";
requires   "Tk::Derived";
requires   "Tk::Widget";

recommends "Encode"                   => "3.01";
recommends "Tk"                       => "804.034";

on "configure" => sub {
    requires   "ExtUtils::MakeMaker";
    };

on "test" => sub {
    requires   "Test::More"               => "0.90";
    requires   "Test::NoWarnings";

    recommends "Test::More"               => "1.302166";
    };
