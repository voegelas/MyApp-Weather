package MyApp::Weather::View::Messages;
use Mojo::Base -strict, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use Exporter qw(import);

our @EXPORT_OK = qw(gettext);

our $TRANSLATIONS = {
  symbols => {
    clearsky => {
      de => 'Sonnig/Klar',
      en => 'Clear sky',
      nb => 'Sol/klarvær',
    },
    fair => {
      de => 'Leicht bewölkt',
      en => 'Fair',
      nb => 'Lettskyet',
    },
    partlycloudy => {
      de => 'Teilweise bewölkt',
      en => 'Partly cloudy',
      nb => 'Delvis skyet',
    },
    cloudy => {
      de => 'Bedeckt',
      en => 'Cloudy',
      nb => 'Skyet',
    },
    fog => {
      de => 'Nebel',
      en => 'Fog',
      nb => 'Tåke',
    },
    rainshowers => {
      de => 'Regenschauer',
      en => 'Rain showers',
      nb => 'Lette regnbyger',
    },
    rainshowersandthunder => {
      de => 'Regenschauer und Gewitter',
      en => 'Rain showers and thunder',
      nb => 'Lette regnbyger og torden',
    },
    sleetshowers => {
      de => 'Schneeregenschauer',
      en => 'Sleet showers',
      nb => 'Sluddbyger',
    },
    snowshowers => {
      de => 'Schneeschauer',
      en => 'Snow showers',
      nb => 'Snøbyger',
    },
    rain => {
      de => 'Regen',
      en => 'Rain',
      nb => 'Regn',
    },
    heavyrain => {
      de => 'Starker Regen',
      en => 'Heavy rain',
      nb => 'Kraftig regn',
    },
    heavyrainandthunder => {
      de => 'Starker Regen und Gewitter',
      en => 'Heavy rain and thunder',
      nb => 'Regn og torden',
    },
    sleet => {
      de => 'Schneeregen',
      en => 'Sleet',
      nb => 'Sludd',
    },
    snow => {
      de => 'Schnee',
      en => 'Snow',
      nb => 'Snø',
    },
    snowandthunder => {
      de => 'Schneegewitter',
      en => 'Snow and thunder',
      nb => 'Snø og torden',
    },
    sleetshowersandthunder => {
      de => 'Schneeregenschauer und Gewitter',
      en => 'Sleet showers and thunder',
      nb => 'Sluddbyger og torden',
    },
    snowshowersandthunder => {
      de => 'Schneeschauer und Gewitter',
      en => 'Snow showers and thunder',
      nb => 'Snøbyger og torden',
    },
    rainandthunder => {
      de => 'Regen und Gewitter',
      en => 'Rain and thunder',
      nb => 'Regnbyger og torden',
    },
    sleetandthunder => {
      de => 'Schneeregen und Gewitter',
      en => 'Sleet and thunder',
      nb => 'Sludd og torden',
    },
    lightrainshowersandthunder => {
      de => 'Leichte Regenschauer und Gewitter',
      en => 'Light rain showers and thunder',
      nb => 'Yrbyger og torden',
    },
    heavyrainshowersandthunder => {
      de => 'Starke Regenschauer und Gewitter',
      en => 'Heavy rain showers and thunder',
      nb => 'Tordenbyger',
    },
    lightsleetshowersandthunder => {
      de => 'Leichte Schneeregenschauer und Gewitter',
      en => 'Light sleet showers and thunder',
      nb => 'Regnbyger og torden',
    },
    heavysleetshowersandthunder => {
      de => 'Starke Schneeregenschauer und Gewitter',
      en => 'Heavy sleet showers and thunder',
      nb => 'Kraftige sluddbyger og torden',
    },
    lightsnowshowersandthunder => {
      de => 'Leichte Schneeschauer und Gewitter',
      en => 'Light snow showers and thunder',
      nb => 'Lette snøbyger og torden',
    },
    heavysnowshowersandthunder => {
      de => 'Starke Schneeschauer und Gewitter',
      en => 'Heavy snow showers and thunder',
      nb => 'Kraftige snøbyger og torden',
    },
    lightrainandthunder => {
      de => 'Leichter Regen und Gewitter',
      en => 'Light rain and thunder',
      nb => 'Yr og torden',
    },
    lightsleetandthunder => {
      de => 'Leichter Schneeregen und Gewitter',
      en => 'Light sleet and thunder',
      nb => 'Lette sluddbyger og torden',
    },
    heavysleetandthunder => {
      de => 'Starker Schneeregen und Gewitter',
      en => 'Heavy sleet and thunder',
      nb => 'Kraftig sludd og torden',
    },
    lightsnowandthunder => {
      de => 'Leichter Schneefall und Gewitter',
      en => 'Light snow and thunder',
      nb => 'Lett snøfall og torden',
    },
    heavysnowandthunder => {
      de => 'Starker Schneefall und Gewitter',
      en => 'Heavy snow and thunder',
      nb => 'Kraftig snøfall og torden',
    },
    lightrainshowers => {
      de => 'Leichte Regenschauer',
      en => 'Light rain showers',
      nb => 'Yrbyger',
    },
    heavyrainshowers => {
      de => 'Starke Regenschauer',
      en => 'Heavy rain showers',
      nb => 'Regnbyger',
    },
    lightsleetshowers => {
      de => 'Leichte Schneeregenschauer',
      en => 'Light sleet showers',
      nb => 'Lette sluddbyger',
    },
    heavysleetshowers => {
      de => 'Starke Schneeregenschauer',
      en => 'Heavy sleet showers',
      nb => 'Kraftige sluddbyger',
    },
    lightsnowshowers => {
      de => 'Leichte Schneeschauer',
      en => 'Light snow showers',
      nb => 'Lette snøbyger',
    },
    heavysnowshowers => {
      de => 'Starke Schneeschauer',
      en => 'Heavy snow showers',
      nb => 'Kraftige snøbyger',
    },
    lightrain => {
      de => 'Leichter Regen',
      en => 'Light rain',
      nb => 'Yr',
    },
    lightsleet => {
      de => 'Leichter Schneeregen',
      en => 'Light sleet',
      nb => 'Lett sludd',
    },
    heavysleet => {
      de => 'Starker Schneeregen',
      en => 'Heavy sleet',
      nb => 'Kraftig sludd',
    },
    lightsnow => {
      de => 'Leichter Schneefall',
      en => 'Light snow',
      nb => 'Lett snø',
    },
    heavysnow => {
      de => 'Starker Schneefall',
      en => 'Heavy snow',
      nb => 'Kraftig snøfall',
    },
  },
  title => {
    de => 'Wetter in %s',
    en => 'Weather in %s',
    nb => 'Værvarsel for %s',
  },
};

sub gettext ($lang, @what) {
  my $translations = $TRANSLATIONS;
  for (@what) {
    if (exists $translations->{$_}) {
      $translations = $translations->{$_};
    }
    else {
      return q{};
    }
  }

  for ($lang, 'en') {
    if (exists $translations->{$_}) {
      return $translations->{$_};
    }
  }

  return q{};
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::View::Messages - MyApp::Weather translations

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  use MyApp::Weather::View::Messages qw(gettext);
  say gettext(de => 'symbols', 'clearsky');

=head1 DESCRIPTION

Maps weather symbol codes used by MET Norway to text translations.

The following languages are supported:

=over

=item * de

=item * en

=item * nb

=back

=head1 SUBROUTINES/METHODS

=head2 gettext

  my $text = gettext($lang => @what);

Returns a translation.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<Exporter> and L<Mojolicious>.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

None known.

=head1 LICENSE AND COPYRIGHT

Copyright 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
