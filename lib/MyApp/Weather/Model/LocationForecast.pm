package MyApp::Weather::Model::LocationForecast;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.004';

use Mojo::Collection;
use MyApp::Weather::Model::LocationForecast::Day;
use MyApp::Weather::Model::LocationForecast::TimeStep;

has 'hash';

sub timeseries ($self) {
  my $hash       = $self->hash               // {};
  my $properties = $hash->{properties}       // {};
  my $timeseries = $properties->{timeseries} // [];

  my @timesteps
    = map { MyApp::Weather::Model::LocationForecast::TimeStep->new(hash => $_) }
    @{$timeseries};

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

    my $to     = $timestep->to - 1;
    my $to_ymd = $to->ymd;

    $date_for{$from_ymd} = $from->truncate(to => 'day');
    push @{$timeseries_for{$from_ymd}}, $timestep->clip_to_day($from);

    if ($from_ymd ne $to_ymd) {
      $date_for{$to_ymd} = $to->truncate(to => 'day');
      push @{$timeseries_for{$to_ymd}}, $timestep->clip_to_day($to);
    }
  }

  # Get the weather conditions per day.
  my @days = map {
    MyApp::Weather::Model::LocationForecast::Day->new(
      date       => $date_for{$_},
      timeseries => $timeseries->new(@{$timeseries_for{$_}}),
    );
  } sort keys %timeseries_for;

  # The last forecast doesn't span all day.
  splice @days, -1;

  return Mojo::Collection->new(@days);
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast - Weather forecast for a location

=head1 VERSION

version 0.004

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

Copyright 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
