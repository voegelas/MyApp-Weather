package MyApp::Weather::Model::LocationForecast::Role::TimeSeries;
use Mojo::Base -role, -signatures;

# SPDX-License-Identifier: AGPL-3.0-or-later

our $VERSION = '0.007';

use Mojo::Collection;

sub available_details ($self) {
    my %keys;

    for my $timestep (@{$self}) {
        if (my $details = $timestep->details) {
            for my $key (keys %{$details}) {
                $keys{$key} = 1;
            }
        }
    }

    return Mojo::Collection->new(sort keys %keys);
}

sub _merge ($timesteps) {
    # Average the timesteps' metrics.
    my %average_for;

    for my $timestep (@{$timesteps}) {
        my $details = $timestep->details;
        if (defined $details) {
            my $duration = $timestep->duration;
            for my $metric (keys %{$details}) {
                my $value = $details->{$metric};
                if (exists $average_for{$metric}) {
                    my $average = $average_for{$metric};
                    $average->[0] += $value * $duration;
                    $average->[1] += $duration;
                }
                else {
                    $average_for{$metric} = [$value * $duration, $duration];
                }
            }
        }
    }

    my %details;
    for my $metric (keys %average_for) {
        my ($numerator, $denominator) = @{$average_for{$metric}};
        if ($denominator > 0) {
            $details{$metric} = $numerator / $denominator;
        }
    }

    # Create a new timestep.
    my $first_timestep = $timesteps->[0];
    my $last_timestep  = $timesteps->[-1];

    my $timestep = MyApp::Weather::Model::LocationForecast::TimeStep->new(
        from    => $first_timestep->from,
        to      => $last_timestep->to,
        instant => {details => \%details},
        period  => $first_timestep->period,
    );

    return $timestep;
}

sub _has_similar_temperature ($ts1, $ts2) {
    return $ts1->symbol_code eq $ts2->symbol_code
        && abs($ts1->air_temperature - $ts2->air_temperature) <= 3.0;
}

sub merge_timesteps ($self, $is_similar = \&_has_similar_temperature) {
    my @timesteps;

    my @similar_timesteps;
    for my $timestep (@{$self}) {
        if (@similar_timesteps > 0) {
            if (!$is_similar->($timestep, $similar_timesteps[0])) {
                push @timesteps, _merge(\@similar_timesteps);
                @similar_timesteps = ();
            }
        }
        push @similar_timesteps, $timestep;
    }
    if (@similar_timesteps > 0) {
        push @timesteps, _merge(\@similar_timesteps);
    }

    return $self->new(@timesteps);
}

1;
__END__

=encoding UTF-8

=head1 NAME

MyApp::Weather::Model::LocationForecast::Role::TimeSeries - Mojo::Collection role

=head1 VERSION

version 0.007

=head1 SYNOPSIS

  my $new_class = Mojo::Collection->with_roles(
    'MyApp::Weather::Model::LocationForecast::Role::TimeSeries');

=head1 DESCRIPTION

A role for time step collections.

=head1 SUBROUTINES/METHODS

=head2 available_details

  my $collection = $timeseries->available_details;

Returns a L<Mojo::Collection> of available details, e.g. "air_temperature" and
"wind_speed".

=head2 merge_timesteps

  my $new_timeseries = $timeseries->merge_timesteps(sub ($step1, $step2) {
    $step1->badness == $step2->badness
  });

Merges consecutive time steps that are similar according to the specified
function.  Returns a L<Mojo::Collection>.

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

Requires L<Mojolicious> and L<Role::Tiny>.

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Andreas Vögele E<lt>andreas@andreasvoegele.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2023 Andreas Vögele

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
