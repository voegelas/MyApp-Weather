package MyApp::Weather::Model::WeatherBadness;
use Mojo::Base -strict;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.002';

use Exporter qw(import);

our @EXPORT_OK = qw($BADNESS $WETNESS);

our $BADNESS = {
  clearsky                     => 1,
  fair                         => 2,
  partlycloudy                 => 3,
  cloudy                       => 4,
  fog                          => 5,
  lightrainshowers             => 6,
  lightrain                    => 7,
  rainshowers                  => 8,
  rain                         => 9,
  heavyrainshowers             => 10,
  heavyrain                    => 11,
  lightrainshowersandthunder   => 12,
  lightrainandthunder          => 13,
  rainshowersandthunder        => 14,
  rainandthunder               => 15,
  heavyrainshowersandthunder   => 16,
  heavyrainandthunder          => 17,
  lightsleetshowers            => 18,
  lightsleet                   => 19,
  sleetshowers                 => 20,
  sleet                        => 21,
  heavysleetshowers            => 22,
  heavysleet                   => 23,
  lightsleetshowersandthunder  => 24,
  lightsleetandthunder         => 25,
  sleetshowersandthunder       => 26,
  sleetandthunder              => 27,
  heavysleetshowersandthunder  => 28,
  heavysleetandthunder         => 29,
  lightsnowshowers             => 30,
  lightsnow                    => 31,
  snowshowers                  => 32,
  snow                         => 33,
  heavysnowshowers             => 34,
  heavysnow                    => 35,
  lightsnowshowersandthunder   => 36,
  lightsnowandthunder          => 37,
  snowshowersandthunder        => 38,
  snowandthunder               => 39,
  heavysnowshowersandthunder   => 40,
  heavysnowandthunder          => 41,
};

our $WETNESS = {
  clearsky                     => 1,
  fair                         => 1,
  partlycloudy                 => 1,
  cloudy                       => 1,
  fog                          => 1,
  lightrainshowers             => 2,
  lightrain                    => 2,
  rainshowers                  => 2,
  rain                         => 2,
  heavyrainshowers             => 2,
  heavyrain                    => 2,
  lightrainshowersandthunder   => 2,
  lightrainandthunder          => 2,
  rainshowersandthunder        => 2,
  rainandthunder               => 2,
  heavyrainshowersandthunder   => 2,
  heavyrainandthunder          => 2,
  lightsleetshowers            => 3,
  lightsleet                   => 3,
  sleetshowers                 => 3,
  sleet                        => 3,
  heavysleetshowers            => 3,
  heavysleet                   => 3,
  lightsleetshowersandthunder  => 3,
  lightsleetandthunder         => 3,
  sleetshowersandthunder       => 3,
  sleetandthunder              => 3,
  heavysleetshowersandthunder  => 3,
  heavysleetandthunder         => 3,
  lightsnowshowers             => 4,
  lightsnow                    => 4,
  snowshowers                  => 4,
  snow                         => 4,
  heavysnowshowers             => 4,
  heavysnow                    => 4,
  lightsnowshowersandthunder   => 4,
  lightsnowandthunder          => 4,
  snowshowersandthunder        => 4,
  snowandthunder               => 4,
  heavysnowshowersandthunder   => 4,
  heavysnowandthunder          => 4,
};

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::WeatherBadness - Weather badness and wetness

=head1 VERSION

version 0.002

=head1 SYNOPSIS

  use MyApp::Weather::Model::WeatherBadness qw($BADNESS $WETNESS);
  say $BADNESS->{clearsky};
  say $WETNESS->{snow};

=head1 DESCRIPTION

Assigns weights to the weather symbol codes used by MET Norway.  Bad weather
gets a higher weight then good weather.

=head1 SUBROUTINES/METHODS

None.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires Exporter and Mojolicious.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

None known.

=head1 LICENSE AND COPYRIGHT

Copyright 2021 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
