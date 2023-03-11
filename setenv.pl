use strict;
use warnings;

my $root;

BEGIN {
    use Cwd qw(abs_path);
    use File::Basename qw(dirname basename);
    $root = dirname(abs_path(__FILE__));
}

# Add the lib/perl5 in local so that we can load local::lib from there
use lib "$root/local/lib/perl5";
# Now add the local dir properly using local::lib
use local::lib "$root/local";

1;
