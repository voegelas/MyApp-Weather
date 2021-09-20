requires 'perl', '5.020';

requires 'Exporter';
requires 'Math::BigFloat';
requires 'Mojolicious', '9.0';
requires 'Role::Tiny', '2.000001';
requires 'Time::Piece';
requires 'Time::Seconds';

on 'test' => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Mojo';
};

on 'develop' => sub {
    requires 'Dist::Zilla';
    requires 'Dist::Zilla::Plugin::CopyFilesFromBuild';
    requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
    requires 'Dist::Zilla::Plugin::Test::Kwalitee';
    requires 'Pod::Coverage::TrustPod';
    requires 'Test::Kwalitee', '1.21';
    requires 'Test::Pod::Coverage';
};
