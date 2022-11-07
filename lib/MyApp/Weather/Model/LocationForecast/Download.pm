package MyApp::Weather::Model::LocationForecast::Download;
use Mojo::Base -base, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use File::Spec;
use Mojo::Log;
use Mojo::Util qw(url_escape);
use MyApp::Weather::Model::LocationForecast;
use MyApp::Weather::Model::UserAgent;

has agent     => 'Mojolicious (Perl)';
has cache_dir => File::Spec->tmpdir;
has lang      => 'en';

has forecast_url_format =>
  'https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=%.4f&lon=%.4f';

has place_url_format =>
  'https://nominatim.openstreetmap.org/search?city=%s&format=jsonv2&limit=1';

has ua => sub ($self) {
  MyApp::Weather::Model::UserAgent->new(
    agent           => $self->agent,
    cache_dir       => $self->cache_dir,
    override_expire => sub ($url) {
      return ~0 if index($url, '/nominatim.openstreetmap.org/') >= 0;
      return 7_200 + int rand 3_600 if index($url, '/locationforecast/') >= 0;
      return 0;
    },
  );
};

sub get_forecast_p ($self, $location, $arg_ref = {}) {
  my $log     = $arg_ref->{log} // Mojo::Log->new;
  my $referer = $arg_ref->{referer};

  my $ua = $self->ua;

  my $headers = {'Accept-Language' => $self->lang . ';q=1.0,*;q=0.1'};
  if (defined $referer) {
    $headers->{'Referer'} = $referer;
  }

  my $place_url = sprintf $self->place_url_format, url_escape($location);
  my $promise   = $ua->get_p($place_url, $log, $headers)->then(sub ($tx) {
    if ($tx->res->is_success) {
      my $places = $tx->res->json;
      if (ref $places eq 'ARRAY') {
        my $place = $places->[0];
        if (defined $place) {
          my $forecast_url = sprintf $self->forecast_url_format,
            url_escape($place->{lat}),
            url_escape($place->{lon});
          return $ua->get_p($forecast_url, $log);
        }
      }
    }
    return;
  })->then(sub ($tx) {
    if ($tx->res->is_success) {
      my $hash = $tx->res->json;
      if (ref $hash eq 'HASH') {
        return MyApp::Weather::Model::LocationForecast->new(hash => $hash);
      }
    }
    return;
  });

  return $promise;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast::Download - Download weather forecasts

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  my $download = MyApp::Weather::Model::LocationForecast::Download->new(
    agent => 'example.com support@example.com',
  );
  $download->get_forecast_p('Oslo')->then(sub ($forecast) {
    printf "%d time steps downloaded\n", $forecast->timeseries->size;
  })->wait;

=head1 DESCRIPTION

Fetches a weather forecast for a location from MET Norway.

=head1 ATTRIBUTES

=head2 agent

  my $chars = $download->agent;

An identifying user agent string.

=head2 cache_dir

  my $path = $download->cache_dir;

Weather forecasts and locations are cached in this directory.

=head2 lang

  my $lang = $download->lang;

Data is fetched in this language.

=head1 SUBROUTINES/METHODS

=head2 get_forecast_p

  my $promise = $forecast->get_forecast_p($location, $arg_ref);

Returns a promise that is resolved with a
L<MyApp::Weather::Model::LocationForecast> object.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<File::Spec> and L<Mojolicious>.

=head1 INCOMPATIBILITIES

None.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 BUGS AND LIMITATIONS

None known.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
