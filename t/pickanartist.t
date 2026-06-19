use strict;
use warnings;
use Test::More;
use Test::MockModule;
use Capture::Tiny 'capture_stdout';

use FindBin '$RealBin';
use lib "$RealBin/../lib";

# Mock Net::LastFM->new before loading App::LastFM::PickAnArtist so that the
# field initialiser (which calls Net::LastFM->new) does not reject undef
# API credentials via Moose type constraints.
use Net::LastFM;
my $mock = Test::MockModule->new('Net::LastFM');
$mock->mock( 'new', sub { bless {}, 'Net::LastFM' } );

use_ok('App::LastFM::PickAnArtist');

# Test default constructor
new_ok('App::LastFM::PickAnArtist');

# Test constructor with custom params
{
    my $app = App::LastFM::PickAnArtist->new(
        username => 'testuser',
        min      => 100,
        max      => 500,
    );
    isa_ok($app, 'App::LastFM::PickAnArtist', 'construction with custom params');
}

# Test run with artists in range — output should be "Name (playcount)"
{
    $mock->mock(
        'request_signed',
        sub {
            return {
                topartists => {
                    artist => [
                        { name => 'Artist A', playcount => 700 },
                        { name => 'Artist B', playcount => 600 },
                        { name => 'Artist C', playcount => 200 },    # below min, stops pagination
                    ]
                }
            };
        }
    );

    my $app    = App::LastFM::PickAnArtist->new( min => 500, max => 1000 );
    my $output = capture_stdout { $app->run };
    like( $output, qr/^Artist [AB] \(\d+\)\n$/, 'run outputs artist name and playcount' );
}

# Test that only artists within [min, max] are selected
{
    $mock->mock(
        'request_signed',
        sub {
            return {
                topartists => {
                    artist => [
                        { name => 'Too Popular',  playcount => 1500 },    # above max
                        { name => 'Just Right',   playcount => 750 },
                        { name => 'Too Obscure',  playcount => 100 },     # below min, stops pagination
                    ]
                }
            };
        }
    );

    my $app    = App::LastFM::PickAnArtist->new( min => 500, max => 1000 );
    my $output = capture_stdout { $app->run };
    like( $output, qr/^Just Right \(750\)\n$/, 'only artists within range are picked' );
}

# Test that getartists dies when no artists fall within the range
{
    $mock->mock(
        'request_signed',
        sub {
            return {
                topartists => {
                    artist => [
                        { name => 'Artist X', playcount => 200 },    # below min, stops pagination
                    ]
                }
            };
        }
    );

    my $app = App::LastFM::PickAnArtist->new( min => 500, max => 1000 );
    eval { $app->getartists };
    like(
        $@,
        qr/No artists with between 500 and 1000 plays for davorg/,
        'getartists dies with correct message when no artists match'
    );
}

done_testing;
