requires 'Feature::Compat::Class';
requires 'Net::LastFM';
requires 'Getopt::Long';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::MockModule';
    requires 'Capture::Tiny';
};
