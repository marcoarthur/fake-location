package Fake::Location;
use 5.028;
use Moo;
use Mojo::Base -signatures, -async_await;
use Math::Random::Secure qw(rand irand);
use Types::Standard qw(Num HashRef Object Bool ArrayRef Tuple Maybe Str);
use constant LONG      => 89;
use constant LAT       => 89;
use constant FAIL_PROB => 0.1;
use namespace::autoclean;

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
    default  => sub { 2 },
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

sub start ($self) {

    Mojo::IOLoop->recurring(
        1 / $self->sample_rate => sub {
            my $p    = Mojo::Promise->new;
            my $fail = rand() < FAIL_PROB ? 1 : 0;

            if ($fail) {
                $self->_save(undef);
                $p->reject("Can't provide location");
            } else {
                my $loc = [ irand(LONG) + rand(), irand(LAT) + rand() ];
                $self->_save($loc);
                $p->resolve($loc);
            }

            $self->location_p($p);
        }
    ) unless $self->is_running;

    $self->is_running(1);
}

sub _save ( $self, $val ) {
    push $self->history->@*, [ time() => $val ];
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

