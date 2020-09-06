package Fake::Location;
use 5.028;
use Moo;
use Mojo::Base -signatures, -async_await;
use Math::Random::Secure qw(rand irand);
use Types::Standard qw(Num HashRef Object Bool ArrayRef Tuple Maybe Str);
use Type::Params qw(compile);
use Carp;
use constant LONG        => 89;
use constant LAT         => 89;
use constant FAIL_PROB   => 0.1;
use constant SAMPLE_RATE => 2;
use namespace::autoclean;

with 'Throwable';

our $VERSION = "0.01";

has history => (
    is       => 'ro',
    isa      => ArrayRef [ Tuple [ Str, Maybe [ArrayRef] ] ],
    required => 1,
    default  => sub { [] },
);

has sample_rate => (
    is       => 'ro',
    isa      => Num,
    required => 1,
    default  => sub { SAMPLE_RATE },
);

has fail_rate => (
    is       => 'ro',
    isa      => Num,
    required => 1,
    default  => sub { FAIL_PROB },
);

has is_running => (
    is       => 'rw',
    isa      => Bool,
    required => 1,
    default  => sub { 0 },
);

has location_p => (
    is  => 'rw',
    isa => sub { $_[0]->isa('Mojo::Promise') },
);

has _loop => ( is => 'rw', );

sub frequency ($self ) {
    return 1/$self->sample_rate;
}

sub start ($self) {

    # save the sampler loop
    $self->_loop(
        Mojo::IOLoop->recurring(
            1 / $self->sample_rate => sub {
                $self->location_p( $self->_next_location_p );
            }
        )
    ) unless $self->is_running;

    # first location is always resolvable
    $self->location_p(
        Mojo::Promise->new(
            sub ( $resolve, $reject ) {
                Mojo::IOLoop->timer(
                    1 / $self->sample_rate => sub {
                        my $loc = $self->_rand_location;
                        $resolve->( $loc );
                    }
                );
            }
        )
    );
    $self->is_running(1);
}

sub location ( $self ) {
    my $loc;
    my $err_msg;

    croak "Not running yet" unless $self->is_running;

    # get current promise location
    $self->location_p->then( sub { $loc = shift } )->catch(
        sub ($err) {
            $err_msg = "Error getting location: $err";
            warn $err_msg;
        }
    )->wait;

    # set next promise location
    $self->location_p( $self->_next_location_p );

    # current location unavailable: throw error
    $self->throw( err => $err_msg ) if $err_msg;

    return $loc;
}

sub stop ($self) {
    croak "I'm not running yet" unless $self->is_running;
    Mojo::IOLoop->remove( $self->_loop );
    $self->is_running(0);
    return 1;
}

sub _save ( $self, $val ) {
    push $self->history->@*, [ time() => $val ];
}

# rand location around (lat, long) or a total random location.
sub _rand_location {
    state $check = compile( Object, Num, { optional => 1 }, Num, { optional => 1 } );

    my $signal = sub { rand() > 0.5 ? 1 : -1 };
    my ( $self, $lon, $lat ) = $check->(@_);

    $lon = $lon ? $lon : irand(LONG) * $signal->();
    $lat = $lat ? $lat : irand(LAT) * $signal->();

    return [ $lon + rand(), $lat + rand() ];
}

# next location
sub _next_location_p( $self ) {
    my $p    = Mojo::Promise->new;
    my $fail = rand() < $self->fail_rate ? 1 : 0;

    if ($fail) {
        $self->_save(undef);
        $p->reject("Can't provide location");
    } else {
        my $loc = $self->_rand_location;
        $self->_save($loc);
        $p->resolve($loc);
    }

    return $p;
}

1;

__END__

=encoding utf-8

=head1 NAME

Fake::Location - Can give location at some sampling rate. Will simulate a
random walk.

=head1 SYNOPSIS

    use Fake::Location;

=head1 DESCRIPTION

Fake::Location is ...

=head1 LICENSE

Copyright (C) Marco Arthur.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Marco Arthur E<lt>arthurpbs@gmail.comE<gt>

=cut

