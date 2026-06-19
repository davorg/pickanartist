# Copilot Instructions for pickanartist

## Project Overview

`pickanartist` is a small Perl command-line tool that picks a random Last.FM artist
from a user's listening history whose play count falls within a configurable range.
The intent is to surface artists the user likes (listened to frequently) but doesn't
play constantly — helping diversify music choices.

See also: [blog post](https://dev.to/davorg/solving-simple-problems-4p2f)

## Repository Layout

```
bin/pickanartist               # CLI entry point (shebang: perl -CS)
lib/App/LastFM/PickAnArtist.pm # Core module
README.md
.gitignore                     # Ignores .vscode/
```

There is currently no test suite, no `cpanfile`, no `Makefile.PL`, and no CI
configuration.

## Language & Style

- **Language**: Perl 5, written with `use strict; use warnings;`
- **OOP**: Uses `Feature::Compat::Class` (modern Perl `class`/`field`/`method`
  syntax, backport of the `class` feature introduced in Perl 5.38).  Suppress the
  experimental warning with `no warnings 'experimental::class';`.
- **Output**: Uses `use feature 'say';` (not `print`).
- **Module namespace**: `App::LastFM::PickAnArtist`

## Key Dependencies

| Module                  | Purpose                                   |
|-------------------------|-------------------------------------------|
| `Feature::Compat::Class`| Modern Perl OOP (`class`/`field`/`method`)|
| `Net::LastFM`           | Last.FM API client                        |
| `Getopt::Long`          | CLI option parsing                        |

Install CPAN dependencies via `cpanm` (e.g. `cpanm Feature::Compat::Class Net::LastFM`).

## Environment Variables

The application requires two environment variables at runtime:

| Variable           | Purpose              |
|--------------------|----------------------|
| `LASTFM_API_KEY`   | Last.FM API key      |
| `LASTFM_API_SECRET`| Last.FM API secret   |

These are consumed directly in `PickAnArtist.pm` when constructing the
`Net::LastFM` object.  **Never hard-code these values.**

## CLI Interface

```
bin/pickanartist [OPTIONS]
bin/pickanartist <username>   # positional shorthand
```

Options (parsed with `Getopt::Long`):

| Option       | Default  | Description                              |
|--------------|----------|------------------------------------------|
| `--user`     | `davorg` | Last.FM username                         |
| `--min`      | `500`    | Minimum play count to include            |
| `--max`      | `1000`   | Maximum play count to include            |
| `--range`    | —        | Shorthand `MIN-MAX` (e.g. `--range 200-800`); sets both `--min` and `--max` |

The single positional argument form (`bin/pickanartist username`) takes priority
over options when `@ARGV` contains exactly one element.

## Core Logic (PickAnArtist.pm)

1. **`run`** — orchestrates the three steps below.
2. **`getartists`** — paginates through `user.getTopArtists` (Last.FM API), collecting
   artists whose `playcount` is within `[$min, $max]`.  Stops once the last artist on
   a page has fewer plays than `$min`.  Dies if no qualifying artists are found.
3. **`pickartist`** — selects one artist at random from `@artists` using `rand`.
4. **`render`** — prints `"$artist->{name} ($artist->{playcount})"` to stdout via `say`.

## Adding Features / Modifying the Module

- Add new fields with the `:param` attribute if they should be settable via
  the constructor; omit `:param` for internal state.
- Constructor arguments map directly to `field` names declared with `:param`.
- Propagate new constructor fields through `bin/pickanartist` (add a
  `GetOptions` key and pass it to `App::LastFM::PickAnArtist->new`).
- Keep all API interaction inside `PickAnArtist.pm`; keep `bin/pickanartist`
  limited to argument parsing and object construction.

## Testing

There is currently no test suite.  When adding tests:

- Use standard Perl testing tools: `Test::More`, `Test::Exception`, or `Test2::V0`.
- Place test files under `t/` (e.g. `t/pickanartist.t`).
- Run with `prove -l t/`.
- Mock `Net::LastFM` to avoid real API calls in unit tests (e.g. with `Test::MockObject` or `Test::MockModule`).

## Common Errors & Workarounds

- **"No artists with between N and M plays for <user>"** — the specified range
  contains no artists for that user.  Widen `--min`/`--max` or check the user's
  Last.FM library.
- **"Invalid range: ..."** — the `--range` argument must match `^\d+-\d+$` with
  min < max.
- **Missing API credentials** — `Net::LastFM->new` will be called with `undef`
  values if `LASTFM_API_KEY` / `LASTFM_API_SECRET` are not set; set them before
  running.
- **`Feature::Compat::Class` not installed** — install via
  `cpanm Feature::Compat::Class`; requires Perl 5.14+.
