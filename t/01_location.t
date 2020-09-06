use strictures 2;
use Test::More;
use Test::Fatal;
use Mojo::Base -async_await;
use Syntax::Keyword::Try;
use Fake::Location;

my $l = Fake::Location->new;
isa_ok $l, 'Fake::Location';
ok $l->start, "Start location service";

my ( $pos , $i );

for (1..5) { 
    try { 
        $pos = $l->location;
        isa_ok $pos,  'ARRAY', "[lon, lat] position";
    } catch ( $e ) {
        like $e, qr/can't provide location/i, "Failed with right error msg";
    }

    note explain $pos;
}

ok $l->stop, "Stop location service";
done_testing;
