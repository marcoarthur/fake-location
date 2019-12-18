package Fake::Location;
use 5.028;
use strict;
use warnings;
use Moo;
use Types::Standard qw(Number HashRef Object);

our $VERSION = "0.01";


has [ to, from ] => (
    is => 'ro',
    isa => 'Object',
);

has history => (
    is => 'ro',
    isa => 'HashRef',
);

has sample_rate => (
    is => 'ro',
    isa => Number
);


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

