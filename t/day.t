#!perl

# SPDX-License-Identifier: AGPL-3.0-or-later

use Mojo::Base -strict;

use open ':std', ':encoding(utf8)';

use Test::More tests => 1;

BEGIN {
  use_ok 'MyApp::Weather::Model::LocationForecast::Day';
}

sub _prevalent_condition {
  return MyApp::Weather::Model::LocationForecast::Day::_prevalent_condition(@_);
}

#is_deeply _prevalent_condition({1 => ['clearsky', 'fair'], 2 => ['rain']}),
#  ['clearsky', 'fair'], '_prevalent_condition returns longest array';
#is_deeply _prevalent_condition(
#  {1 => ['clearsky'], 2 => ['rain'], 3 => ['snow']}), ['snow'],
#  '_prevalent_condition returns array with highest weight';
