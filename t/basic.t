use strict;
use warnings;
use Test::More qw(no_plan);
use LWP::Simple;

use_ok 'Test::FakeWeb';

{
    my $web = Test::FakeWeb->new(
        'http://www.google.com/' => sub {
            return [ 200, [], [ 'gooogle' ] ]
        },
        'http://www.yahoo.com/' => sub {
            return [ 200, [], [ 'yahoo!' ] ]
        },
    );

    is(get('http://www.google.com/'), 'gooogle');
    is(get('http://www.yahoo.com/'), 'yahoo!');
    ok(! get('http://www.amazon.com/'));

    is($web->unknown_requests->[0]->{SERVER_NAME}, 'www.amazon.com');
};
