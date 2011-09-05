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
    my $session = $mock->session;

    is(get('http://www.google.com/'), 'gooogle');
    is(get('http://www.yahoo.com/'), 'yahoo!');

    ok($session->verify);
};

ok(
    $mock->session( sub { get('http://www.google.com/') }),
    'session + callback'
);
ok(
    ! $mock->session(sub { get('http://www.amazon.com/') }),
    'session + callback'
);

{
    my $session = $mock->session;

    is(get('http://www.google.com/'), 'gooogle');
    ok(! get('http://www.amazon.com/'));

    ok(! $session->verify);
    is($session->unknown->[0]->{SERVER_NAME}, 'www.amazon.com');
};

isnt(get('http://www.google.com/'), 'gooogle');
