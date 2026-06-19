# pickanartist

A command-line tool that picks a random [Last.FM](https://www.last.fm/) artist
from your listening history whose play count falls within a configurable range.

The goal is to surface artists you genuinely like — ones you've listened to
enough to have a meaningful play count — but that you don't reach for
automatically. It's a way to break out of listening habits and rediscover
artists already in your library.

For more background, see [this blog post](https://dev.to/davorg/solving-simple-problems-4p2f).

## Prerequisites

* Perl 5.14 or later
* [cpanm](https://metacpan.org/pod/App::cpanminus) (recommended for installing
  dependencies)
* A [Last.FM API account](https://www.last.fm/api/account/create) — you will
  need an API key and API secret

## Installation

Clone the repository and install the required CPAN modules:

```
git clone https://github.com/davorg/pickanartist.git
cd pickanartist
cpanm Feature::Compat::Class Net::LastFM
```

## Configuration

Export your Last.FM API credentials as environment variables before running
the tool:

```
export LASTFM_API_KEY=your_api_key_here
export LASTFM_API_SECRET=your_api_secret_here
```

## Usage

```
bin/pickanartist [OPTIONS]
bin/pickanartist <username>
```

Passing a single positional argument is a shorthand for `--user <username>`.

## Command-line options

| Option          | Default  | Description                                                    |
|-----------------|----------|----------------------------------------------------------------|
| `--user <name>` | `davorg` | Last.FM username to look up                                    |
| `--min <n>`     | `500`    | Minimum play count (inclusive) for an artist to be considered  |
| `--max <n>`     | `1000`   | Maximum play count (inclusive) for an artist to be considered  |
| `--range <m-n>` | —        | Shorthand for `--min` and `--max` combined, e.g. `200-800`     |

## Examples

Pick a random artist from the default user's history in the default range
(500–1000 plays):

```
bin/pickanartist
```

Pick a random artist for a different user:

```
bin/pickanartist someusername
```

Use a custom play-count range:

```
bin/pickanartist --user someusername --min 200 --max 800
```

Use the `--range` shorthand:

```
bin/pickanartist --user someusername --range 200-800
```

## Output

The tool prints one line to standard output in the format:

```
Artist Name (playcount)
```

For example:

```
Radiohead (742)
```

## License

This software is copyright (c) Dave Cross and is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.
