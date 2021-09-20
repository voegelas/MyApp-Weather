#!perl

# SPDX-License-Identifier: AGPL-3.0-or-later

use Mojo::Base -strict;

use open ':std', ':encoding(utf8)';

use Test::More tests => 4;

use Time::Seconds;

BEGIN {
  use_ok 'MyApp::Weather::Model::LocationForecast::TimeStep';
}

my $hours = 18;

#<<<
my $timestep_hash = {
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
};
#>>>

my $timestep
  = new_ok 'MyApp::Weather::Model::LocationForecast::TimeStep' =>
  [hash => $timestep_hash];

isa_ok $timestep, 'MyApp::Weather::Model::LocationForecast::TimeStep',
  'timestep';

subtest 'time' => sub {
  plan tests => 9;

  my $from     = $timestep->from;
  my $to       = $timestep->to;
  my $duration = $timestep->duration;
  isa_ok $from,     'Time::Piece',   'from';
  isa_ok $to,       'Time::Piece',   'to';
  isa_ok $duration, 'Time::Seconds', 'duration';
  cmp_ok $duration, '==', $hours * ONE_HOUR, "duration is $hours hours";
  cmp_ok $to,       '==', $from + $duration, 'start plus duration equals end';

  my $first_day = $timestep->clip_to_day($from);
  cmp_ok $first_day->from, '==', $from, 'start has not changed';
  cmp_ok $first_day->to, '<=', $from->truncate(to => 'day') + ONE_DAY,
    'end is not too high';

  my $second_day = $timestep->clip_to_day($to);
  cmp_ok $second_day->from, '>=', $to->truncate(to => 'day'),
    'start is not too low';
  cmp_ok $second_day->to, '==', $to, 'end has not changed';
};
