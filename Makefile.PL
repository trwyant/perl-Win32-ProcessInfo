use 5.006;

use strict;
use warnings;

use Config;
use ExtUtils::MakeMaker;

## my $vers = $] >= 5.008 ? '-5.8' : '';
my $vers = '';

(my $mmv = ExtUtils::MakeMaker->VERSION) =~ s/_//g;

my %args = (
    NAME => 'Win32::Process::Info',
    VERSION_FROM => 'lib/Win32/Process/Info.pm',
    PREREQ_PM => {},
    PL_FILES => {},	# Prevent old MakeMaker from running Build.PL
    'dist' => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    AUTHOR => 'Tom Wyant (wyant at cpan dot org)',
    ABSTRACT => 'Get information on arbitrary processes in Windows NT',
    BINARY_LOCATION => "$Config{archname}$vers/Win32-Process-Info.tar.gz",
);

$mmv >= 6.31 and $args{LICENSE} = 'perl';

$mmv >= 6.4501 and $args{META_ADD} = {
    no_index => {
	directory => [ qw{ inc t xt } ],
    },
};

$mmv >= 6.4501 and $args{META_MERGE} = {
    resources => {
	bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Win32-Process-Info',
	license => 'http://dev.perl.org/licenses/',
    },
};

WriteMakefile(%args);

