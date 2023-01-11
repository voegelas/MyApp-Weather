#!perl

# SPDX-License-Identifier: AGPL-3.0-or-later

use Mojo::Base -strict;

use Test::More tests => 4;

use Time::Piece;
use Time::Seconds;

BEGIN {
    use_ok 'MyApp::Weather::Model::LocationForecast::TimeStep';
}

my $hours = 18;

my $from    = localtime;
my $to      = $from + $hours * ONE_HOUR;
my $instant = {details => {air_temperature => 9.3}};
my $period  = {summary => {symbol_code     => 'fair_day'}};

my $timestep
    = new_ok 'MyApp::Weather::Model::LocationForecast::TimeStep' =>
    [from => $from, to => $to, instant => $instant, period => $period];

isa_ok $timestep, 'MyApp::Weather::Model::LocationForecast::TimeStep',
    'timestep';

subtest 'time' => sub {
    plan tests => 5;

    my $from     = $timestep->from;
    my $to       = $timestep->to;
    my $duration = $timestep->duration;
    isa_ok $from,     'Time::Piece',   'from';
    isa_ok $to,       'Time::Piece',   'to';
    isa_ok $duration, 'Time::Seconds', 'duration';
    cmp_ok $duration, '==', $hours * ONE_HOUR, "duration is $hours hours";
    cmp_ok $to, '==', $from + $duration, 'start plus duration equals end';
};
