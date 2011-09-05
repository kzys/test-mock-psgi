package Test::Mock::PSGI::Session;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(protocol unknown));

sub verify {
    scalar @{ shift->unknown } == 0;
}

1;

