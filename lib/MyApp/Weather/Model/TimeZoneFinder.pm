package MyApp::Weather::Model::TimeZoneFinder;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use Mojo::Cache;

has finder => sub {
  my $finder;
  my $file_base = $ENV{TIME_ZONE_DATABASE};
  if (defined $file_base) {
    $finder = eval {
      require Geo::Location::TimeZoneFinder;
      Geo::Location::TimeZoneFinder->new(file_base => $file_base);
    };
  }
  return $finder;
};
has cache => sub { Mojo::Cache->new };

sub time_zone_at ($self, %position) {
  my $lat = $position{lat};
  my $lon = $position{lon};
  my $key = "$lat,$lon";
  my $tz  = $self->cache->get($key);
  if (!defined $tz) {
    my $finder = $self->finder;
    if (defined $finder) {
      $tz = $finder->time_zone_at(lat => $lat, lon => $lon);
      $self->cache->set($key, $tz);
    }
  }
  return $tz;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::TimeZoneFinder - Find a location's time zone

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  my $finder = MyApp::Weather::Model::TimeZoneFinder->new;
  my $tz     = $finder->time_zone_at(lat => $lat, lon => $lon);

=head1 DESCRIPTION

Maps geographic coordinates to time zone names, such as "Europe/Berlin".

=head1 SUBROUTINES/METHODS

=head2 time_zone_at

  my $tz = $finder->time_zone_at(lat => $lat, lon => $lon);

Returns the name of the time zone at the specified coordinates.

The time zone name can be used to get the local time at a location.

  my @time = do { local $ENV{TZ} = ":$tz"; localtime };

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Environment variables

The file base of a time zone database from
L<https://github.com/evansiroky/timezone-boundary-builder>, e.g.
F</usr/local/share/timezones/combined-shapefile>.

=head1 DEPENDENCIES

Requires L<Mojolicious> and L<Geo::Location::TimeZoneFinder>.

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
