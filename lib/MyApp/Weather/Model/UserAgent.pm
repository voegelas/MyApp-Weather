package MyApp::Weather::Model::UserAgent;
use Mojo::Base 'Mojo::UserAgent', -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.004';

use File::Spec;
use Mojo::Date;
use Mojo::File qw(path);
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Promise;
use Mojo::Util qw(sha1_sum);

has agent           => 'Mojolicious (Perl)';
has cache_dir       => File::Spec->tmpdir;
has max_redirects   => sub { $ENV{MOJO_MAX_REDIRECTS} // 4 };
has override_expire => sub {
  sub ($url) { return 0 };
};

sub new {
  my $self = shift->SUPER::new(@_);

  $self->transactor->name($self->agent);

  return $self;
}

sub cache_file ($self, $url) {
  my $digest  = sha1_sum($url);
  my $version = 1;
  my $path    = path($self->cache_dir)->child($digest . $version);

  return $path;
}

sub read_cache ($self, $cache_file) {
  my $tx;

  my $bytes = eval { $cache_file->slurp };
  if (defined $bytes) {
    my $data = decode_json($bytes);
    $tx = Mojo::Transaction::HTTP->new;
    my $request  = $tx->req;
    my $response = $tx->res;
    $request->url->parse($data->{url});
    $response->code(200);
    $response->headers->from_hash($data->{headers});
    $response->headers->header('X-Cache-File', $cache_file);
    $response->body($data->{body});
  }

  return $tx;
}

sub write_cache ($self, $cache_file, $tx) {
  my $request  = $tx->req;
  my $response = $tx->res;
  my $data     = {
    url     => $request->url->to_string,
    headers => $response->headers->to_hash,
    body    => $response->body,
  };
  my $bytes = encode_json($data);

  return eval { $cache_file->spurt($bytes) };
}

sub last_modified ($self, $filename) {
  my $mtime;

  my @stat = stat $filename;
  if (@stat) {
    $mtime = $stat[9];
  }

  return $mtime;
}

sub file_age ($self, $filename) {
  my $age = ~0;

  my $mtime = $self->last_modified($filename);
  if (defined $mtime) {
    $age = time - $mtime;
  }

  return $age;
}

sub has_expired ($self, $cache_tx) {
  my $has_expired = 0;

  # Never expire when the module is tested.
  return 0 if $ENV{CACHE_DOES_NOT_EXPIRE};

  my $request    = $cache_tx->req;
  my $response   = $cache_tx->res;
  my $url        = $request->url->to_string;
  my $cache_file = $response->headers->header('X-Cache-File');
  if ($self->file_age($cache_file) > $self->override_expire->($url)) {
    my $expires = $response->headers->expires;
    if (defined $expires) {
      my $expiration_time = eval { Mojo::Date->new($expires) };
      if (defined $expiration_time) {
        if (time >= $expiration_time->epoch) {
          $has_expired = 1;
        }
      }
    }
  }

  return $has_expired;
}

sub get_p ($self, $url, $log, @args) {
  my $promise;

  my $cache_tx;
  my $cache_time;

  # Check if a cached response exists.
  my $cache_file = $self->cache_file($url);
  if (-f $cache_file) {
    $cache_tx = $self->read_cache($cache_file);
    if (defined $cache_tx) {
      if ($self->has_expired($cache_tx)) {
        $cache_time = Mojo::Date->new($self->last_modified($cache_file));
      }
      else {
        $log->debug("Cache hit for $url");
        $promise = Mojo::Promise->resolve($cache_tx);
      }
    }
  }

  if (!defined $promise) {
    my $remote_tx = $self->build_tx(GET => $url, @args);
    if (defined $cache_time) {
      $remote_tx->req->headers->header('If-Modified-Since',
        $cache_time->to_string);
    }
    $promise = $self->start_p($remote_tx)->then(sub ($tx) {
      my $response = $tx->res;
      if ($response->is_error) {
        $log->error("Could not fetch $url");
      }
      if ($response->is_success) {
        $log->debug("Fetched $url");
        if (!$self->write_cache($cache_file, $tx)) {
          $log->error("Could not cache $url");
        }
      }
      elsif (defined $cache_tx) {
        $log->debug("Cache hit for $url");
        $tx = $cache_tx;
      }
      return $tx;
    });
  }

  return $promise;
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::UserAgent - Caching HTTP user agent

=head1 VERSION

version 0.004

=head1 SYNOPSIS

  my $log = Mojo::Log->new;
  my $ua  = MyApp::Weather::Model::UserAgent->new(
    agent     => 'example.com support@example.com',
    cache_dir => '/var/cache/weather',
  );
  my $promise = $ua->get_p($url, $log)->then(sub ($tx) {
    my $response = $tx->res;
    if ($response->is_success) {
      say $response->body;
    }
  });

=head1 DESCRIPTION

A L<Mojo::UserAgent> subclass that caches content for a period of time.

=head1 ATTRIBUTES

=head2 agent

  my $agent = $ua->agent;

A user agent string.

=head2 cache_dir

  my $cache_dir = $ua->cache_dir;

The requested data is cached in this directory.  The directory has to exist.

=head2 override_expire

  my $seconds = $ua->override_expire->($url);

A subroutine that takes a URL and returns a minimum age in seconds.

=head1 SUBROUTINES/METHODS

=head2 cache_file

  my $cache_file = $ua->cache_file($url);

Maps a web address to a filename.

=head2 read_cache

  my $tx = $ua->read_cache($cache_file);

Reads cached content from a file and returns a L<Mojo::Transaction::HTTP>
object.

=head2 write_cache

  my $path = $ua->write_cache($cache_file, $tx);

Writes a L<Mojo::Transaction::HTTP> object to a file.

=head2 last_modified

  my $mtime = $ua->last_modified($filename);

Returns the specified file's last modification time in seconds since the
epoch.

=head2 file_age

  my $seconds = $ua->file_age($filename);

Returns the specified file's age in seconds.

=head2 has_expired

  my $bool = $ua->has_expired($cache_tx);

Returns true if the cached content is outdated.

=head2 get_p

  my $promise = $ua->get_p($url, $log, @args);

Reads cached content or performs a non-blocking request.  Returns a
L<Mojo::Promise> object that is resolved with a L<Mojo::Transaction::HTTP>
object.

=head1 DIAGNOSTICS

=over

=item B<< Cache hit for URL >>

The requested data was served from the cache.

=item B<< Could not cache URL >>

A file could not be written to the cache directory.

=item B<< Could not fetch URL >>

The requested data could not be fetched from the specified URL.

=item B<< Fetched URL >>

The requested data was fetched from the specified URL.

=back

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

Copyright 2022 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
