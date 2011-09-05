package Test::Mock::PSGI;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_ro_accessors(qw(_map unknown_requests));
use LWP::Protocol::PSGI;
use Plack::App::URLMapWithPort;
use Plack::App::Cascade;
use Test::Mock::PSGI::Session;

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

sub session {
    my ($self, $code_ref) = @_;

    my @unknown;

    my $cascade = Plack::App::Cascade->new;
    $cascade->add($self->_map->to_app);
    $cascade->add(
        sub {
            my ($env) = @_;
            push @unknown, $env;
            return [ 404, [], [ '' ] ];
        }
    );

    my $session = Test::Mock::PSGI::Session->new({
        protocol => LWP::Protocol::PSGI->register($cascade->to_app),
        unknown => \@unknown,
    });
    if ($code_ref) {
        $code_ref->();
        my $ok = $session->verify;
        undef $session;
        return $ok;
    } else {
        $session;
    }
}

1;
