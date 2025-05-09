package MyApp::Weather::Model::LocationForecast::TimeStep;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.007';

use MyApp::Weather::Model::WeatherEmojis  qw($EMOJIS);
use MyApp::Weather::Model::WeatherBadness qw($BADNESS $WETNESS);

has 'from';
has 'to';
has duration => sub ($self) { $self->to - $self->from };
has 'instant';
has 'period';

sub details ($self) {
    my $instant = $self->instant // {};
    return $instant->{details} // {};
}

sub symbol_code ($self) {
    my $summary     = $self->period->{summary} // {};
    my $symbol_code = $summary->{symbol_code}  // q{};

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

version 0.007

=head1 SYNOPSIS

  my $timestep = MyApp::Weather::Model::LocationForecast::TimeStep->new(
    from    => $from,
    to      => $to,
    instant => $instant,
    period  => $period,
  );

=head1 DESCRIPTION

Wrapper class for time steps from MET Norway.

=head1 ATTRIBUTES

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

=head2 instant

  my $hash = $timestep->instant;

Parameters that describe the state at that exact time instant, e.g.
air_temperature.

=head2 period

  my $hash = $timestep->period;

Parameters that describe a period of time, e.g. air_temperature_min,
air_temperature_min.

=head1 SUBROUTINES/METHODS

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

Requires L<Mojolicious>.

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2023 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
