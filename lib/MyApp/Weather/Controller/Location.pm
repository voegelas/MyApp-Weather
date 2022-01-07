package MyApp::Weather::Controller::Location;
use Mojo::Base 'Mojolicious::Controller', -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.003';

use File::Spec;
use Mojo::File qw(path);
use MyApp::Weather::Model::LocationForecast::Download;

our %VALID = (
  location         => qr{\A [- [:alpha:]]{2,64} \z}xms,
  temperature_unit => qr{\A [CF] \z}xmsi,
);

has agent => sub ($c) { $ENV{WEATHER_USER_AGENT} || 'Mojolicious (Perl)' };

has cache_dir => sub ($c) {
  my $path = File::Spec->tmpdir;
  if (exists $ENV{CACHE_DIRECTORY}) {
    $path = $ENV{CACHE_DIRECTORY};
  }
  elsif (exists $ENV{HOME}) {
    my $user_path = path($ENV{HOME}, '.cache', 'weather');
    if (-d $user_path && -w $user_path) {
      $path = $user_path;
    }
  }

  return $path;
};

has lang => sub ($c) { exists $ENV{LANG} ? $ENV{LANG} =~ s{_.*}{}xmsr : 'en' };

has temperature_unit => sub ($c) { $ENV{TEMPERATURE_UNIT} || 'C' };

has download => sub ($c) {
  state $download = MyApp::Weather::Model::LocationForecast::Download->new(
    agent        => $c->agent,
    cache_dir    => $c->cache_dir,
    default_lang => $c->lang,
  );
};

sub calendar ($c) {
  my $location = $c->stash('location');

  my $log = $c->log;

  # Check the input.
  my $v = $c->validation;

  my $lang = $v->optional('lang')->size(2, 2)->param || $c->lang;

  my %units;
  $units{temperature}
    = uc($v->optional('temperature_unit')->like($VALID{temperature_unit})->param
      || $c->temperature_unit);

  if ($v->has_error || $location !~ $VALID{location}) {
    return $c->reply->exception('Invalid argument');
  }

  # Get and render the weather forecast.
  $c->render_later;

  my $arg_ref = {log => $log};
  $c->download->get_forecast_p($location, $arg_ref)->then(sub ($forecast) {
    $c->res->headers->cache_control('public, max-age=3600');
    $c->stash('agent',    $c->download->agent);
    $c->stash('forecast', $forecast);
    $c->stash('lang',     $lang);
    $c->stash('units',    \%units);
    return $c->render;
  })->catch(sub (@err) {
    $log->error(@err);
    return $c->reply->not_found;
  });

  return 1;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Controller::Location - Weather forecast controller

=head1 VERSION

version 0.003

=head1 SYNOPSIS

  my $r = $app->routes;
  $r->get('/:location' => [format => ['ics']])->to('Location#calendar');

=head1 DESCRIPTION

A L<Mojolicious::Controller> subclass that gets and renders the weather
forecast for a location.

=head1 SUBROUTINES/METHODS

=head2 calendar

  my $r = $app->routes;
  $r->get('/:location' => [format => ['ics']])->to('Location#calendar');

Gets a weather forecast and renders the result.

Supports the following query parameters:

=over

=item * lang  I<optional>

The language the weather forecast is rendered in.  See
L<MyApp::Weather::View::Messages> for supported languages.

=item * temperature_unit  I<optional>

The temperature unit.  Valid values are "C" for Celsius and "F" for
Fahrenheit.

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

See L<MyApp::Weather>.

=head1 DEPENDENCIES

Requires L<File::Spec> and L<Mojolicious>.

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
