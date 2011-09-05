use strict;
use warnings;
use Test::More qw(no_plan);
use LWP::Simple;

use_ok 'Test::Mock::PSGI';

my $mock = Test::Mock::PSGI->new;
$mock->maps(
    'http://www.google.com/' => sub {
        return [ 200, [], [ 'gooogle' ] ]
    },
    'http://www.yahoo.com/' => sub {
        return [ 200, [], [ 'yahoo!' ] ]
    },
);

{
    my $guard = $mock->register;

    is(get('http://www.google.com/'), 'gooogle');
    is(get('http://www.yahoo.com/'), 'yahoo!');
    ok(! get('http://www.amazon.com/'));

    is($mock->unknown_requests->[0]->{SERVER_NAME}, 'www.amazon.com');
};

isnt(get('http://www.google.com/'), 'gooogle');
