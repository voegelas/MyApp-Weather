#!perl

# SPDX-License-Identifier: AGPL-3.0-or-later

use Mojo::Base -strict;

use Test::More tests => 4;

BEGIN {
    use_ok 'MyApp::Weather::Model::LocationForecast';
}

my $hours = 18;

#<<<
my $timeseries_array = [
  {
    time => "2021-10-21T12:00:00Z",
    data => {
      instant => {
        details => {
          air_temperature => 9.3,
        },
      },
      "next_${hours}_hours" => {
        summary => {
          symbol_code => 'fair_day',
        },
      },
    },
  },
  {
    time => "2021-10-22T06:00:00Z",
    data => {
      instant => {
        details => {
          air_temperature => 4.9,
        },
      },
      "next_${hours}_hours" => {
        summary => {
          symbol_code => 'partlycloudy_day',
        },
      },
    },
  },
];

my $forecast_hash = {
  geometry => {
    coordinates => [10.739, 59.9133, 8],
    type        => 'Point',
  },
  properties => {
    timeseries => $timeseries_array,
  },
};
#>>>

my $forecast
    = new_ok 'MyApp::Weather::Model::LocationForecast' =>
    [hash => $forecast_hash];

subtest 'timeseries' => sub {
    plan tests => 4;

    my $timeseries = $forecast->timeseries;
    isa_ok $timeseries, 'Mojo::Collection', 'timeseries';
    cmp_ok $timeseries->size, '>', 0, 'timeseries is not empty';

    my $timestep = $timeseries->first;
    isa_ok $timestep, 'MyApp::Weather::Model::LocationForecast::TimeStep',
        'timestep';

    ok !$timeseries->first(sub { $_->symbol_code eq q{} }),
        'no empty symbol codes';
};

subtest 'days' => sub {
    plan tests => 4;

    my $days = $forecast->days;
    isa_ok $days, 'Mojo::Collection', 'days';
    cmp_ok $days->size, '>', 0, 'days is not empty';

    my $day = $days->first;
    isa_ok $day, 'MyApp::Weather::Model::LocationForecast::Day', 'day';

    ok !$days->first(sub { $_->emojis eq q{} }), 'no empty emojis';
};
