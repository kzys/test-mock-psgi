package Test::Mock::PSGI;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_map unknown_requests));
use LWP::Protocol::PSGI;
use Plack::App::URLMapWithPort;
use Plack::App::Cascade;

sub new {
    my ($class, @rest) = @_;

    my $self = $class->SUPER::new(@rest);

    my $map = Plack::App::URLMapWithPort->new;
    $self->{_map} = $map;

    return $self;
}

sub map {
    shift->_map->map(@_);
}

sub maps {
    my ($self, %apps) = @_;

    for my $key (keys %apps) {
        $self->map($key => $apps{$key});
    }
}

sub register {
    my ($self) = @_;

    my @unknown_requests;
    $self->{unknown_requests} = \@unknown_requests;

    my $cascade = Plack::App::Cascade->new;
    $cascade->add($self->_map->to_app);
    $cascade->add(
        sub {
            my ($env) = @_;
            push @unknown_requests, $env;
            return [ 404, [], [ '' ] ];
        }
    );
    LWP::Protocol::PSGI->register($cascade->to_app);
}

1;
