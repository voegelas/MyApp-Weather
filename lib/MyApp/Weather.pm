package MyApp::Weather;
use Mojo::Base 'Mojolicious', -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.004';

use Mojo::File qw(curfile);
use Mojo::Home;

has default_location => 'Oslo';

sub startup ($app) {
  # Switch to installable directories.
  $app->home(Mojo::Home->new(curfile->sibling('Weather')));
  $app->static->paths->[0]   = $app->home->child('public');
  $app->renderer->paths->[0] = $app->home->child('templates');

  # Use random secrets since this application doesn't use session cookies.
  $app->secrets([rand]);

  # Map the file extension "ics" to the MIME type "text/calendar".
  $app->types->type(ics => 'text/calendar');

  # Register helpers and hooks.
  $app->plugin('MyApp::Weather::Plugin::Helpers');
  $app->hook(before_dispatch => \&_before_dispatch);

  my $r = $app->routes;

  # Route requests like "/Oslo.ics" to MyApp::Weather::Controller::Location.
  $r->get('/:location' => [format => [qw(html ics)]])->to(
    'Location#calendar',
    format   => 'ics',
    location => $app->default_location,
  );

  return;
}

sub _before_dispatch ($c) {
  if (state $base = $ENV{REQUEST_BASE}) {
    my $url = Mojo::URL->new($base);
    if ($url->host) {
      $c->req->url->base($url);
    }
    else {
      $c->req->url->base->path($url->path);
    }
  }

  return;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather - Weather forecasts in the iCalendar data format

=head1 VERSION

version 0.004

=head1 SYNOPSIS

  env WEATHER_USER_AGENT='example.com support@example.com' \
      script/weather daemon -l http://localhost:3000
  curl http://localhost:3000/Oslo.ics

=head1 DESCRIPTION

A L<Mojolicious> web application that gets weather forecasts from L<MET
Norway|https://api.met.no/> and produces web calendars in the iCalendar data
format.

=head1 SUBROUTINES/METHODS

=head2 startup

  $app->startup;

Sets up the application and the routes.

Requests are routed to L<MyApp::Weather::Controller::Location>.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Environment variables

=head3 LANG

The default weather forecast language.  See L<MyApp::Weather::View::Messages>
for supported languages.

=head3 CACHE_DIRECTORY

Weather forecasts and locations are cached in this directory.  The directory
must exist and be writable.

=head3 REQUEST_BASE

The base in the frontend proxy.

=head3 TEMPERATURE_UNIT

The default temperature unit.  Valid values are "C" for Celsius and "F" for
Fahrenheit.

=head3 WEATHER_USER_AGENT

An identifying user agent string.  See
L<https://api.met.no/doc/TermsOfService> and
L<https://operations.osmfoundation.org/policies/nominatim/> for more
information.

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
