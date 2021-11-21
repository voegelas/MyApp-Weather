package MyApp::Weather::Model::LocationForecast::Day;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.002';

use Time::Seconds;

use overload
  bool     => sub {1},
  '""'     => sub { shift->to_string },
  fallback => 1;

has 'date';
has 'timeseries';

has daytime_start => 6;
has daytime_end   => 21;

has emojis      => q{};
has is_foggy    => 0;
has is_rainy    => 0;
has is_snowy    => 0;
has is_windy    => 0;
has symbol_code => q{};

has _extrema => sub { {} };

sub new {
  my $self = shift->SUPER::new(@_);

  $self->_initialize;

  return $self;
}

sub to_string ($self) {
  return sprintf '%s %s %.f° %.f°',
    $self->date->ymd,
    $self->emojis,
    $self->air_temperature_min // 0.0,
    $self->air_temperature_max // 0.0;
}

sub _initialize ($self) {
  my $timeseries = $self->timeseries;

  my $metrics = $timeseries->available_details;
  my %extrema
    = map { $_ => {min => +100_000.0, max => -100_000.0} } @{$metrics};

  my %timesteps_by_wetness;

  TIMESTEP:
  for my $timestep (@{$timeseries}) {
    my $details     = $timestep->details     or next TIMESTEP;
    my $symbol_code = $timestep->symbol_code or next TIMESTEP;
    my $wetness     = $timestep->wetness;

    if ($wetness > 2) {
      $self->is_snowy(1);
    }
    elsif ($wetness > 1) {
      $self->is_rainy(1);
    }

    if ($symbol_code eq 'fog') {
      $self->is_foggy(1);
    }

    # Get minimum and maximum values.
    METRIC:
    for my $metric (@{$metrics}) {
      my $value = $details->{$metric};
      next METRIC if !defined $value;

      if ($metric eq 'wind_speed') {
        if ($value >= 9.0) {
          $self->is_windy(1);
        }
      }

      my $pair = $extrema{$metric};
      if ($pair->{min} > $value) {
        $pair->{min} = $value;
      }
      if ($pair->{max} < $value) {
        $pair->{max} = $value;
      }
    }

    # Group the timesteps by wetness.
    push @{$timesteps_by_wetness{$wetness}}, $timestep;
  }

  $self->_extrema(\%extrema);

  # Group the timesteps by badness.
  my %timesteps_by_badness;
  for my $timestep (@{$self->_prevalent_condition(\%timesteps_by_wetness)}) {
    push @{$timesteps_by_badness{$timestep->badness}}, $timestep;
  }

  # Get a timestep with the prevalent weather conditions.
  my $timestep = shift @{$self->_prevalent_condition(\%timesteps_by_badness)};
  if (defined $timestep) {
    $self->symbol_code($timestep->symbol_code);

    my $emojis = $timestep->emojis;
    if ($timestep->wetness == 1) {
      if ($self->is_snowy) {
        $emojis = '❄' . $emojis;
      }
      elsif ($self->is_rainy) {
        $emojis = '☔' . $emojis;
      }
    }
    elsif ($timestep->wetness == 2) {
      if ($self->is_snowy) {
        $emojis = '❄' . $emojis;
      }
    }
    if ($self->is_foggy) {
      if ($self->symbol_code ne 'fog') {
        $emojis = '🌫' . $emojis;
      }
    }
    if ($self->is_windy) {
      $emojis = '🚩' . $emojis;
    }
    $self->emojis($emojis);
  }

  return;
}

sub _sum_duration ($self, $timesteps) {
  my $start_hour = $self->daytime_start;
  my $end_hour   = $self->daytime_end;

  my $duration = 0;
  for my $timestep (@{$timesteps}) {
    my $from_hour = $timestep->from->hour;
    my $to_hour   = $timestep->to->hour || 24;
    if ($to_hour > $start_hour && $from_hour < $end_hour) {
      my $daytime_duration = $timestep->duration;
      if ($from_hour < $start_hour) {
        $daytime_duration -= ($start_hour - $from_hour) * ONE_HOUR;
      }
      if ($to_hour > $end_hour) {
        $daytime_duration -= ($to_hour - $end_hour) * ONE_HOUR;
      }
      $duration += $daytime_duration;
    }
  }

  return $duration;
}

sub _prevalent_condition ($self, $timesteps_by_weight) {
  my $prevalent_timesteps = [];
  my $max_duration        = 0;
  my $max_weight          = -1;
  for my $weight (keys %{$timesteps_by_weight}) {
    my $timesteps = $timesteps_by_weight->{$weight};
    my $duration  = $self->_sum_duration($timesteps);
    my $diff      = $max_duration - $duration;
    if ($diff < 0 || ($diff == 0 && $max_weight < $weight)) {
      $prevalent_timesteps = $timesteps;
      $max_duration        = $duration;
      $max_weight          = $weight;
    }
  }

  return $prevalent_timesteps;
}

sub AUTOLOAD ($self) {
  my $value;

  our $AUTOLOAD;
  if ($AUTOLOAD =~ m{:: ([^:]*?) _ (min|max) \z}xms) {
    if (exists $self->_extrema->{$1}) {
      $value = $self->_extrema->{$1}->{$2};
    }
  }

  return $value;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast::Day - Weather forecast for a day

=head1 VERSION

version 0.002

=head1 SYNOPSIS

  my $day = MyApp::Weather::Model::LocationForecast::Day->new(
    date       => $tp,
    timeseries => $timeseries,
  );

=head1 DESCRIPTION

A weather forecast for a day.

=head1 ATTRIBUTES

=head2 date

  my $tp = $day->date;

A Time::Piece object.

=head2 timeseries

  my $timeseries = $day->timeseries;

A Mojo::Collection of MyApp::Weather::Model::LocationForecast::TimeStep
objects.

=head2 emojis

  my $chars = $day->emojis;

One or more emojis that depict the weather condition.

=head2 is_foggy

  my $bool = $day->is_foggy;

True if the day is foggy.

=head2 is_rainy

  my $bool = $day->is_rainy;

True if the day is rainy.

=head2 is_snowy

  my $bool = $day->is_snowy;

True if the day is snowy.

=head2 is_windy

  my $bool = $day->is_rainy;

True if the day is windy.

=head2 symbol_code

  my $symbol_code = $symbol_code;

The prevalent weather condition's symbol code.  See
L<MyApp::Weather::Model::LocationForecast::TimeStep> for possible values.

=head1 SUBROUTINES/METHODS

=head2 to_string

  my $chars = $self->to_string;

Returns a string that summarizes the weather condition.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires Mojolicious and Time::Seconds.

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
