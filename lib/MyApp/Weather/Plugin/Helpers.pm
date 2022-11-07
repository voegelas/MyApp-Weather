package MyApp::Weather::Plugin::Helpers;
use Mojo::Base 'Mojolicious::Plugin', -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.005';

use MyApp::Weather::View::Messages qw(gettext);

sub register ($self, $app, $conf) {
  $app->helper('gettext' => sub { shift; gettext(@_) });
  $app->helper(
    'make_format_temperature' => sub { shift; _make_format_temperature(@_) });

  return;
}

sub _make_round ($scale = -1) {
  return sub ($num) { int $num + ($num > 0 ? 0.5 : -0.5) };
}

sub _make_format_temperature ($unit, $scale = -1) {
  my $round = _make_round($scale);
  return $unit eq 'F'
    ? sub ($celsius) { $round->(9.0 * $celsius / 5.0 + 32.0) }
    : sub ($celsius) { $round->($celsius) };
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Plugin::Helpers - Mojolicious helpers

=head1 VERSION

version 0.005

=head1 SYNOPSIS

  $app->plugin('MyApp::Weather::Plugin::Helpers');

=head1 DESCRIPTION

Helpers for L<MyApp::Weather>.

=head1 HELPERS

=head2 gettext

  my $chars = $c->gettext($lang => @what);

Returns a translation.

=head2 make_format_temperature

  my $format_temperature = $c->make_format_temperature('F');
  say $format_temperature->(20.5);

Makes a function that outputs temperatures in Celsius or Fahrenheit.

=head1 SUBROUTINES/METHODS

=head2 register

  $plugin->register($app);

Registers helpers in L<MyApp::Weather>.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<Math::BigFloat> and L<Mojolicious>.

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
