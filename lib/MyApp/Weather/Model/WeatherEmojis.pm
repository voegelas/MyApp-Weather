package MyApp::Weather::Model::WeatherEmojis;
use Mojo::Base -strict;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.002';

use Exporter qw(import);

our @EXPORT_OK = qw($EMOJIS);

our $EMOJIS = {
  clearsky                     => '☀️',
  fair                         => '🌤',
  partlycloudy                 => '⛅',
  cloudy                       => '☁',
  fog                          => '🌫',
  lightrainshowers             => '🌦',
  lightrain                    => '🌦',
  rainshowers                  => '💧',
  rain                         => '💧',
  heavyrainshowers             => '💧💧',
  heavyrain                    => '💧💧',
  lightrainshowersandthunder   => '🌦⚡',
  lightrainandthunder          => '🌦⚡',
  rainshowersandthunder        => '💧⚡',
  rainandthunder               => '💧⚡',
  heavyrainshowersandthunder   => '💧💧⚡',
  heavyrainandthunder          => '💧💧⚡',
  lightsleetshowers            => '🌨',
  lightsleet                   => '🌨',
  sleetshowers                 => '🌨',
  sleet                        => '🌨',
  heavysleetshowers            => '🌨🌨',
  heavysleet                   => '🌨🌨',
  lightsleetshowersandthunder  => '🌨⚡',
  lightsleetandthunder         => '🌨⚡',
  sleetshowersandthunder       => '🌨⚡',
  sleetandthunder              => '🌨⚡',
  heavysleetshowersandthunder  => '🌨🌨⚡',
  heavysleetandthunder         => '🌨🌨⚡',
  lightsnowshowers             => '❄',
  lightsnow                    => '❄',
  snowshowers                  => '❄',
  snow                         => '❄',
  heavysnowshowers             => '❄❄',
  heavysnow                    => '❄❄',
  lightsnowshowersandthunder   => '❄⚡',
  lightsnowandthunder          => '❄⚡',
  snowshowersandthunder        => '❄⚡',
  snowandthunder               => '❄⚡',
  heavysnowshowersandthunder   => '❄❄⚡',
  heavysnowandthunder          => '❄❄⚡',
};

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::WeatherEmojis - Weather emojis

=head1 VERSION

version 0.002

=head1 SYNOPSIS

  use MyApp::Weather::Model::WeatherEmojis qw($EMOJIS);
  say $EMOJIS->{clearsky};

=head1 DESCRIPTION

Maps the weather symbol codes used by MET Norway to emojis.

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
