package Test::Mock::PSGI::Session;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(protocol unknown));

my $Test = Test::Builder->new;

sub _english_join {
    my $last;

    if (scalar @_ > 2) {
        $last = pop @_;
    }
    (join ', ', @_) . ($last ? " and $last" : '')
}

sub verify {
    my @requests = @{ shift->unknown };

    if (@requests) {
        $Test->diag(
            'This test accessed ' . _english_join(map {
                $_->{SERVER_NAME}
            } @requests) . '.'
        );
        0;
    } else {
        1;
    }
}

1;
