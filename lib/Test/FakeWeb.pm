package Test::FakeWeb;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_protocol unknown_requests));
use LWP::Protocol::PSGI;
use Plack::App::URLMapWithPort;
use Plack::App::Cascade;

sub new {
    my ($class, %apps) = @_;

    my $self = $class->SUPER::new;

    my @unknown_requests;

    my $cascade = Plack::App::Cascade->new;
    my $map = Plack::App::URLMapWithPort->new;
    for my $key (keys %apps) {
        $map->map($key => $apps{$key});
    }
    $cascade->add($map->to_app);
    $cascade->add(
        sub {
            my ($env) = @_;
            push @unknown_requests, $env;
            return [ 404, [], [ '' ] ];
        }
    );
    $self->{_protocol} = LWP::Protocol::PSGI->register($cascade->to_app);
    $self->{unknown_requests} = \@unknown_requests;

    return $self;
}

1;
