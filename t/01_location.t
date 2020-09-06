use strictures 2;
use Test::More;
use Test::Fatal;
use Mojo::Base -async_await;
use Syntax::Keyword::Try;
use Fake::Location;

my $l = Fake::Location->new;
isa_ok $l, 'Fake::Location';
ok $l->frequency == 1/$l->sample_rate, "frequency is inverse sample rate";
ok $l->fail_rate == 0.1, "fail rate is 10%";
ok $l->start, "Start location service";

my ( $pos , $i , @res);

for (1..5) { 
    try { 
        $pos = $l->location;
        isa_ok $pos,  'ARRAY', "[lon, lat] position";
    } catch ( $e ) {
        like $e, qr/can't provide location/i, "Failed with right error msg";
        $pos = undef;
    }

    note explain $pos;
    push @res, $pos;
}

ok $l->stop, "Stop location service";

my @h = map { $_->[1] } $l->history->@*;
is_deeply \@res, \@h, "location history";
done_testing;
