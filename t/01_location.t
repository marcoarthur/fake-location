use strictures 2;
use Test::More;
use Test::Fatal;
use Mojo::Base -async_await;
use Syntax::Keyword::Try;
use Fake::Location;
use constant LOCATIONS => 5;

my @build_args =
  ( [ bad => { fail_rate => 'not number' } ], [ good => { fail_rate => 0.8 } ], [ good => {} ], );

my ( $l, $pos, $i, @hist );

subtest 'Initialize Fake::Location' => sub {

    my $test_attrs = sub {
        my ( $obj, $attr ) = @_;
        for my $name ( keys %$attr ) {
            ok $obj->$name == $attr->{$name}, "$name has right value";
        }
    };

    for my $args (@build_args) {
        if ( $args->[0] eq "good" ) {
            my $href = $args->[1];
            $l = Fake::Location->new($href);
            isa_ok $l, 'Fake::Location';
            $test_attrs->( $l, $href );    # test attributes
            ok $l->frequency == 1 / $l->sample_rate, "frequency is inverse sample rate";
        } else {
            like( exception { $l = Fake::Location->new($args) },
                qr/.*/, "invalid args throws error as expected" );
        }
    }
};

subtest 'Get locations' => sub {

    ok $l->start, "Start location service";
    my $inrange = sub {
        my ( $lon, $lat ) = @_;
        my $lon_range = $lon >= -90.0 && $lon <= 90.0;
        my $lat_range = $lat >= -90.0 && $lat <= 90.0;
        return $lon_range && $lat_range;
    };

    for ( 1 .. LOCATIONS ) {
        try {
            $pos = $l->location;
            isa_ok $pos, 'ARRAY', "[lon, lat] position";
            ok $inrange->(@$pos), "Right lon/lat range";
        } catch ($e) {
            like $e, qr/can't provide location/i, "Failed with right error msg";
            $pos = undef;
        }

        push @hist, $pos;
    }
};

ok $l->stop, "Stop location service";

TODO: {
    local $TODO = "redesign history";
    my @h = map { $_->[1] } $l->history->@*;
    is_deeply \@hist, \@h, "location history";
}

done_testing;
