use Feature::Compat::Class;

class App::LastFM::PickAnArtist {

  use strict;
  use warnings;
  no warnings 'experimental::class';
  use feature 'say';

  use Net::LastFM;
  use Getopt::Long;

  field $username :param = 'davorg';
  field $min      :param = 500;
  field $max      :param = 1000;
  field $lastfm   = Net::LastFM->new(
    api_key    => $ENV{LASTFM_API_KEY},
    api_secret => $ENV{LASTFM_SECRET},
  );
  field $method   = 'user.getTopArtists';
  field @artists;
  field $artist;

  method run {
    $self->getartists;
    $self->pickartist;
    $self->render;
  }

  method getartists {

    my ($data);
    my $page = 1;

    do {
      $data = $lastfm->request_signed(
        method => $method,
        user   => $username,
        page   => $page,
      );

      for (@{$data->{topartists}{artist}}) {

        next if $_->{playcount} > $max;
        next if $_->{playcount} < $min;

        push @artists, $_;
      }

      ++$page;
    } until $data->{topartists}{artist}[-1]{playcount} < $min;

    die "No artists with between $min and $max plays for $username\n"
      unless @artists;
  }

  method pickartist {
    $artist = $artists[ rand @artists ];
  }

  method render {
    say "$artist->{name} ($artist->{playcount})";
  }

}

1;
