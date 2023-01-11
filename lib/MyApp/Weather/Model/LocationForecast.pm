package MyApp::Weather::Model::LocationForecast;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use Mojo::Collection;
use MyApp::Weather::Model::LocationForecast::Day;
use MyApp::Weather::Model::LocationForecast::TimeStep;
use MyApp::Weather::Model::TimeZoneFinder;
use Time::Piece;
use Time::Seconds;

has 'hash';
has finder =>
  sub { state $finder = MyApp::Weather::Model::TimeZoneFinder->new };

sub _get_hours ($self, $forecast_object) {
  my @hours;

  my $time = $forecast_object->{time} // '1970-01-01T00:00:00Z';
  my $data = $forecast_object->{data} // {};

  my $utc   = Time::Piece->strptime($time, '%FT%TZ%z');
  my $epoch = $utc->epoch;
  my $from  = localtime $epoch;

  # Look for "next_1_hours", "next_6_hours" and "next_12_hours".
  my $duration = ~0;
  my $next_hours_key;
  for my $key (keys %{$data}) {
    if ($key =~ m{\A next_(\d+)_hours \z}xms) {
      if ($duration > $1) {
        $duration       = $1;
        $next_hours_key = $key;
      }
    }
  }

  if (defined $next_hours_key) {
    my $instant = $data->{instant};
    my $period  = $data->{$next_hours_key};
    # Split long periods into single hours.
    while ($duration > 0) {
      my $to       = $from + ONE_HOUR;
      my $timestep = MyApp::Weather::Model::LocationForecast::TimeStep->new(
        from    => $from,
        to      => $to,
        instant => $instant,
        period  => $period,
      );
      push @hours, $timestep;
      $from = $to;
      --$duration;
    }
  }
  return @hours;
}

sub timeseries ($self) {
  my $hash        = $self->hash               // {};
  my $geometry    = $hash->{geometry}         // {};
  my $coordinates = $geometry->{coordinates}  // [];
  my $lat         = $coordinates->[1]         // 0.0;
  my $lon         = $coordinates->[0]         // 0.0;
  my $properties  = $hash->{properties}       // {};
  my $timeseries  = $properties->{timeseries} // [];

  my $tz = $self->finder->time_zone_at(lat => $lat, lon => $lon);
  local $ENV{TZ} = $tz if defined $tz;

  my @timesteps = map { $self->_get_hours($_) } @{$timeseries};

  return Mojo::Collection->with_roles(
    'MyApp::Weather::Model::LocationForecast::Role::TimeSeries')
    ->new(@timesteps);
}

sub days ($self) {
  my $timeseries = $self->timeseries;

  # Partition the time series by day.
  my %date_for;
  my %timeseries_for;
  for my $timestep (@{$timeseries}) {
    my $from     = $timestep->from;
    my $from_ymd = $from->ymd;

    $date_for{$from_ymd} = $from->truncate(to => 'day');
    push @{$timeseries_for{$from_ymd}}, $timestep;
  }

  # Get the weather conditions per day.
  my @days = map {
    MyApp::Weather::Model::LocationForecast::Day->new(
      date       => $date_for{$_},
      timeseries => $timeseries->new(@{$timeseries_for{$_}}),
    );
  } sort keys %timeseries_for;

  # The last forecast may not span all day.
  if (@days > 0 && @{$days[-1]->timeseries} < 24) {
    splice @days, -1;
  }

  return Mojo::Collection->new(@days);
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast - Weather forecast for a location

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  my $forecast =
    MyApp::Weather::Model::LocationForecast->new(hash => $hash);
  for my $day (@{$forecast->days}) {
    say $day;
  }

=head1 DESCRIPTION

Wrapper class for location forecasts from MET Norway.

=head1 ATTRIBUTES

=head2 hash

  my $hash = $forecast->hash;

A weather forecast decoded from JSON.

=head1 SUBROUTINES/METHODS

=head2 timeseries

  my $timeseries = $forecast->timeseries;

Returns a L<Mojo::Collection> of
L<MyApp::Weather::Model::LocationForecast::TimeStep> objects.

=head2 days

  my $days = $forecast->days;

Splits the weather forecast into daily forecasts.  Returns a
L<Mojo::Collection> of L<MyApp::Weather::Model::LocationForecast::Day>
objects.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<Mojolicious>.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

None known.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
