package Plack::App::URLMapWithPort;
use strict;
use warnings;
use parent qw(Plack::App::URLMap);

my $NOT_FOUND = [ 404, [ 'Content-Type' => 'text/plain' ], [ 'Not Found' ] ];

sub map {
    my ($self, $path, $app) = @_;

    my $without_port = URI->new($path);
    my $port = $without_port->port;
    $without_port->port(undef);

    $self->SUPER::map(
        $without_port => sub {
            my ($env) = @_;
            if ($env->{SERVER_PORT} == $port) {
                $app->($env);
            } else {
                $NOT_FOUND;
            }
        }
    );
}

1;
