requires 'Math::Random::Secure';
requires 'Mojo::Base';
requires 'Moo';
requires 'Types::Standard';
requires 'namespace::autoclean';
requires 'perl', '5.028';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};


