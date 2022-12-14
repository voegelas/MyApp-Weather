package MyApp::Weather::Model::WeatherEmojis;
use Mojo::Base -strict;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use Exporter qw(import);

our @EXPORT_OK = qw($EMOJIS);

our $EMOJIS = {
  clearsky                     => 'โ๏ธ',
  fair                         => '๐ค',
  partlycloudy                 => 'โ',
  cloudy                       => 'โ',
  fog                          => '๐ซ',
  lightrainshowers             => '๐ฆ',
  lightrain                    => '๐ฆ',
  rainshowers                  => '๐ง',
  rain                         => '๐ง',
  heavyrainshowers             => '๐ง๐ง',
  heavyrain                    => '๐ง๐ง',
  lightrainshowersandthunder   => '๐ฆโก',
  lightrainandthunder          => '๐ฆโก',
  rainshowersandthunder        => '๐งโก',
  rainandthunder               => '๐งโก',
  heavyrainshowersandthunder   => '๐ง๐งโก',
  heavyrainandthunder          => '๐ง๐งโก',
  lightsleetshowers            => '๐จ',
  lightsleet                   => '๐จ',
  sleetshowers                 => '๐จ',
  sleet                        => '๐จ',
  heavysleetshowers            => '๐จ๐จ',
  heavysleet                   => '๐จ๐จ',
  lightsleetshowersandthunder  => '๐จโก',
  lightsleetandthunder         => '๐จโก',
  sleetshowersandthunder       => '๐จโก',
  sleetandthunder              => '๐จโก',
  heavysleetshowersandthunder  => '๐จ๐จโก',
  heavysleetandthunder         => '๐จ๐จโก',
  lightsnowshowers             => 'โ',
  lightsnow                    => 'โ',
  snowshowers                  => 'โ',
  snow                         => 'โ',
  heavysnowshowers             => 'โโ',
  heavysnow                    => 'โโ',
  lightsnowshowersandthunder   => 'โโก',
  lightsnowandthunder          => 'โโก',
  snowshowersandthunder        => 'โโก',
  snowandthunder               => 'โโก',
  heavysnowshowersandthunder   => 'โโโก',
  heavysnowandthunder          => 'โโโก',
};

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::WeatherEmojis - Weather emojis

=head1 VERSION

version 0.005

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

Requires L<Exporter> and L<Mojolicious>.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vรถgele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

None known.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2022 Andreas Vรถgele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
