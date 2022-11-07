package MyApp::Weather::Model::LocationForecast::TimeStep;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use MyApp::Weather::Model::WeatherEmojis qw($EMOJIS);
use MyApp::Weather::Model::WeatherBadness qw($BADNESS $WETNESS);
use Time::Piece;
use Time::Seconds;

has 'hash';

has 'from';
has to => sub ($self) { $self->from + $self->duration };
has 'duration';
has 'next_hours';

sub new {
  my $self = shift->SUPER::new(@_);

  $self->_initialize;

  return $self;
}

sub _initialize ($self) {
  if (!defined $self->from) {
    my $time = $self->hash->{time} // '1970-01-01T00:00:00Z';
    # XXX Use the location's timezone.
    my $from = localtime Time::Piece->strptime($time, '%FT%TZ%z')->epoch;
    $self->from($from);
  }

  if (!defined $self->duration) {
    my $data = $self->hash->{data} // {};
    # Look for "next_1_hours", "next_6_hours" and "next_12_hours".
    my $hours = ~0;
    my $next_hours_key;
    for my $key (keys %{$data}) {
      if ($key =~ m{\A next_(\d+)_hours \z}xms) {
        if ($hours > $1) {
          $hours          = $1;
          $next_hours_key = $key;
        }
      }
    }
    if (defined $next_hours_key) {
      my $next_hours = $data->{$next_hours_key};
      $self->duration(Time::Seconds->new(ONE_HOUR * $hours));
      $self->next_hours($next_hours);
    }
    else {
      $self->duration(Time::Seconds->new(0));
      $self->next_hours({});
    }
  }

  return;
}

sub clip_to_period ($self, $tp_from, $tp_to) {
  my $from        = $self->from;
  my $to          = $self->to;
  my $has_changes = 0;

  if ($from < $tp_from && $to > $tp_from) {
    $from        = $tp_from;
    $has_changes = 1;
  }

  if ($to > $tp_to && $from < $tp_to) {
    $to          = $tp_to;
    $has_changes = 1;
  }

  my $timestep = $self;
  if ($has_changes) {
    my $data = $self->hash->{data} // {};
    my $hash = {
      data => $data,
      time => (gmtime $from->epoch)->datetime . 'Z',
    };
    $timestep = MyApp::Weather::Model::LocationForecast::TimeStep->new(
      hash       => $hash,
      from       => $from,
      duration   => $to - $from,
      next_hours => $self->next_hours,
    );
  }

  return $timestep;
}

sub clip_to_day ($self, $tp) {
  my $tp_from  = $tp->truncate(to => 'day');
  my $tp_to    = $tp_from + ONE_DAY;
  my $timestep = $self->clip_to_period($tp_from, $tp_to);

  return $timestep;
}

sub details ($self) {
  my $data    = $self->hash->{data} // {};
  my $instant = $data->{instant}    // {};

  return $instant->{details} // {};
}

sub symbol_code ($self) {
  my $summary     = $self->next_hours->{summary} // {};
  my $symbol_code = $summary->{symbol_code}      // q{};

  $symbol_code =~ s{_(?:day|night|polartwilight) \z}{}xms;

  # Fix typos.
  if ($symbol_code eq 'lightssleetshowersandthunder') {
    $symbol_code = 'lightsleetshowersandthunder';
  }
  elsif ($symbol_code eq 'lightssnowshowersandthunder') {
    $symbol_code = 'lightsnowshowersandthunder';
  }

  return $symbol_code;
}

sub emojis ($self) {
  return $EMOJIS->{$self->symbol_code} // q{};
}

sub badness ($self) {
  return $BADNESS->{$self->symbol_code} // 0;
}

sub wetness ($self) {
  return $WETNESS->{$self->symbol_code} // 0;
}

sub AUTOLOAD ($self) {
  my $value;

  our $AUTOLOAD;
  if ($AUTOLOAD =~ m{:: ([^:]*?) \z}xms) {
    my $details = $self->details;
    if (exists $details->{$1}) {
      $value = $details->{$1};
    }
  }

  return $value;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast::TimeStep - Data point in weather forecasts

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  my $timestep =
    MyApp::Weather::Model::LocationForecast::TimeStep->new(hash => $hash);

=head1 DESCRIPTION

Wrapper class for time steps from MET Norway.

=head1 ATTRIBUTES

=head2 hash

  my $hash = $timestep->hash;

A time step decoded from JSON.

=head2 from

  my $tp = $timestep->from;

The time step's start time as a L<Time::Piece> object.  The start time is
inclusive.

=head2 to

  my $tp = $timestep->to;

The time step's end time as a L<Time::Piece> object.  The end time is
exclusive.

=head2 duration

  my $seconds = $timestep->duration;

The time step's duration as a L<Time::Seconds> object.

=head1 SUBROUTINES/METHODS

=head2 clip_to_period

  my $new_timestep = $timestep->clip_to_period($tp_from, $tp_to);

Returns a time step that is clipped to the specified time interval.

=head2 clip_to_day

  my $new_timestep = $timestep->clip_to_day($tp);

Returns a time step that is clipped to the specified day.

=head2 details

  my $hash = $timestep->details;

Returns the details from the decoded JSON time step.

=head2 symbol_code

  my $symbold_code = $timestep->symbol_code;

Returns the time step's symbol code.

MET Norway uses the following codes:

=over

=item * clearsky

=item * cloudy

=item * fair

=item * fog

=item * heavyrain

=item * heavyrainandthunder

=item * heavyrainshowers

=item * heavyrainshowersandthunder

=item * heavysleet

=item * heavysleetandthunder

=item * heavysleetshowers

=item * heavysleetshowersandthunder

=item * heavysnow

=item * heavysnowandthunder

=item * heavysnowshowers

=item * heavysnowshowersandthunder

=item * lightrain

=item * lightrainandthunder

=item * lightrainshowers

=item * lightrainshowersandthunder

=item * lightsleet

=item * lightsleetandthunder

=item * lightsleetshowers

=item * lightsleetshowersandthunder

=item * lightsnow

=item * lightsnowandthunder

=item * lightsnowshowers

=item * lightsnowshowersandthunder

=item * partlycloudy

=item * rain

=item * rainandthunder

=item * rainshowers

=item * rainshowersandthunder

=item * sleet

=item * sleetandthunder

=item * sleetshowers

=item * sleetshowersandthunder

=item * snow

=item * snowandthunder

=item * snowshowers

=item * snowshowersandthunder

=back

=head2 emojis

  my $chars = $timestep->emojis;

Returns one or more emojis that depict the weather condition.

=head2 badness

  my $weight = $timestep->badness;

Returns an integer weight.  Bad weather has a higher weight than good weather.
Can be used to sort time steps by weather condition.

=head2 wetness

  my $weight = $timestep->wetness;

Returns an integer weight.  Wet weather has a higher weight than dry weather.
Can be used to group time steps by wetness.  Possible values are:

=over

=item 1. Dry

=item 2. Rain

=item 3. Sleet

=item 4. Snow

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<Mojolicious>, L<Time::Piece> and L<Time::Seconds>.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

Currently, the local time zone is used to create L<Time::Piece> objects
instead of the location's time zone.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
