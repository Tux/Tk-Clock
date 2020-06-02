use Test::PAUSE::Permissions;
 
BEGIN { $ENV{RELEASE_TESTING} = 1; }

my $usr = lc getpwuid ($<) || "joe";
plan skip_all => "You are not me" unless $usr =~ m/^(?:merijn|tux)$/;

all_permissions_ok ("HMBRAND");
