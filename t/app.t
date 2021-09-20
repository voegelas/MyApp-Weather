#!perl

# SPDX-License-Identifier: AGPL-3.0-or-later

use Mojo::Base -strict;

use open ':std', ':encoding(utf8)';

use Test::More;
use Test::Mojo;

use Mojo::File qw(path);

$ENV{CACHE_DIRECTORY}       = path('t')->child('cache');
$ENV{CACHE_DOES_NOT_EXPIRE} = 1;
$ENV{LANG}                  = 'en_US.UTF-8';
$ENV{TEMPERATURE_UNIT}      = 'C';

my $t = Test::Mojo->new('MyApp::Weather');
$t->get_ok('/Oslo.ics')->status_is(200)
  ->content_type_is('text/calendar')
  ->content_like(qr{^ BEGIN:VCALENDAR $}xms)
  ->content_like(qr{^ PRODID:}xms)
  ->content_like(qr{^ VERSION:}xms)
  ->content_like(qr{^ BEGIN:VEVENT $}xms)
  ->content_like(qr{^ UID:}xms)
  ->content_like(qr{^ DTSTAMP:\d{8,}T\d{6}Z $}xms)
  ->content_like(qr{^ DTSTART;VALUE=DATE:\d{8,} $}xms)
  ->content_like(qr{^ SUMMARY:}xms)
  ->content_like(qr{^ LOCATION:Oslo $}xms)
  ->content_like(qr{^ DESCRIPTION:}xms)
  ->content_like(qr{^ CLASS:PUBLIC $}xms)
  ->content_like(qr{^ TRANSP:TRANSPARENT $}xms)
  ->content_like(qr{^ X-SOGO-SEND-APPOINTMENT-NOTIFICATIONS:NO $}xms)
  ->content_like(qr{^ END:VEVENT $}xms)
  ->content_like(qr{^ END:VCALENDAR $}xms);

done_testing();
