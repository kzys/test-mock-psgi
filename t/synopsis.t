use strict;
use warnings;
use Test::More tests => 1;

open(my $file, '<', 'lib/Test/Mock/PSGI.pm');
my $str = do {
    local $/;
    <$file>;
};
close($file);

if ($str =~ /^=head1\sSYNOPSIS$(.*?)^=/xms) {
    eval($1);
    is("$@", '');
}
